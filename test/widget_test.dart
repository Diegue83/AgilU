import 'package:agilu/app.dart';
import 'package:agilu/core/routes.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/estacion_repository.dart';
import 'package:agilu/data/repositories/foto_repository.dart';
import 'package:agilu/data/repositories/menu_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/data/repositories/producto_repository.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _encargado = Perfil(
  nombre: 'Beto',
  correo: 'beto@utng.edu.mx',
  rol: RolUsuario.encargado,
  cafeteriaId: 'c1',
  cafeteria: 'Central',
);

Widget _app(AuthRepository auth,
        {String ruta = Routes.login, PerfilRepository? perfiles}) =>
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: auth),
        Provider<PerfilRepository>.value(
            value: perfiles ?? MockPerfilRepository()),
        Provider<EstacionRepository>(create: (_) => MockEstacionRepository()),
        Provider<ProductoRepository>(create: (_) => MockProductoRepository()),
        Provider<FotoRepository>(create: (_) => MockFotoRepository()),
        Provider<MenuRepository>(create: (_) => MockMenuRepository()),
        Provider<PedidoRepository>(create: (_) => MockPedidoRepository()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: AgilUApp(rutaInicial: ruta),
    );

Future<void> _iniciarSesion(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'alumno@utng.edu.mx');
  await tester.enterText(find.byType(TextField).at(1), '123456');
  await tester.tap(find.text('Iniciar sesión'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin sesión abre en el login', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository()));
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('con sesión guardada abre directo en el menú', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(), ruta: Routes.menu));
    await tester.pumpAndSettle();
    expect(find.text('Menú de hoy'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
  });

  testWidgets('el login muestra el error de validación', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository()));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    expect(find.text('Escribe tu correo y tu contraseña.'), findsOneWidget);
  });

  testWidgets('login correcto de un alumno lleva al menú', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository()));
    await _iniciarSesion(tester);
    expect(find.text('Menú de hoy'), findsOneWidget);
  });

  testWidgets('login de un encargado lleva a su panel', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    expect(find.text('Molletes'), findsOneWidget);
    await tester.tap(find.text('Estaciones'));
    await tester.pumpAndSettle();
    expect(find.text('Guisados'), findsOneWidget);
  });

  testWidgets('el menú del alumno sigue el orden de las estaciones',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(), ruta: Routes.menu));
    await tester.pumpAndSettle();
    final chips = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .map((c) => (c.label as Text).data)
        .toList();
    expect(chips, ['Todos', 'Tortas y hamburguesas', 'Guisados', 'Tiendita']);
  });

  testWidgets('el encargado da de alta un producto desde su panel',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.text('Producto'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Guardar'), 200,
        scrollable: find
            .ancestor(
                of: find.byType(TextField).first,
                matching: find.byType(Scrollable))
            .first);
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('El nombre es obligatorio.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Torta cubana');
    await tester.enterText(find.byType(TextField).at(2), '65');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guisados').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Guardar'), 200,
        scrollable: find
            .ancestor(
                of: find.byType(TextField).first,
                matching: find.byType(Scrollable))
            .first);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Torta cubana'), findsOneWidget);
  });

  testWidgets('el formulario de edición abre con los datos actuales',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.text('Molletes'));
    await tester.pumpAndSettle();
    expect(find.text('Editar producto'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Molletes'), findsOneWidget);
    expect(find.widgetWithText(TextField, '40.00'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(2), '42');
    await tester.scrollUntilVisible(find.text('Guardar'), 200,
        scrollable: find
            .ancestor(
                of: find.byType(TextField).first,
                matching: find.byType(Scrollable))
            .first);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('\$42.00'), findsOneWidget);
  });

  testWidgets('un producto agotado se ve gris y no se puede agregar',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(), ruta: Routes.menu));
    await tester.pumpAndSettle();
    final tile = tester.widget<ListTile>(find.ancestor(
        of: find.text('Café americano'), matching: find.byType(ListTile)));
    expect(tile.enabled, isFalse);
    final boton = tester.widget<IconButton>(find.descendant(
        of: find.ancestor(
            of: find.text('Café americano'), matching: find.byType(ListTile)),
        matching: find.byType(IconButton)));
    expect(boton.onPressed, isNull);
  });

  testWidgets('el interruptor de la lista cambia la disponibilidad',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    final fila = find.ancestor(
        of: find.text('Café americano'), matching: find.byType(ListTile));
    await tester.scrollUntilVisible(fila, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.descendant(of: fila, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    expect(find.descendant(of: fila, matching: find.text('Disponible')),
        findsOneWidget);
  });

  testWidgets('eliminar un producto pide confirmación', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.text('Molletes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Eliminar producto'));
    await tester.pumpAndSettle();
    expect(find.text('¿Eliminar "Molletes"?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Editar producto'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar producto'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('Molletes'), findsNothing);
  });

  testWidgets('sin foto se muestra la imagen genérica', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(), ruta: Routes.menu));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('foto-generica')), findsWidgets);
  });

  testWidgets('la edición ofrece cambiar la foto y el alta lo explica',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.text('Molletes'));
    await tester.pumpAndSettle();
    expect(find.text('Galería'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Producto'));
    await tester.pumpAndSettle();
    expect(find.text('Podrás agregar la foto después de guardar el producto.'),
        findsOneWidget);
  });
}
