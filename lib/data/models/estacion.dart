class Estacion {
  final String id;
  final String nombre;
  final int orden;
  final bool activo;
  final int productos;

  const Estacion({
    required this.id,
    required this.nombre,
    this.orden = 0,
    this.activo = true,
    this.productos = 0,
  });

  bool get sePuedeEliminar => productos == 0;

  Estacion copiar({String? nombre, int? orden, bool? activo}) => Estacion(
        id: id,
        nombre: nombre ?? this.nombre,
        orden: orden ?? this.orden,
        activo: activo ?? this.activo,
        productos: productos,
      );
}
