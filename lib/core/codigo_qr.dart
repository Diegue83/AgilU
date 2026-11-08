/// Contenido del QR de entrega (HU-12): el pedido y su código de 4 dígitos.
/// El servidor sigue siendo quien decide si se entrega (EntregarPedido).
class CodigoQr {
  static const _prefijo = 'agilu-entrega';

  final String pedidoId;
  final String codigo;
  const CodigoQr(this.pedidoId, this.codigo);

  String get texto => '$_prefijo:$pedidoId:$codigo';

  /// Devuelve null si el texto no es un QR de entrega de ÁgilU.
  static CodigoQr? leer(String texto) {
    final partes = texto.trim().split(':');
    if (partes.length != 3 || partes[0] != _prefijo) return null;
    final id = partes[1];
    final codigo = partes[2];
    if (!RegExp(r'^[0-9a-fA-F-]{32,36}$').hasMatch(id)) return null;
    if (!RegExp(r'^\d{4}$').hasMatch(codigo)) return null;
    return CodigoQr(id, codigo);
  }

  /// Los ids llegan del servidor sin guiones; se comparan sin ellos.
  static String normalizarId(String id) => id.replaceAll('-', '').toLowerCase();
}
