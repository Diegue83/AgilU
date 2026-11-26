import '../../core/permisos.dart';

/// Rol con sus permisos, como lo ve el administrador.
class RolAdmin {
  final String id;
  final String nombre;
  final String? descripcion;
  final Set<String> permisos;

  /// Cuántas cuentas tienen este rol.
  final int usuarios;

  const RolAdmin({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.permisos = const {},
    this.usuarios = 0,
  });

  bool get esDeSistema => Permisos.rolesDeSistema.contains(nombre);

  /// Con algún permiso de cafetería, asignarlo exige elegir cafetería.
  bool get requiereCafeteria => permisos.any(Permisos.deCafeteria.contains);

  /// Solo los roles propios que nadie tiene se pueden borrar.
  bool get sePuedeEliminar => !esDeSistema && usuarios == 0;

  String get etiqueta => etiquetaRolNombre(nombre);

  /// Fila de SQL nativo de RolesAdmin.
  factory RolAdmin.desdeMapa(Map m) => RolAdmin(
        id: '${m['id']}',
        nombre: '${m['nombre'] ?? ''}',
        descripcion: m['descripcion'] as String?,
        permisos: {
          for (final p in (m['permisos'] as List?) ?? const []) '$p',
        },
        usuarios: (m['usuarios'] as num?)?.toInt() ?? 0,
      );

  RolAdmin copiar(
          {String? descripcion, Set<String>? permisos, int? usuarios}) =>
      RolAdmin(
        id: id,
        nombre: nombre,
        descripcion: descripcion ?? this.descripcion,
        permisos: permisos ?? this.permisos,
        usuarios: usuarios ?? this.usuarios,
      );
}

/// Permiso del catálogo.
class PermisoDisponible {
  final String codigo;
  final String nombre;
  const PermisoDisponible(this.codigo, this.nombre);
}
