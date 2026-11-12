import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';

import '../../core/conector.dart';
import '../../dataconnect_generated/agilu.dart';
import 'almacen_archivos.dart';

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

/// Sube la foto al bucket público "productos" de Supabase (carpeta del
/// encargado) y la liga al producto con GuardarFotoProducto, que comprueba en
/// el servidor que el producto sea de su cafetería.
class SupabaseFotoRepository implements FotoRepository {
  final AlmacenArchivos _almacen;
  final AgiluConnector _conector;
  final String? Function() _uid;

  SupabaseFotoRepository(this._almacen,
      {required String? Function() uid, AgiluConnector? conector})
      : _uid = uid,
        _conector = conector ?? conectorAgilu;

  @override
  Future<String> subir(String productoId, Uint8List bytes, String tipo) async {
    final problema = validarImagen(bytes, tipo);
    if (problema != null) throw Exception(problema);
    final uid = _uid();
    if (uid == null) throw Exception('Inicia sesión de nuevo.');
    final ruta = rutaArchivo(uid, productoId, tipo);
    try {
      await _almacen.subir('productos', ruta, bytes, tipo);
    } catch (_) {
      throw Exception('No se pudo guardar la foto.');
    }
    final url = _almacen.urlPublica('productos', ruta);
    try {
      await _conector.guardarFotoProducto(id: productoId, url: url).execute();
    } catch (e) {
      throw Exception(e.toString().contains('no es de tu cafetería')
          ? 'El producto no es de tu cafetería.'
          : 'No se pudo guardar la foto.');
    }
    return url;
  }
}

class MockFotoRepository implements FotoRepository {
  @override
  Future<String> subir(String productoId, Uint8List bytes, String tipo) async =>
      'https://ejemplo.test/productos/$productoId.jpg';
}
