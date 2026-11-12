import '../../core/conector.dart';
import '../../core/reglas_pedido.dart';
import '../../dataconnect_generated/agilu.dart';

/// Un aviso guardado para el usuario (por ejemplo "tu pedido está listo").
class Aviso {
  final String id;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leido;
  final String? folio;

  const Aviso({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    this.leido = false,
    this.folio,
  });
}

/// Bandeja de avisos del usuario con sesión (los últimos 20).
abstract class BandejaRepository {
  Future<List<Aviso>> misAvisos();
  Future<void> marcarLeidos();
}

class DataConnectBandejaRepository implements BandejaRepository {
  final AgiluConnector _conector;
  DataConnectBandejaRepository({AgiluConnector? conector})
      : _conector = conector ?? conectorAgilu;

  @override
  Future<List<Aviso>> misAvisos() async {
    final res = await _conector.misNotificaciones().execute();
    return res.data.notificacions
        .map((n) => Aviso(
              id: n.id,
              titulo: n.titulo,
              mensaje: n.mensaje,
              fecha: n.fechaEnvio.toDateTime().toLocal(),
              leido: n.leido,
              folio: n.pedido == null
                  ? null
                  : ReglasPedido.formatearFolio(n.pedido!.folio),
            ))
        .toList();
  }

  @override
  Future<void> marcarLeidos() => _conector.marcarAvisosLeidos().execute();
}

class MockBandejaRepository implements BandejaRepository {
  final List<Aviso> avisos;
  MockBandejaRepository({List<Aviso>? avisos})
      : avisos = avisos ??
            [
              Aviso(
                id: 'a1',
                titulo: 'Tu pedido está listo',
                mensaje: 'Pasa a recoger tu pedido AGU-00012.',
                fecha: DateTime(2026, 11, 12, 13, 5),
                folio: 'AGU-00012',
              ),
              Aviso(
                id: 'a2',
                titulo: 'Pago validado',
                mensaje: 'Tu pago del pedido AGU-00011 fue aprobado.',
                fecha: DateTime(2026, 11, 11, 9, 30),
                leido: true,
                folio: 'AGU-00011',
              ),
            ];

  @override
  Future<List<Aviso>> misAvisos() async => List.of(avisos);

  @override
  Future<void> marcarLeidos() async {
    for (var i = 0; i < avisos.length; i++) {
      final a = avisos[i];
      avisos[i] = Aviso(
          id: a.id,
          titulo: a.titulo,
          mensaje: a.mensaje,
          fecha: a.fecha,
          leido: true,
          folio: a.folio);
    }
  }
}
