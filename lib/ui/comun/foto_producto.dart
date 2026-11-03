import 'package:flutter/material.dart';

/// Foto del producto o, si no tiene o no carga, una imagen genérica.
class FotoProducto extends StatelessWidget {
  final String? url;
  final double tamano;
  const FotoProducto({super.key, required this.url, this.tamano = 48});

  @override
  Widget build(BuildContext context) {
    final generica = Container(
      key: const Key('foto-generica'),
      width: tamano,
      height: tamano,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.restaurant, size: tamano * 0.5),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null || url!.isEmpty
          ? generica
          : Image.network(
              url!,
              width: tamano,
              height: tamano,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => generica,
            ),
    );
  }
}
