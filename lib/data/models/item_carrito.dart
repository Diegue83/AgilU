import 'producto.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;

  Map<String, dynamic> toMap() => {
        'productoId': producto.id,
        'nombre': producto.nombre,
        'precioUnitario': producto.precio,
        'cantidad': cantidad,
      };
}