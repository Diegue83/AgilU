import 'dart:async';

import '../../dataconnect_generated/agilu.dart';
import '../models/cafeteria.dart';
import '../models/producto.dart';
import 'menu_repository.dart';

/// Lee el menú de SQL Connect (operación ListarMenu) y lo vuelve a consultar
/// cada [intervalo] para reflejar cambios de precio o disponibilidad.
class DataConnectMenuRepository implements MenuRepository {
  final AgiluConnector _conector;
  final Duration intervalo;

  DataConnectMenuRepository({
    AgiluConnector? conector,
    this.intervalo = const Duration(seconds: 30),
  }) : _conector = conector ?? AgiluConnector.instance;

  @override
  Stream<List<Producto>> observarMenu() {
    final ref = _conector.listarMenu().ref();
    StreamSubscription<void>? sub;
    Timer? timer;
    late final StreamController<List<Producto>> controller;

    void consultar() => ref.execute().then((_) {}, onError: (Object _) {});

    controller = StreamController<List<Producto>>(
      onListen: () {
        sub = ref.subscribe().listen(
              (r) => controller.add(r.data.productos.map(aProducto).toList()),
              onError: controller.addError,
            );
        timer = Timer.periodic(intervalo, (_) => consultar());
      },
      onCancel: () async {
        timer?.cancel();
        await sub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<List<Cafeteria>> cafeterias() async {
    final res = await _conector.listarCafeterias().execute();
    return res.data.cafeterias
        .map((c) => Cafeteria(
              id: c.id,
              nombre: c.nombre,
              aperturaMinutos: c.aperturaMinutos,
              cierreMinutos: c.cierreMinutos,
              anticipacionMinutos: c.anticipacionMinutos,
              intervaloMinutos: c.intervaloMinutos,
              capacidadPorFranja: c.capacidadPorFranja,
              permitirInmediatos: c.permitirInmediatos,
              activa: c.activa,
            ))
        .toList();
  }

  static Producto aProducto(ListarMenuProductos p) => Producto(
        id: p.id,
        nombre: p.nombre,
        descripcion: p.descripcion ?? '',
        precio: p.precio,
        categoria: p.categoria,
        disponible: p.disponible,
        cafeteriaId: p.puesto.cafeteria.id,
        estacionId: p.puesto.id,
        estacion: p.puesto.nombre,
        estacionOrden: p.puesto.orden,
        urlImagen: p.urlDeImagen,
        precioOferta: p.precioOferta,
        ofertaHasta: p.ofertaHasta?.toDateTime().toLocal(),
        esEspecialidad: p.esEspecialidad,
        preparacionInmediata: p.preparacionInmediata,
      );
}
