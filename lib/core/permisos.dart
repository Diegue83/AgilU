/// Catálogo fijo de permisos (Permiso.codigoAccion). El servidor revisa cada
/// código en sus operaciones; la app solo decide qué pantallas mostrar.
class Permisos {
  Permisos._();

  static const pedidosAtender = 'pedidos.atender';
  static const pagosValidar = 'pagos.validar';
  static const catalogoGestionar = 'catalogo.gestionar';
  static const estacionPropia = 'estacion.propia';
  static const personalGestionar = 'personal.gestionar';
  static const cafeteriaConfigurar = 'cafeteria.configurar';
  static const reporteVer = 'reporte.ver';
  static const adminGestionar = 'admin.gestionar';

  /// Nombre de cada permiso, en el orden en que se muestran.
  static const nombres = <String, String>{
    pedidosAtender: 'Atender pedidos (panel y entrega)',
    pagosValidar: 'Validar pagos y cobrar adeudos',
    catalogoGestionar: 'Administrar estaciones, productos y ofertas',
    estacionPropia: 'Manejar su estación asignada y sus productos',
    personalGestionar: 'Administrar el personal y las solicitudes',
    cafeteriaConfigurar: 'Configurar horario y cobro de la cafetería',
    reporteVer: 'Ver el reporte de la cafetería',
    adminGestionar: 'Administrar cafeterías, roles y permisos',
  };

  /// Permisos que trabajan sobre una cafetería: quien tiene alguno necesita
  /// una cafetería asignada y entra al panel del personal.
  static const deCafeteria = {
    pedidosAtender,
    pagosValidar,
    catalogoGestionar,
    estacionPropia,
    personalGestionar,
    cafeteriaConfigurar,
    reporteVer,
  };

  /// Roles que no se pueden borrar.
  static const rolesDeSistema = {'alumno', 'empleado', 'encargado', 'admin'};

  /// Permisos iniciales de los roles de sistema (dataconnect/permisos.gql).
  /// Se usan cuando el perfil no trae permisos, como en los datos de prueba.
  static Set<String> porDefecto(String? rol) => switch (rol) {
        'encargado' => const {
            pedidosAtender,
            pagosValidar,
            catalogoGestionar,
            personalGestionar,
            cafeteriaConfigurar,
            reporteVer,
          },
        'empleado' => const {pedidosAtender, estacionPropia},
        'admin' => const {adminGestionar},
        _ => const {},
      };

  /// Si el permiso se puede cambiar en ese rol: el alumno no lleva permisos y
  /// el administrador no pierde el suyo.
  static bool sePuedeCambiar(String rol, String codigo) =>
      rol != 'alumno' && !(rol == 'admin' && codigo == adminGestionar);
}

/// Nombre para mostrar de un rol: los de sistema en español, los demás con
/// mayúscula inicial y espacios en lugar de guiones bajos.
String etiquetaRolNombre(String? nombre) => switch (nombre) {
      null || 'alumno' => 'Alumno',
      'empleado' => 'Empleado',
      'encargado' => 'Encargado',
      'admin' => 'Administrador',
      _ => nombre.isEmpty
          ? 'Alumno'
          : nombre[0].toUpperCase() + nombre.substring(1).replaceAll('_', ' '),
    };
