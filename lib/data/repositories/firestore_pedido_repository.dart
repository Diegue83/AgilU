import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/reglas_pedido.dart';
import '../models/pedido.dart';
import 'pedido_repository.dart';

class FirestorePedidoRepository implements PedidoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<String> crearPedido(Pedido pedido) async {
    final contador = _db.collection('contadores').doc('folio');
    final nuevo = _db.collection('pedidos').doc();

    return _db.runTransaction<String>((tx) async {
      final snap = await tx.get(contador);
      final actual = snap.exists ? (snap.data()!['valor'] as num).toInt() : 0;
      final siguiente = actual + 1;
      final folio = ReglasPedido.formatearFolio(siguiente);

      tx.set(contador, {'valor': siguiente});
      tx.set(nuevo, {
        ...pedido.toMap(),
        'folio': folio,
        'recogerA': Timestamp.fromDate(pedido.recogerA),
        'creadoEn': FieldValue.serverTimestamp(),
      });
      return folio;
    });
  }
}