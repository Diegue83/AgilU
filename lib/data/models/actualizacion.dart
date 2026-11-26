/// Versión de la app en formato mayor.menor.parche (la etiqueta del release es
/// "v1.2.0"; el número de compilación no cuenta).
class VersionApp implements Comparable<VersionApp> {
  final int mayor;
  final int menor;
  final int parche;
  const VersionApp(this.mayor, this.menor, this.parche);

  static final _formato = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:[+-].*)?$');

  /// null si el texto no es una versión válida.
  static VersionApp? leer(String? texto) {
    final m = _formato.firstMatch(texto?.trim() ?? '');
    if (m == null) return null;
    return VersionApp(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }

  @override
  int compareTo(VersionApp other) => mayor != other.mayor
      ? mayor.compareTo(other.mayor)
      : menor != other.menor
          ? menor.compareTo(other.menor)
          : parche.compareTo(other.parche);

  bool esMayorQue(VersionApp o) => compareTo(o) > 0;

  @override
  bool operator ==(Object other) =>
      other is VersionApp && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(mayor, menor, parche);

  @override
  String toString() => '$mayor.$menor.$parche';
}

/// Una versión publicada en los releases de GitHub con su APK y la suma
/// SHA-256 del APK (archivo .apk.sha256 en el mismo release).
class Actualizacion {
  final VersionApp version;
  final String notas;
  final Uri urlApk;
  final Uri urlSha256;
  final int tamano;

  const Actualizacion({
    required this.version,
    required this.notas,
    required this.urlApk,
    required this.urlSha256,
    this.tamano = 0,
  });

  /// Tamaño máximo que se acepta descargar.
  static const tamanoMaximo = 200 * 1024 * 1024;

  /// Lee la respuesta de /releases/latest. Devuelve null si no es un release
  /// publicado con versión válida, APK y su .sha256, o si las ligas no son
  /// descargas de ese mismo repositorio.
  static Actualizacion? desdeRelease(Map<String, dynamic> json,
      {required String repositorio}) {
    if (json['draft'] == true || json['prerelease'] == true) return null;
    final version = VersionApp.leer(json['tag_name'] as String?);
    if (version == null) return null;
    final prefijo = 'https://github.com/$repositorio/releases/download/';
    final archivos = [
      for (final a in (json['assets'] as List? ?? const []))
        if (a is Map &&
            a['name'] is String &&
            a['browser_download_url'] is String &&
            (a['browser_download_url'] as String).startsWith(prefijo))
          a,
    ];
    final apk = archivos
        .where((a) => (a['name'] as String).toLowerCase().endsWith('.apk'))
        .firstOrNull;
    if (apk == null) return null;
    final sha =
        archivos.where((a) => a['name'] == '${apk['name']}.sha256').firstOrNull;
    if (sha == null) return null;
    final tamano = (apk['size'] as num?)?.toInt() ?? 0;
    if (tamano > tamanoMaximo) return null;
    return Actualizacion(
      version: version,
      notas: (json['body'] as String? ?? '').trim(),
      urlApk: Uri.parse(apk['browser_download_url'] as String),
      urlSha256: Uri.parse(sha['browser_download_url'] as String),
      tamano: tamano,
    );
  }

  /// Saca la suma de un archivo .sha256 ("<64 hex>  nombre.apk").
  static String? leerSha256(String texto) =>
      RegExp(r'\b[0-9a-fA-F]{64}\b').firstMatch(texto)?.group(0)?.toLowerCase();
}
