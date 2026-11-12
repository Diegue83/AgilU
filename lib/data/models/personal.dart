import 'perfil.dart';

/// Una persona con rol distinto de alumno: empleado, encargado, beneficiaria o
/// administrador.
class MiembroPersonal {
  final String usuarioId;
  final String nombre;
  final String correo;
  final RolUsuario rol;
  final String? cafeteriaId;
  final String? cafeteria;

  const MiembroPersonal({
    required this.usuarioId,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.cafeteriaId,
    this.cafeteria,
  });

  /// Fila de SQL nativo (PersonalAdmin, MiPersonal).
  factory MiembroPersonal.desdeMapa(Map m) => MiembroPersonal(
        usuarioId: '${m['usuarioId']}',
        nombre: '${m['nombre'] ?? ''}',
        correo: '${m['correo'] ?? ''}',
        rol: RolUsuario.desdeNombre(m['rol'] as String?),
        cafeteriaId: m['cafeteriaId'] as String?,
        cafeteria: m['cafeteria'] as String?,
      );
}

class CafeteriaAdmin {
  final String id;
  final String nombre;
  final String? ubicacion;
  final bool activa;

  const CafeteriaAdmin({
    required this.id,
    required this.nombre,
    this.ubicacion,
    this.activa = true,
  });

  factory CafeteriaAdmin.desdeMapa(Map m) => CafeteriaAdmin(
        id: '${m['id']}',
        nombre: '${m['nombre'] ?? ''}',
        ubicacion: m['ubicacion'] as String?,
        activa: m['activa'] != false,
      );

  CafeteriaAdmin copiar({String? nombre, String? ubicacion, bool? activa}) =>
      CafeteriaAdmin(
        id: id,
        nombre: nombre ?? this.nombre,
        ubicacion: ubicacion ?? this.ubicacion,
        activa: activa ?? this.activa,
      );
}

/// Nombre que se muestra para cada rol.
String etiquetaRol(RolUsuario rol) => switch (rol) {
      RolUsuario.alumno => 'Alumno',
      RolUsuario.empleado => 'Empleado',
      RolUsuario.encargado => 'Encargado',
      RolUsuario.beneficiaria => 'Beneficiaria',
      RolUsuario.admin => 'Administrador',
    };
