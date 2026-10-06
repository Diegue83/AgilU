import 'package:flutter/material.dart';

import '../../core/routes.dart';

class ConfirmacionView extends StatelessWidget {
  final String folio;
  const ConfirmacionView({super.key, required this.folio});

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
                Text(folio,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
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
