import '../../core/permisos.dart';
import 'perfil.dart';

/// Una persona con rol distinto de alumno: empleado, encargado, administrador o
/// un rol creado por el administrador.
class MiembroPersonal {
  final String usuarioId;
  final String nombre;
  final String correo;
  final RolUsuario rol;
  final String? cafeteriaId;
  final String? cafeteria;

  /// Estación asignada a un empleado.
  final String? estacionId;
  final String? estacion;

  /// Nombre del rol en la base; para roles propios del administrador.
  final String? nombreRol;

  String get etiqueta => etiquetaRolNombre(nombreRol ?? rol.name);

  const MiembroPersonal({
    required this.usuarioId,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.cafeteriaId,
    this.cafeteria,
    this.estacionId,
    this.estacion,
    this.nombreRol,
  });

  /// Fila de SQL nativo (PersonalAdmin, MiPersonal).
  factory MiembroPersonal.desdeMapa(Map m) => MiembroPersonal(
        usuarioId: '${m['usuarioId']}',
        nombre: '${m['nombre'] ?? ''}',
        correo: '${m['correo'] ?? ''}',
        rol: RolUsuario.desdeNombre(m['rol'] as String?),
        nombreRol: m['rol'] as String?,
        cafeteriaId: m['cafeteriaId'] as String?,
        cafeteria: m['cafeteria'] as String?,
        estacionId: m['estacionId'] as String?,
        estacion: m['estacion'] as String?,
      );

  MiembroPersonal conEstacion(String? id, String? nombre) => MiembroPersonal(
        usuarioId: usuarioId,
        nombre: this.nombre,
        correo: correo,
        rol: rol,
        cafeteriaId: cafeteriaId,
        cafeteria: cafeteria,
        estacionId: id,
        estacion: nombre,
        nombreRol: nombreRol,
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

/// Nombre que se muestra para cada rol de sistema.
String etiquetaRol(RolUsuario rol) => etiquetaRolNombre(rol.name);

/// Alguien que se registró como empleado y espera la aprobación del encargado.
class SolicitudEmpleo {
  final String usuarioId;
  final String nombre;
  final String correo;
  final String? telefono;
  final DateTime fecha;

  const SolicitudEmpleo({
    required this.usuarioId,
    required this.nombre,
    required this.correo,
    this.telefono,
    required this.fecha,
  });
}
