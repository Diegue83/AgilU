import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Lee un QR con la cámara y regresa su texto (HU-12).
class EscanerView extends StatefulWidget {
  const EscanerView({super.key});

  @override
  State<EscanerView> createState() => _EscanerViewState();
}

class _EscanerViewState extends State<EscanerView> {
  bool _leido = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR de entrega')),
      body: MobileScanner(
        onDetect: (captura) {
          if (_leido) return;
          final valor = captura.barcodes
              .map((b) => b.rawValue)
              .whereType<String>()
              .firstOrNull;
          if (valor == null) return;
          _leido = true;
          Navigator.pop(context, valor);
        },
      ),
    );
  }
}
