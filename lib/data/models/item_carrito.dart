import 'producto.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get precioUnitario => producto.precioEn(DateTime.now());

  double get subtotal => precioUnitario * cantidad;

  Map<String, dynamic> toMap() => {
        'productoId': producto.id,
        'nombre': producto.nombre,
        'precioUnitario': precioUnitario,
        'cantidad': cantidad,
      };
}
