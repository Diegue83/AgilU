/// Devuelve el mensaje de un @check del servidor si viene en el error, o
/// [porDefecto]. Los @check de dataconnect/agilu traen mensajes para el usuario;
/// el resto de los errores son técnicos y no se muestran tal cual.
String mensajeDeError(Object error, String porDefecto, List<String> conocidos) {
  final texto = error.toString();
  for (final m in conocidos) {
    if (texto.contains(m)) return m;
  }
  return porDefecto;
}
