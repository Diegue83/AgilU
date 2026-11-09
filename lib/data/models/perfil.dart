enum RolUsuario {
  alumno,
  encargado,
  beneficiaria;

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

  bool get esBeneficiaria => rol == RolUsuario.beneficiaria;
}
