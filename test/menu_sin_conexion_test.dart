import 'dart:async';

import 'package:agilu/data/models/cafeteria.dart';
import 'package:agilu/data/models/producto.dart';
import 'package:agilu/data/repositories/menu_con_cache.dart';
import 'package:agilu/data/repositories/menu_repository.dart';
import 'package:agilu/ui/menu/menu_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Menú en línea que se puede "desconectar".
class _Red implements MenuRepository {
  bool conectado = true;
  final productos = [
    const Producto(
        id: 't',
        nombre: 'Torta',
        descripcion: 'De milanesa',
        precio: 50,
        categoria: 'C',
        cafeteriaId: 'c1',
        estacion: 'Tortas',
        controlarStock: true,
        existencias: 3),
  ];

  @override
  Stream<List<Producto>> observarMenu() =>
      conectado ? Stream.value(productos) : Stream.error(Exception('sin red'));

  @override
  Future<List<Cafeteria>> cafeterias() async {
    if (!conectado) throw Exception('sin red');
    return const [
      Cafeteria(id: 'c1', nombre: 'Central', capacidadPorFranja: 7)
    ];
  }
}

Future<void> _esperar() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('sin conexión entrega la última copia y dice de cuándo es', () async {
    final red = _Red();
    final almacen = MemoriaAlmacenMenu();
    final cache = MenuConCache(red,
        almacen: almacen, ahora: () => DateTime(2026, 11, 26, 9, 5));

    // Con red: guarda la copia.
    final enVivo = await cache.observarMenu().first;
    await cache.cafeterias();
    await _esperar();
    expect(enVivo.single.nombre, 'Torta');
    expect(cache.guardadoEn, isNull);

    // Sin red: la misma copia, con su hora.
    red.conectado = false;
    final copia = await cache.observarMenu().first;
    expect(copia.single.existencias, 3);
    expect(copia.single.estacion, 'Tortas');
    expect(cache.guardadoEn, DateTime(2026, 11, 26, 9, 5));
    final cafes = await cache.cafeterias();
    expect(cafes.single.capacidadPorFranja, 7);

    // Al volver la red deja de ser copia.
    red.conectado = true;
    await cache.observarMenu().first;
    expect(cache.guardadoEn, isNull);
  });

  test('sin conexión y sin copia se informa el error', () async {
    final red = _Red()..conectado = false;
    final cache = MenuConCache(red, almacen: MemoriaAlmacenMenu());
    await expectLater(cache.observarMenu().first, throwsException);
    await expectLater(cache.cafeterias(), throwsException);
  });

  test('el menú avisa cuando muestra la copia guardada', () async {
    final red = _Red();
    final almacen = MemoriaAlmacenMenu();
    final cache = MenuConCache(red,
        almacen: almacen, ahora: () => DateTime(2026, 11, 26, 9, 5));
    await cache.observarMenu().first;
    await cache.cafeterias();
    await _esperar();

    red.conectado = false;
    final vm = MenuViewModel(cache, ahora: () => DateTime(2026, 11, 26, 10));
    await _esperar();
    expect(vm.productosVisibles.single.nombre, 'Torta');
    expect(vm.error, isNull);
    expect(vm.avisoSinConexion, contains('09:05'));
    vm.dispose();
  });
}
