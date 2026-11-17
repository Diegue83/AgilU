enum RolUsuario {
  alumno,
  empleado,
  encargado,
  beneficiaria,
  admin;

  static RolUsuario desdeNombre(String? nombre) => RolUsuario.values.firstWhere(
        (r) => r.name == nombre,
        orElse: () => RolUsuario.alumno,
      );
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
  });

  /// Cafetería a la que pidió entrar como empleado, mientras el encargado no
  /// apruebe o rechace la solicitud.
  final String? solicitudCafeteria;

  /// Se registró como empleado y espera la aprobación del encargado.
  bool get esperandoAprobacion =>
      rol == RolUsuario.alumno && solicitudCafeteria != null;

  bool get esEncargado => rol == RolUsuario.encargado && cafeteriaId != null;

  /// Atiende pedidos de su cafetería, sin acceso a pagos, precios ni ajustes.
  bool get esEmpleado => rol == RolUsuario.empleado && cafeteriaId != null;

  /// Encargado o empleado: entra al panel de la cafetería.
  bool get esPersonal => esEncargado || esEmpleado;

  bool get esAdmin => rol == RolUsuario.admin;

  bool get esBeneficiaria => rol == RolUsuario.beneficiaria;
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
