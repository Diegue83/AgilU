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
  final RolUsuario rol;

  /// Cafetería que administra un encargado; null para alumnos.
  final String? cafeteriaId;
  final String? cafeteria;

  const Perfil({
    required this.nombre,
    required this.correo,
    this.rol = RolUsuario.alumno,
    this.cafeteriaId,
    this.cafeteria,
  });

  bool get esEncargado => rol == RolUsuario.encargado && cafeteriaId != null;

  /// Atiende pedidos de su cafetería, sin acceso a pagos, precios ni ajustes.
  bool get esEmpleado => rol == RolUsuario.empleado && cafeteriaId != null;

  /// Encargado o empleado: entra al panel de la cafetería.
  bool get esPersonal => esEncargado || esEmpleado;

  bool get esAdmin => rol == RolUsuario.admin;

  bool get esBeneficiaria => rol == RolUsuario.beneficiaria;
}
