/// Confianza del alumno de 0 a 100 (HU-23). Cada pedido sin recoger quita 20
/// puntos; se recuperan 5 por día cuando ya no se debe nada de ese pedido.
class Confianza {
  final int puntos;

  /// Pedidos sin recoger en los últimos 30 días.
  final int noRecogidos;

  /// Lo que debe de pedidos a pagar al recoger, desde que se piden hasta que
  /// se pagan.
  final double adeudo;

  /// Pedidos a pagar al recoger que siguen sin pagarse.
  final int creditosAbiertos;

  const Confianza({
    this.puntos = 100,
    this.noRecogidos = 0,
    this.adeudo = 0,
    this.creditosAbiertos = 0,
  });

  /// Con 100 puntos y sin otro pedido a pagar al recoger pendiente.
  bool get puedePagarAlRecoger => puntos >= 100 && creditosAbiertos == 0;

  /// Fila de SQL nativo de MiConfianza.
  factory Confianza.desdeMapa(Map? m) => Confianza(
        puntos: (m?['puntos'] as num?)?.toInt() ?? 100,
        noRecogidos: (m?['noRecogidos'] as num?)?.toInt() ?? 0,
        adeudo: (m?['adeudo'] as num?)?.toDouble() ?? 0,
        creditosAbiertos: (m?['creditosAbiertos'] as num?)?.toInt() ?? 0,
      );
}
