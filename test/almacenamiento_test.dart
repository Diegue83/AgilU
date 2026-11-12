import 'dart:math';
import 'dart:typed_data';

import 'package:agilu/data/models/ticket.dart';
import 'package:agilu/data/repositories/almacen_archivos.dart';
import 'package:agilu/data/repositories/pagos_repository.dart';
import 'package:agilu/ui/encargado/pagos/pagos_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// PNG de 1×1 píxel.
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);

void main() {
  group('rutas y validación', () {
    test('la ruta queda en la carpeta del usuario y no se puede adivinar', () {
      final a = rutaArchivo('uid123', 'pedido9', 'image/jpeg');
      final b = rutaArchivo('uid123', 'pedido9', 'image/jpeg');
      expect(a, startsWith('uid123/pedido9-'));
      expect(a, endsWith('.jpg'));
      expect(a, isNot(b));
      expect(RegExp(r'-[0-9a-f]{32}\.jpg$').hasMatch(a), isTrue);
      expect(rutaArchivo('u', 'p', 'image/png', azar: Random(1)),
          endsWith('.png'));
    });

    test('solo JPG o PNG de hasta 1 MB', () {
      expect(validarImagen(_png, 'image/png'), isNull);
      expect(validarImagen(_png, 'image/gif'), 'La foto debe ser JPG o PNG.');
      expect(
          validarImagen(Uint8List(0), 'image/png'), 'No se recibió la foto.');
      expect(validarImagen(Uint8List(tamanoMaximo + 1), 'image/jpeg'),
          'La foto pesa más de 1 MB.');
    });

    test('la URL pública sigue el formato de Supabase', () {
      final almacen = SupabaseAlmacen(
          url: 'https://abc.supabase.co/', llave: 'k', token: () async => 't');
      expect(almacen.urlPublica('productos', 'u/f.jpg'),
          'https://abc.supabase.co/storage/v1/object/public/productos/u/f.jpg');
    });
  });

  group('comprobante en el panel de pagos', () {
    Widget conPago(MockPagosRepository repo, String ubicacion) => MaterialApp(
          home: Provider<PagosRepository>.value(
            value: repo,
            child: Scaffold(body: ImagenComprobante(ubicacion: ubicacion)),
          ),
        );

    testWidgets('una ruta de Supabase se descarga y se muestra',
        (tester) async {
      final repo = MockPagosRepository()..imagenes['uid/p9-abc.png'] = _png;
      await tester.pumpWidget(conPago(repo, 'uid/p9-abc.png'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('si no se puede descargar, lo dice sin romper la pantalla',
        (tester) async {
      await tester
          .pumpWidget(conPago(MockPagosRepository(), 'uid/no-existe.png'));
      await tester.pumpAndSettle();
      expect(find.text('No se pudo mostrar el comprobante.'), findsOneWidget);
    });

    test('el pago guarda la ubicación del comprobante', () {
      final p = PagoPorValidar(
          pedidoId: 'p',
          folio: 'AGU-00001',
          referencia: 'AGU-00001',
          total: 1,
          recogerA: DateTime(2026),
          alumno: 'A',
          comprobanteUrl: 'uid/p-1.jpg');
      expect(p.comprobanteUrl, 'uid/p-1.jpg');
    });
  });
}
