import 'package:agilu/core/routes.dart';
import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/models/reporte.dart';
import 'package:agilu/data/repositories/reporte_repository.dart';
import 'package:agilu/ui/reporte/reporte_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _Rango implements ReporteRepository {
  DateTime? desde;
  DateTime? hasta;
  @override
  Future<List<FilaReporte>> resumen(DateTime d, DateTime h) async {
    desde = d;
    hasta = h;
    return const [];
  }
}

void main() {
  test('los periodos cubren hoy, 7 y 30 días hasta el final de hoy', () {
    final ahora = DateTime(2026, 11, 10, 15);
    expect(Periodo.hoy.rango(ahora),
        (DateTime(2026, 11, 10), DateTime(2026, 11, 11)));
    expect(Periodo.semana.rango(ahora).$1, DateTime(2026, 11, 4));
    expect(Periodo.mes.rango(ahora).$1, DateTime(2026, 10, 12));
  });

  test('calcula total, ticket promedio y tasa de no recogidos', () {
    const a = FilaReporte(
        cafeteriaId: 'a',
        cafeteria: 'A',
        pedidos: 10,
        entregados: 8,
        noRecogidos: 2,
        ingresos: 500);
    const b = FilaReporte(
        cafeteriaId: 'b',
        cafeteria: 'B',
        pedidos: 5,
        entregados: 5,
        ingresos: 250);
    final t = FilaReporte.total([a, b]);
    expect(t.pedidos, 15);
    expect(t.ingresos, 750);
    expect(t.ticketPromedio, 50);
    expect(a.tasaNoRecogidos, 0.2);
    expect(
        const FilaReporte(cafeteriaId: 'x', cafeteria: 'X').tasaNoRecogidos, 0);
  });

  test('cambiar de periodo vuelve a consultar con el nuevo rango', () async {
    final repo = _Rango();
    final vm = ReporteViewModel(repo, ahora: () => DateTime(2026, 11, 10, 15));
    await vm.cargar();
    expect(repo.desde, DateTime(2026, 11, 4));
    await vm.elegir(Periodo.hoy);
    expect(repo.desde, DateTime(2026, 11, 10));
  });

  test('la beneficiaria inicia en el reporte', () {
    const p = Perfil(
        nombre: 'E', correo: 'e@utng.edu.mx', rol: RolUsuario.beneficiaria);
    expect(Routes.inicioPara(p), Routes.reporte);
  });
}
