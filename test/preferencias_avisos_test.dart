import 'package:agilu/data/models/perfil.dart';
import 'package:agilu/data/repositories/auth_repository.dart';
import 'package:agilu/data/repositories/pedido_repository.dart';
import 'package:agilu/data/repositories/perfil_repository.dart';
import 'package:agilu/ui/cuenta/cuenta_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  test('el alumno apaga el aviso de pedido listo y se guarda', () async {
    final perfiles = MockPerfilRepository();
    final vm =
        CuentaViewModel(perfiles, MockAuthRepository(), MockPedidoRepository());
    await _esperar();
    expect(vm.perfil!.avisos.pedidoListo, isTrue);

    expect(await vm.cambiarAvisos(vm.perfil!.avisos.copiar(pedidoListo: false)),
        isTrue);
    expect(vm.perfil!.avisos.pedidoListo, isFalse);
    expect(vm.perfil!.avisos.pagos, isTrue);
    expect(perfiles.perfil.avisos.pedidoListo, isFalse);
  });

  test('por defecto se reciben todos los avisos', () {
    const a = PreferenciasAvisos();
    expect([a.pedidoListo, a.pagos, a.personal], [true, true, true]);
    expect(a.copiar(personal: false).personal, isFalse);
  });
}
