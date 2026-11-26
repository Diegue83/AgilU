import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cafeteria.dart';
import '../models/producto.dart';
import 'menu_repository.dart';

/// Dónde se guarda la última copia del menú.
abstract class AlmacenMenu {
  Future<String?> leer(String clave);
  Future<void> guardar(String clave, String valor);
}

class PreferenciasAlmacenMenu implements AlmacenMenu {
  @override
  Future<String?> leer(String clave) async =>
      (await SharedPreferences.getInstance()).getString(clave);

  @override
  Future<void> guardar(String clave, String valor) async =>
      (await SharedPreferences.getInstance()).setString(clave, valor);
}

class MemoriaAlmacenMenu implements AlmacenMenu {
  final Map<String, String> datos = {};
  @override
  Future<String?> leer(String clave) async => datos[clave];
  @override
  Future<void> guardar(String clave, String valor) async =>
      datos[clave] = valor;
}

/// Envuelve el menú en línea y guarda la última copia. Sin conexión entrega
/// esa copia y [guardadoEn] dice de cuándo es; con conexión, el menú en vivo.
class MenuConCache implements MenuRepository {
  final MenuRepository _enLinea;
  final AlmacenMenu _almacen;
  final DateTime Function() _ahora;

  MenuConCache(this._enLinea,
      {AlmacenMenu? almacen, DateTime Function()? ahora})
      : _almacen = almacen ?? PreferenciasAlmacenMenu(),
        _ahora = ahora ?? DateTime.now;

  static const _claveMenu = 'menu.productos';
  static const _claveCafeterias = 'menu.cafeterias';

  /// Hora de la copia que se está mostrando, o null si el menú es en vivo.
  DateTime? guardadoEn;

  @override
  Stream<List<Producto>> observarMenu() {
    late final StreamController<List<Producto>> salida;
    StreamSubscription<List<Producto>>? sub;
    var enVivo = false;

    Future<void> usarCopia(Object error) async {
      if (enVivo) return; // Ya hay datos en vivo: el error se reintenta solo.
      final copia = await _leerMenu();
      if (copia == null) {
        salida.addError(error);
      } else {
        guardadoEn = copia.$1;
        salida.add(copia.$2);
      }
    }

    salida = StreamController<List<Producto>>(
      onListen: () {
        sub = _enLinea.observarMenu().listen((productos) {
          enVivo = true;
          guardadoEn = null;
          salida.add(productos);
          _guardarMenu(productos);
        }, onError: (Object e) {
          enVivo = false;
          usarCopia(e);
        });
      },
      onCancel: () => sub?.cancel(),
    );
    return salida.stream;
  }

  @override
  Future<List<Cafeteria>> cafeterias() async {
    try {
      final lista = await _enLinea.cafeterias();
      await _almacen.guardar(_claveCafeterias,
          jsonEncode([for (final c in lista) _deCafeteria(c)]));
      return lista;
    } catch (e) {
      final texto = await _almacen.leer(_claveCafeterias);
      if (texto == null) rethrow;
      return [
        for (final m
            in (jsonDecode(texto) as List).cast<Map<String, dynamic>>())
          _aCafeteria(m),
      ];
    }
  }

  Future<void> _guardarMenu(List<Producto> productos) => _almacen.guardar(
        _claveMenu,
        jsonEncode({
          'guardadoEn': _ahora().toIso8601String(),
          'productos': [for (final p in productos) _deProducto(p)],
        }),
      );

  Future<(DateTime, List<Producto>)?> _leerMenu() async {
    final texto = await _almacen.leer(_claveMenu);
    if (texto == null) return null;
    try {
      final m = jsonDecode(texto) as Map<String, dynamic>;
      return (
        DateTime.parse(m['guardadoEn'] as String),
        [
          for (final p in (m['productos'] as List).cast<Map<String, dynamic>>())
            _aProducto(p),
        ],
      );
    } catch (_) {
      return null; // Copia dañada o de otra versión: se ignora.
    }
  }

  static Map<String, dynamic> _deProducto(Producto p) => {
        'id': p.id,
        'nombre': p.nombre,
        'descripcion': p.descripcion,
        'precio': p.precio,
        'categoria': p.categoria,
        'disponible': p.disponible,
        'cafeteriaId': p.cafeteriaId,
        'estacionId': p.estacionId,
        'estacion': p.estacion,
        'estacionOrden': p.estacionOrden,
        'urlImagen': p.urlImagen,
        'precioOferta': p.precioOferta,
        'ofertaHasta': p.ofertaHasta?.toIso8601String(),
        'esEspecialidad': p.esEspecialidad,
        'preparacionInmediata': p.preparacionInmediata,
        'controlarStock': p.controlarStock,
        'existencias': p.existencias,
      };

  static Producto _aProducto(Map<String, dynamic> m) => Producto(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        descripcion: m['descripcion'] as String? ?? '',
        precio: (m['precio'] as num).toDouble(),
        categoria: m['categoria'] as String? ?? 'General',
        disponible: m['disponible'] as bool? ?? true,
        cafeteriaId: m['cafeteriaId'] as String,
        estacionId: m['estacionId'] as String? ?? '',
        estacion: m['estacion'] as String? ?? '',
        estacionOrden: (m['estacionOrden'] as num?)?.toInt() ?? 0,
        urlImagen: m['urlImagen'] as String?,
        precioOferta: (m['precioOferta'] as num?)?.toDouble(),
        ofertaHasta: m['ofertaHasta'] == null
            ? null
            : DateTime.parse(m['ofertaHasta'] as String),
        esEspecialidad: m['esEspecialidad'] as bool? ?? false,
        preparacionInmediata: m['preparacionInmediata'] as bool? ?? false,
        controlarStock: m['controlarStock'] as bool? ?? false,
        existencias: (m['existencias'] as num?)?.toInt() ?? 0,
      );

  static Map<String, dynamic> _deCafeteria(Cafeteria c) => {
        'id': c.id,
        'nombre': c.nombre,
        'aperturaMinutos': c.aperturaMinutos,
        'cierreMinutos': c.cierreMinutos,
        'anticipacionMinutos': c.anticipacionMinutos,
        'intervaloMinutos': c.intervaloMinutos,
        'capacidadPorFranja': c.capacidadPorFranja,
        'permitirInmediatos': c.permitirInmediatos,
        'activa': c.activa,
      };

  static Cafeteria _aCafeteria(Map<String, dynamic> m) => Cafeteria(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        aperturaMinutos: (m['aperturaMinutos'] as num).toInt(),
        cierreMinutos: (m['cierreMinutos'] as num).toInt(),
        anticipacionMinutos: (m['anticipacionMinutos'] as num).toInt(),
        intervaloMinutos: (m['intervaloMinutos'] as num).toInt(),
        capacidadPorFranja: (m['capacidadPorFranja'] as num).toInt(),
        permitirInmediatos: m['permitirInmediatos'] as bool? ?? false,
        activa: m['activa'] as bool? ?? true,
      );
}
