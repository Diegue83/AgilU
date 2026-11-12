import 'dart:convert';

import 'package:http/http.dart' as http;

/// Eventos que generan un aviso (bandeja y push) en la Edge Function "avisar"
/// de Supabase. Ver supabase/functions/avisar.
enum EventoAviso {
  comprobante('comprobante'),
  pagoValidado('pago_validado'),
  pagoRechazado('pago_rechazado'),
  pedidoListo('pedido_listo'),
  solicitud('solicitud');

  final String clave;
  const EventoAviso(this.clave);
}

/// Pide a la función que avise a quien corresponda. Nunca falla hacia la
/// pantalla: si el aviso no sale, la acción del usuario ya quedó guardada.
abstract class Notificador {
  Future<void> avisar(EventoAviso evento, {String? pedidoId});
}

class SupabaseNotificador implements Notificador {
  final String _url;
  final String _llave;
  final Future<String?> Function() _token;
  final http.Client _http;

  SupabaseNotificador({
    required String url,
    required String llave,
    required Future<String?> Function() token,
    http.Client? cliente,
  })  : _url = url.endsWith('/') ? url.substring(0, url.length - 1) : url,
        _llave = llave,
        _token = token,
        _http = cliente ?? http.Client();

  @override
  Future<void> avisar(EventoAviso evento, {String? pedidoId}) async {
    try {
      final token = await _token();
      if (token == null) return;
      await _http
          .post(
            Uri.parse('$_url/functions/v1/avisar'),
            headers: {
              'apikey': _llave,
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'evento': evento.clave,
              if (pedidoId != null) 'pedidoId': pedidoId,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Sin red o función caída: el aviso se pierde, la acción no.
    }
  }
}

/// Sin Supabase configurado, o en pruebas: guarda lo que se pidió avisar.
class MockNotificador implements Notificador {
  final List<(EventoAviso, String?)> enviados = [];

  @override
  Future<void> avisar(EventoAviso evento, {String? pedidoId}) async =>
      enviados.add((evento, pedidoId));
}
