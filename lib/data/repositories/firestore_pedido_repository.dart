import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pedido.dart';
import 'pedido_repository.dart';

/// Guarda los pedidos en la colección `pedidos`.
class FirestorePedidoRepository implements PedidoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<String> crearPedido(Pedido pedido) async {
    final ref = await _db.collection('pedidos').add(pedido.toMap());
    return 'AGU-${ref.id.substring(0, 5).toUpperCase()}';
  }
}
