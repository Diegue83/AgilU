import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/producto.dart';
import 'menu_repository.dart';

/// Colección esperada en Firestore: `productos`
/// Campos: nombre, descripcion, precio, categoria, disponible.
class FirestoreMenuRepository implements MenuRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<Producto>> observarMenu() {
    return _db.collection('productos').snapshots().map(
          (snap) => snap.docs
              .map((d) => Producto.fromMap(d.data(), d.id))
              .toList(),
        );
  }
}
