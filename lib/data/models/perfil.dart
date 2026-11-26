import '../../core/permisos.dart';

/// Roles de sistema; [otro] es un rol creado por el administrador. Lo que cada
/// cuenta puede hacer lo dicen sus permisos, no el rol.
enum RolUsuario {
  alumno,
  empleado,
  encargado,
  admin,
  otro;

  static RolUsuario desdeNombre(String? nombre) {
    if (nombre == null || nombre.isEmpty) return RolUsuario.alumno;
    return RolUsuario.values
        .firstWhere((r) => r.name == nombre, orElse: () => RolUsuario.otro);
  }
}

class Perfil {
  final String nombre;
  final String correo;
  final String? telefono;
  final RolUsuario rol;

  /// Cafetería que administra un encargado; null para alumnos.
  final String? cafeteriaId;
  final String? cafeteria;

  const Perfil({
    required this.nombre,
    required this.correo,
    this.telefono,
    this.rol = RolUsuario.alumno,
    this.cafeteriaId,
    this.cafeteria,
    this.solicitudCafeteria,
    this.estacionId,
    this.estacion,
    this.nombreRol,
    Set<String>? permisos,
    this.avisos = const PreferenciasAvisos(),
  }) : _permisos = permisos;

  /// Qué notificaciones push recibe.
  final PreferenciasAvisos avisos;

  /// Nombre del rol tal como está en la base (incluye roles propios).
  final String? nombreRol;

  final Set<String>? _permisos;

  /// Permisos del rol. Si el perfil no los trae (datos de prueba), se usan los
  /// iniciales del rol de sistema.
  Set<String> get permisos =>
      _permisos ?? Permisos.porDefecto(nombreRol ?? rol.name);

  bool puede(String permiso) => permisos.contains(permiso);

  /// Estación que el encargado le asignó a un empleado.
  final String? estacionId;
  final String? estacion;

  /// Empleado con estación: puede activarla y manejar sus productos.
  bool get tieneEstacion =>
      cafeteriaId != null &&
      puede(Permisos.estacionPropia) &&
      estacionId != null;

  /// Cafetería a la que pidió entrar como empleado, mientras el encargado no
  /// apruebe o rechace la solicitud.
  final String? solicitudCafeteria;

  /// Se registró como empleado y espera la aprobación del encargado.
  bool get esperandoAprobacion =>
      rol == RolUsuario.alumno && solicitudCafeteria != null;

  /// Administra el personal de su cafetería.
  bool get esEncargado =>
      cafeteriaId != null && puede(Permisos.personalGestionar);

  /// Atiende pedidos de su cafetería, sin acceso a pagos, precios ni ajustes.
  bool get esEmpleado => rol == RolUsuario.empleado && cafeteriaId != null;

  /// Tiene algún permiso de cafetería y una cafetería asignada: entra al
  /// panel del personal.
  bool get esPersonal =>
      cafeteriaId != null && permisos.any(Permisos.deCafeteria.contains);

  bool get esAdmin => puede(Permisos.adminGestionar);

  String get etiquetaRol => etiquetaRolNombre(nombreRol ?? rol.name);
}

/// Lo que el alumno captura en el primer paso del registro.
class DatosPersonales {
  final String nombre;
  final String apellidos;
  final String? telefono;

  /// Si se registra como empleado: id de la cafetería donde trabaja.
  final String? cafeteriaSolicitada;

  const DatosPersonales({
    required this.nombre,
    required this.apellidos,
    this.telefono,
    this.cafeteriaSolicitada,
  });

  String get nombreCompleto => '${nombre.trim()} ${apellidos.trim()}'.trim();
}

/// Cafetería que se puede elegir al registrarse como empleado.
class OpcionCafeteria {
  final String id;
  final String nombre;
  final String? ubicacion;
  const OpcionCafeteria(this.id, this.nombre, {this.ubicacion});

  String get etiqueta => ubicacion == null ? nombre : '$nombre ($ubicacion)';
}

/// Notificaciones push que quiere recibir la persona. La bandeja de avisos
/// las guarda todas aunque se apaguen.
class PreferenciasAvisos {
  final bool pedidoListo;
  final bool pagos;
  final bool personal;
  const PreferenciasAvisos(
      {this.pedidoListo = true, this.pagos = true, this.personal = true});

  PreferenciasAvisos copiar({bool? pedidoListo, bool? pagos, bool? personal}) =>
      PreferenciasAvisos(
        pedidoListo: pedidoListo ?? this.pedidoListo,
        pagos: pagos ?? this.pagos,
        personal: personal ?? this.personal,
      );
}
