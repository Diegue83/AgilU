import 'package:flutter/material.dart';

import '../../core/reglas_pedido.dart';
import '../../core/routes.dart';
import '../../data/models/pedido.dart';

class ConfirmacionView extends StatelessWidget {
  final ResultadoPedido resultado;
  const ConfirmacionView({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 96, color: Colors.green),
                const SizedBox(height: 16),
                Text('¡Pedido enviado!',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text('Tu folio es:'),
                SelectableText(resultado.folio,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Recoge hoy a las ${ReglasPedido.formatearHora(resultado.recogerA)}'),
                Text('Total a pagar: \$${resultado.total.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                const Text('Muestra tu folio en la cafetería.',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, Routes.menu),
                  child: const Text('Volver al menú'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}