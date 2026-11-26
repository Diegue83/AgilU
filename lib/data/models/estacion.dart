class Estacion {
  final String id;
  final String nombre;
  final int orden;
  final bool activo;
  final int productos;

  /// Cuenta propia de la estación; vacía usa la de la cafetería.
  final String? banco;
  final String? clabe;
  final String? titular;

  bool get tieneCuenta => clabe != null && clabe!.isNotEmpty;

  const Estacion({
    required this.id,
    required this.nombre,
    this.orden = 0,
    this.activo = true,
    this.productos = 0,
    this.banco,
    this.clabe,
    this.titular,
  });

  bool get sePuedeEliminar => productos == 0;

  Estacion copiar({String? nombre, int? orden, bool? activo}) => Estacion(
        id: id,
        nombre: nombre ?? this.nombre,
        orden: orden ?? this.orden,
        activo: activo ?? this.activo,
        productos: productos,
        banco: banco,
        clabe: clabe,
        titular: titular,
      );
}
