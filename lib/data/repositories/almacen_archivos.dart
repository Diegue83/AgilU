import 'dart:math';
import 'dart:typed_data';

import 'package:storage_client/storage_client.dart';

/// Archivos de la app (comprobantes y fotos de productos) en Supabase Storage.
/// Cada petición lleva el token de Firebase del usuario con sesión; las
/// políticas de supabase/almacenamiento.sql deciden qué puede hacer.
abstract class AlmacenArchivos {
  Future<void> subir(String bucket, String ruta, Uint8List datos, String tipo);
  Future<Uint8List> descargar(String bucket, String ruta);
  String urlPublica(String bucket, String ruta);
}

const tiposPermitidos = {'image/jpeg': 'jpg', 'image/png': 'png'};
const tamanoMaximo = 1024 * 1024;

/// Problema con el archivo antes de subirlo, o null si se puede subir.
String? validarImagen(Uint8List datos, String tipo) {
  if (!tiposPermitidos.containsKey(tipo)) return 'La foto debe ser JPG o PNG.';
  if (datos.isEmpty) return 'No se recibió la foto.';
  if (datos.length > tamanoMaximo) return 'La foto pesa más de 1 MB.';
  return null;
}

/// Ruta dentro del bucket: <uid>/<id>-<aleatorio>.<ext>. La carpeta del
/// usuario la exige la política de subida; la parte aleatoria hace que la
/// ruta de un comprobante no se pueda adivinar.
String rutaArchivo(String uid, String id, String tipo, {Random? azar}) {
  final r = azar ?? Random.secure();
  final aleatorio = List.generate(16, (_) => r.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return '$uid/$id-$aleatorio.${tiposPermitidos[tipo]}';
}

class SupabaseAlmacen implements AlmacenArchivos {
  final String _url;
  final String _llave;

  /// Token de Firebase del usuario con sesión.
  final Future<String?> Function() _token;

  SupabaseAlmacen({
    required String url,
    required String llave,
    required Future<String?> Function() token,
  })  : _url = url.endsWith('/') ? url.substring(0, url.length - 1) : url,
        _llave = llave,
        _token = token;

  Future<SupabaseStorageClient> _cliente() async {
    final token = await _token();
    if (token == null) throw Exception('Inicia sesión de nuevo.');
    return SupabaseStorageClient('$_url/storage/v1', {
      'apikey': _llave,
      'Authorization': 'Bearer $token',
    });
  }

  @override
  Future<void> subir(
      String bucket, String ruta, Uint8List datos, String tipo) async {
    final cliente = await _cliente();
    await cliente.from(bucket).uploadBinary(ruta, datos,
        fileOptions: FileOptions(contentType: tipo, upsert: false));
  }

  @override
  Future<Uint8List> descargar(String bucket, String ruta) async =>
      (await _cliente()).from(bucket).download(ruta);

  @override
  String urlPublica(String bucket, String ruta) =>
      '$_url/storage/v1/object/public/$bucket/$ruta';
}

/// Almacén en memoria para pruebas y para correr la app sin Supabase.
class MockAlmacen implements AlmacenArchivos {
  final Map<String, Uint8List> archivos = {};

  @override
  Future<void> subir(
      String bucket, String ruta, Uint8List datos, String tipo) async {
    archivos['$bucket/$ruta'] = datos;
  }

  @override
  Future<Uint8List> descargar(String bucket, String ruta) async {
    final a = archivos['$bucket/$ruta'];
    if (a == null) throw Exception('No existe el archivo.');
    return a;
  }

  @override
  String urlPublica(String bucket, String ruta) =>
      'https://ejemplo.supabase.co/storage/v1/object/public/$bucket/$ruta';
}
