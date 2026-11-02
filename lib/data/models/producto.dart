import '../../core/app_config.dart';

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final bool disponible;
  final String cafeteriaId;
  final String estacionId;
  final String estacion;
  final int estacionOrden;
  final String? urlImagen;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    this.disponible = true,
    this.cafeteriaId = AppConfig.cafeteriaPorDefecto,
    this.estacionId = '',
    this.estacion = '',
    this.estacionOrden = 0,
    this.urlImagen,
  });

  /// Sección del menú: la estación si la hay, si no la categoría.
  String get seccion => estacion.isNotEmpty ? estacion : categoria;

  factory Producto.fromMap(Map<String, dynamic> map, String id) => Producto(
        id: id,
        nombre: (map['nombre'] ?? '') as String,
        descripcion: (map['descripcion'] ?? '') as String,
        precio: ((map['precio'] ?? 0) as num).toDouble(),
        categoria: (map['categoria'] ?? 'General') as String,
        disponible: (map['disponible'] ?? true) as bool,
        cafeteriaId:
            (map['cafeteriaId'] ?? AppConfig.cafeteriaPorDefecto) as String,
        estacionId: (map['estacionId'] ?? '') as String,
        estacion: (map['estacion'] ?? '') as String,
        estacionOrden: ((map['estacionOrden'] ?? 0) as num).toInt(),
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria': categoria,
        'disponible': disponible,
        'cafeteriaId': cafeteriaId,
        'estacionId': estacionId,
        'estacion': estacion,
        'estacionOrden': estacionOrden,
      };
}
