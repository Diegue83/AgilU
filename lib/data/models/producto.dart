import '../../core/app_config.dart';

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final bool disponible;
  final String cafeteriaId;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    this.disponible = true,
    this.cafeteriaId = AppConfig.cafeteriaPorDefecto,
  });

  factory Producto.fromMap(Map<String, dynamic> map, String id) => Producto(
        id: id,
        nombre: (map['nombre'] ?? '') as String,
        descripcion: (map['descripcion'] ?? '') as String,
        precio: ((map['precio'] ?? 0) as num).toDouble(),
        categoria: (map['categoria'] ?? 'General') as String,
        disponible: (map['disponible'] ?? true) as bool,
        cafeteriaId:
            (map['cafeteriaId'] ?? AppConfig.cafeteriaPorDefecto) as String,
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria': categoria,
        'disponible': disponible,
        'cafeteriaId': cafeteriaId,
      };
}