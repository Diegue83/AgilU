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
  final double? precioOferta;
  final DateTime? ofertaHasta;
  final bool esEspecialidad;
  final bool preparacionInmediata;

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
    this.precioOferta,
    this.ofertaHasta,
    this.esEspecialidad = false,
    this.preparacionInmediata = false,
  });

  /// HU-21: la oferta vale mientras no llegue su fecha de término.
  bool ofertaVigente(DateTime ahora) =>
      precioOferta != null &&
      ofertaHasta != null &&
      ahora.isBefore(ofertaHasta!);

  /// Precio que se cobra en este momento.
  double precioEn(DateTime ahora) =>
      ofertaVigente(ahora) ? precioOferta! : precio;

  bool destacadoEn(DateTime ahora) => ofertaVigente(ahora) || esEspecialidad;

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
