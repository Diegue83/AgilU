import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/actualizacion.dart';

/// La descarga no coincide con la suma publicada: no se instala.
class ActualizacionInvalida implements Exception {
  final String mensaje;
  const ActualizacionInvalida(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Android todavía no deja que ÁgilU instale apps; se abrió el ajuste.
class FaltaPermisoInstalar implements Exception {
  const FaltaPermisoInstalar();
}

abstract class ActualizacionRepository {
  /// Versión instalada, o null si no se puede saber (fuera de Android).
  Future<VersionApp?> versionInstalada();

  /// Último release publicado, o null si no hay uno válido.
  Future<Actualizacion?> ultima();

  /// Descarga el APK, comprueba su SHA-256 y devuelve la ruta del archivo.
  Future<String> descargar(Actualizacion a, void Function(double) progreso);

  /// Abre el instalador de Android. Lanza [FaltaPermisoInstalar] si primero
  /// hay que permitir instalar apps desde ÁgilU.
  Future<void> instalar(String ruta);
}

/// Releases de GitHub del repositorio público. No lleva token: solo lee.
class GitHubActualizacionRepository implements ActualizacionRepository {
  final String repositorio;
  final http.Client _http;
  static const _canal = MethodChannel('agilu/actualizacion');

  GitHubActualizacionRepository(
      {required this.repositorio, http.Client? cliente})
      : _http = cliente ?? http.Client();

  static const _encabezados = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'AgilU-app',
  };

  @override
  Future<VersionApp?> versionInstalada() async {
    final v = await _canal.invokeMapMethod<String, dynamic>('version');
    return VersionApp.leer(v?['nombre'] as String?);
  }

  @override
  Future<Actualizacion?> ultima() async {
    final res = await _http.get(
        Uri.parse('https://api.github.com/repos/$repositorio/releases/latest'),
        headers: _encabezados);
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('GitHub respondió ${res.statusCode}.');
    }
    return Actualizacion.desdeRelease(
        jsonDecode(res.body) as Map<String, dynamic>,
        repositorio: repositorio);
  }

  @override
  Future<String> descargar(
      Actualizacion a, void Function(double) progreso) async {
    final shaRes = await _http.get(a.urlSha256, headers: _encabezados);
    final esperado =
        shaRes.statusCode == 200 ? Actualizacion.leerSha256(shaRes.body) : null;
    if (esperado == null) {
      throw const ActualizacionInvalida(
          'El release no trae una suma SHA-256 válida.');
    }

    final carpeta = await _canal.invokeMethod<String>('carpeta');
    final archivo = File('$carpeta/agilu-${a.version}.apk');
    final respuesta = await _http
        .send(http.Request('GET', a.urlApk)..headers.addAll(_encabezados));
    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo descargar (${respuesta.statusCode}).');
    }
    final total = respuesta.contentLength ?? a.tamano;
    var recibidos = 0;
    final salida = archivo.openWrite();
    final suma = _AcumuladorSha256();
    try {
      await for (final trozo in respuesta.stream) {
        recibidos += trozo.length;
        if (recibidos > Actualizacion.tamanoMaximo) {
          throw const ActualizacionInvalida('El archivo es demasiado grande.');
        }
        salida.add(trozo);
        suma.agregar(trozo);
        if (total > 0) progreso(recibidos / total);
      }
    } finally {
      await salida.close();
    }
    if (suma.terminar() != esperado) {
      await archivo.delete();
      throw const ActualizacionInvalida(
          'La descarga no coincide con la suma publicada; no se instaló.');
    }
    return archivo.path;
  }

  @override
  Future<void> instalar(String ruta) async {
    final puede = await _canal.invokeMethod<bool>('puedeInstalar') ?? false;
    if (!puede) {
      await _canal.invokeMethod<void>('permitirInstalar');
      throw const FaltaPermisoInstalar();
    }
    await _canal.invokeMethod<void>('instalar', {'ruta': ruta});
  }
}

class _AcumuladorSha256 {
  final _salida = _Salida();
  late final ByteConversionSink _entrada =
      sha256.startChunkedConversion(_salida);

  void agregar(List<int> bytes) => _entrada.add(bytes);

  String terminar() {
    _entrada.close();
    return _salida.valor.toString();
  }
}

class _Salida implements Sink<Digest> {
  late Digest valor;
  @override
  void add(Digest data) => valor = data;
  @override
  void close() {}
}

/// Para pruebas y para correr fuera de Android.
class MockActualizacionRepository implements ActualizacionRepository {
  VersionApp? instalada;
  Actualizacion? publicada;
  bool sumaCorrecta;
  bool permiso;
  final List<String> instaladas = [];

  MockActualizacionRepository({
    this.instalada = const VersionApp(1, 1, 0),
    this.publicada,
    this.sumaCorrecta = true,
    this.permiso = true,
  });

  @override
  Future<VersionApp?> versionInstalada() async => instalada;

  @override
  Future<Actualizacion?> ultima() async => publicada;

  @override
  Future<String> descargar(
      Actualizacion a, void Function(double) progreso) async {
    progreso(0.5);
    progreso(1);
    if (!sumaCorrecta) {
      throw const ActualizacionInvalida(
          'La descarga no coincide con la suma publicada; no se instaló.');
    }
    return '/cache/agilu-${a.version}.apk';
  }

  @override
  Future<void> instalar(String ruta) async {
    if (!permiso) {
      permiso = true;
      throw const FaltaPermisoInstalar();
    }
    instaladas.add(ruta);
  }
}
