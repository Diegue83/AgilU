import 'package:agilu/app.dart';
import 'package:agilu/core/routes.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/avisos_repository.dart';
import 'package:agilu/data/repositories/bandeja_repository.dart';
import 'package:agilu/data/repositories/cafeteria_repository.dart';
import 'package:agilu/data/repositories/contadores_repository.dart';
import 'package:agilu/data/repositories/estacion_repository.dart';
import 'package:agilu/data/repositories/foto_repository.dart';
import 'package:agilu/data/repositories/historial_repository.dart';
import 'package:agilu/data/repositories/menu_repository.dart';
import 'package:agilu/data/repositories/notificador.dart';
import 'package:agilu/data/repositories/pagos_repository.dart';
import 'package:agilu/data/repositories/panel_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/data/repositories/personal_repository.dart';
import 'package:agilu/data/repositories/producto_repository.dart';
import 'package:agilu/data/repositories/reporte_repository.dart';
import 'package:agilu/ui/cart/cart_view_model.dart';
import 'package:agilu/ui/comun/contadores.dart';
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
        {String ruta = Routes.login,
        PerfilRepository? perfiles,
        ContadoresRepository? contadores}) =>
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: auth),
        Provider<AvisosRepository>(create: (_) => MockAvisosRepository()),
        Provider<ReporteRepository>(create: (_) => MockReporteRepository()),
        Provider<PerfilRepository>.value(
            value: perfiles ?? MockPerfilRepository()),
        Provider<HistorialRepository>(create: (_) => MockHistorialRepository()),
        Provider<BandejaRepository>(create: (_) => MockBandejaRepository()),
        Provider<PersonalRepository>(create: (_) => MockPersonalRepository()),
        Provider<AdminRepository>(create: (_) => MockAdminRepository()),
        Provider<EstacionRepository>(create: (_) => MockEstacionRepository()),
        Provider<ProductoRepository>(create: (_) => MockProductoRepository()),
        Provider<FotoRepository>(create: (_) => MockFotoRepository()),
        Provider<CafeteriaRepository>(create: (_) => MockCafeteriaRepository()),
        Provider<PanelRepository>(create: (_) => MockPanelRepository()),
        Provider<PagosRepository>(create: (_) => MockPagosRepository()),
        Provider<MenuRepository>(create: (_) => MockMenuRepository()),
        Provider<PedidoRepository>(create: (_) => MockPedidoRepository()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        Provider<Notificador>(create: (_) => MockNotificador()),
        ChangeNotifierProvider(
            create: (_) =>
                ContadoresController(contadores ?? MockContadoresRepository())),
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
    expect(find.text('En espera (1)'), findsOneWidget);
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Producto'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Guardar'), 200,
        scrollable: find
            .ancestor(
                of: find.byType(TextField).first,
                matching: find.byType(Scrollable))
            .first);
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    await tester.drag(find.byType(ListView).last, const Offset(0, 2000));
    await tester.pumpAndSettle();
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
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Torta cubana'), findsOneWidget);
  });

  testWidgets('el formulario de edición abre con los datos actuales',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
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
    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
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

  testWidgets('el encargado ve los ajustes de su cafetería', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.text('Cafetería'));
    await tester.pumpAndSettle();
    expect(find.text('Pedidos por horario'), findsOneWidget);
    expect(find.text('07:30'), findsOneWidget);
  });

  testWidgets('el panel avanza un pedido de en espera a preparando',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    expect(find.text('AGU-00012'), findsOneWidget);
    await tester.tap(find.text('Empezar a preparar'));
    await tester.pumpAndSettle();
    expect(find.text('En espera (0)'), findsOneWidget);
    expect(find.text('Preparando (2)'), findsOneWidget);
  });

  testWidgets('el encargado entrega un pedido listo con el código del alumno',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.scrollUntilVisible(find.text('Entregar con código'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.dragUntilVisible(find.text('Entregar con código'),
        find.byType(Scrollable).first, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entregar con código'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0000');
    await tester.tap(find.widgetWithText(FilledButton, 'Entregar'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.textContaining('Código incorrecto'), findsOneWidget);

    await tester.dragUntilVisible(find.text('Entregar con código'),
        find.byType(Scrollable).first, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entregar con código'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '4821');
    await tester.tap(find.widgetWithText(FilledButton, 'Entregar'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text('Pedido AGU-00014 entregado.'), findsOneWidget);
  });

  testWidgets('el encargado aprueba un comprobante desde la pestaña Pagos',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.text('Pagos'));
    await tester.pumpAndSettle();
    expect(find.text('AGU-00009 · Ana'), findsOneWidget);
    await tester.tap(find.text('Aprobar'));
    await tester.pumpAndSettle();
    expect(find.text('No hay comprobantes por validar.'), findsOneWidget);
  });

  testWidgets('al iniciar sesión registra el dispositivo para avisos',
      (tester) async {
    final avisos = MockAvisosRepository();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: MockAuthRepository()),
        Provider<AvisosRepository>.value(value: avisos),
        Provider<BandejaRepository>(create: (_) => MockBandejaRepository()),
        Provider<PerfilRepository>.value(value: MockPerfilRepository()),
        Provider<MenuRepository>(create: (_) => MockMenuRepository()),
        Provider<PedidoRepository>(create: (_) => MockPedidoRepository()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        Provider<Notificador>(create: (_) => MockNotificador()),
        ChangeNotifierProvider(
            create: (_) => ContadoresController(MockContadoresRepository())),
      ],
      child: const AgilUApp(),
    ));
    await _iniciarSesion(tester);
    expect(avisos.registrado, isTrue);
  });

  testWidgets('la beneficiaria entra directo a su reporte', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(
            perfil: const Perfil(
                nombre: 'Elena',
                correo: 'elena@utng.edu.mx',
                rol: RolUsuario.beneficiaria))));
    await _iniciarSesion(tester);
    expect(find.text('Reporte'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Cafetería central'), findsOneWidget);
    await tester.tap(find.text('Hoy'));
    await tester.pumpAndSettle();
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets(
      'al cerrar sesión e iniciar con otra cuenta no queda la pantalla anterior',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository()));
    await _iniciarSesion(tester);
    expect(find.text('Menú de hoy'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await _iniciarSesion(tester);
    expect(find.text('Menú de hoy'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('un empleado solo ve el panel de pedidos', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(
            perfil: const Perfil(
                nombre: 'Luis',
                correo: 'luis@utng.edu.mx',
                rol: RolUsuario.empleado,
                cafeteriaId: 'c1'))));
    await _iniciarSesion(tester);
    expect(find.text('En espera (1)'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Pagos'), findsNothing);
    expect(find.text('Productos'), findsNothing);
    expect(find.text('Personal'), findsNothing);
  });

  testWidgets('el encargado da de alta a un empleado con su correo',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    expect(find.text('Luis'), findsOneWidget);

    await tester.tap(find.text('Empleado'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Correo de la cuenta'),
        'nuevo@utng.edu.mx');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(find.text('Empleado · nuevo@utng.edu.mx'), findsOneWidget);
  });

  testWidgets('el administrador entra a cafeterías y crea una', (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(
            perfil: const Perfil(
                nombre: 'Admin',
                correo: 'admin@utng.edu.mx',
                rol: RolUsuario.admin))));
    await _iniciarSesion(tester);
    expect(find.text('Cafetería central'), findsOneWidget);
    expect(find.text('Menú de hoy'), findsNothing);

    await tester.tap(find.text('Cafetería'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Nombre'), 'Barra de café');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Barra de café'), findsOneWidget);

    await tester.tap(find.text('Personal').last);
    await tester.pumpAndSettle();
    expect(find.text('Nadie tiene un rol todavía.'), findsOneWidget);
  });

  testWidgets('el registro va por pasos y termina en el menú del alumno',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final auth = MockAuthRepository();
    await tester.pumpWidget(_app(auth));
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    expect(find.text('Datos personales'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.pump();
    expect(find.text('Escribe tu nombre.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Nombre(s)'), 'Ana');
    await tester.enterText(
        find.widgetWithText(TextField, 'Apellidos'), 'López');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Correo institucional'),
        'ana@utng.edu.mx');
    await tester.enterText(
        find.widgetWithText(TextField, 'Contraseña'), '123456');
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirma la contraseña'), '654321');
    await tester
        .ensureVisible(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pump();
    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Confirma la contraseña'), '123456');
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Menú de hoy'), findsOneWidget);
    expect(auth.registrado?.nombreCompleto, 'Ana López');
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('el alumno ve su perfil y su nivel de confianza en Mi cuenta',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(MockAuthRepository(), ruta: Routes.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mi cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Mi cuenta'), findsOneWidget);
    expect(find.text('Alumno demo'), findsWidgets);
    expect(find.text('Nivel de confianza'), findsOneWidget);
    expect(find.text('Excelente'), findsOneWidget);
    expect(find.text('Eliminar mi cuenta'), findsOneWidget);

    await tester.tap(find.text('Editar datos'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Teléfono (opcional)'), '4181234567');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('4181234567'), findsOneWidget);
  });

  testWidgets('el encargado no ve confianza ni la opción de eliminar',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        ruta: Routes.cuenta,
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await tester.pumpAndSettle();
    expect(find.text('Encargado · Central'), findsOneWidget);
    expect(find.text('Nivel de confianza'), findsNothing);
    expect(find.text('Eliminar mi cuenta'), findsNothing);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
  });

  testWidgets('la campana muestra los avisos sin leer y los marca al abrir',
      (tester) async {
    final contadores =
        MockContadoresRepository(contadores: const Contadores(avisos: 1));
    await tester.pumpWidget(
        _app(MockAuthRepository(), ruta: Routes.menu, contadores: contadores));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byTooltip('Avisos'));
    await tester.pumpAndSettle();
    expect(find.text('Tu pedido está listo'), findsOneWidget);
    expect(find.text('Pago validado'), findsOneWidget);
    // Al abrir la bandeja los avisos quedan leídos en el servidor.
    contadores.contadores = Contadores.ceros;
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsNothing);
  });

  testWidgets('el encargado consulta el historial de pedidos terminados',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado)));
    await _iniciarSesion(tester);
    await tester.tap(find.byTooltip('Historial'));
    await tester.pumpAndSettle();
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Entregados'), findsOneWidget);
    expect(find.textContaining('AGU-00007'), findsOneWidget);
    await tester.tap(find.text('30 días'));
    await tester.pumpAndSettle();
    expect(find.textContaining('AGU-00002'), findsOneWidget);
  });

  testWidgets('Solicitar trabajo abre el registro de empleado con cafetería',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(MockAuthRepository()));
    await tester
        .tap(find.text('¿Trabajas en una cafetería? Solicitar trabajo'));
    await tester.pumpAndSettle();
    expect(find.text('Solicitar trabajo'), findsOneWidget);
    expect(find.text('Cafetería donde trabajas'), findsOneWidget);
  });

  testWidgets('el panel marca con punto rojo pedidos, pagos y solicitudes',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        perfiles: MockPerfilRepository(perfil: _encargado),
        contadores: MockContadoresRepository(
            contadores:
                const Contadores(enEspera: 2, pagos: 3, solicitudes: 1))));
    await _iniciarSesion(tester);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('el alumno ve punto rojo en Mis pedidos y en la campana',
      (tester) async {
    await tester.pumpWidget(_app(MockAuthRepository(),
        ruta: Routes.menu,
        contadores: MockContadoresRepository(
            contadores: const Contadores(listos: 1, avisos: 4))));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byTooltip('Mis pedidos'), matching: find.text('1')),
        findsOneWidget);
  });
}
