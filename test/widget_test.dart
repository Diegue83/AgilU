import 'package:agilu/app.dart';
import 'package:agilu/core/routes.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/estacion_repository.dart';
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
    expect(find.text('Menú'), findsOneWidget);
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
    expect(find.text('Menú'), findsOneWidget);
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
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('El nombre es obligatorio.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Torta cubana');
    await tester.enterText(find.byType(TextField).at(2), '65');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guisados').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Torta cubana'), findsOneWidget);
  });
}
