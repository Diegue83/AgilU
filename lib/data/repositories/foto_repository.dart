import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';

abstract class FotoRepository {
  /// Sube la foto de un producto y devuelve la URL con la que se muestra.
  Future<String> subir(String productoId, Uint8List bytes, String tipo);
}

/// Usa la función subirFotoProducto (functions/index.js), que valida al
/// encargado antes de guardar la imagen.
class CloudFunctionsFotoRepository implements FotoRepository {
  final FirebaseFunctions _functions;
  CloudFunctionsFotoRepository({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-east4');

  @override
  Future<String> subir(String productoId, Uint8List bytes, String tipo) async {
    try {
      final res = await _functions.httpsCallable('subirFotoProducto').call({
        'productoId': productoId,
        'imagenBase64': base64Encode(bytes),
        'tipo': tipo,
      });
      return (res.data as Map)['url'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'No se pudo guardar la foto.');
    }
  }
}

class MockFotoRepository implements FotoRepository {
  @override
  Future<String> subir(String productoId, Uint8List bytes, String tipo) async =>
      'https://ejemplo.test/productos/$productoId.jpg';
}
