import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/actualizacion.dart';
import '../../data/repositories/actualizacion_repository.dart';

enum EstadoActualizacion {
  /// Fuera de Android no hay cómo instalar un APK.
  noSoportada,
  inicial,
  buscando,
  alDia,
  disponible,
  descargando,
  faltaPermiso,
  instalando,
  error,
}

/// Busca en los releases de GitHub una versión más nueva, la descarga,
/// comprueba su SHA-256 y abre el instalador de Android.
class ActualizacionController extends ChangeNotifier {
  final ActualizacionRepository _repo;
  ActualizacionController(this._repo, {bool soportada = true})
      : estado = soportada
            ? EstadoActualizacion.inicial
            : EstadoActualizacion.noSoportada;

  EstadoActualizacion estado;
  VersionApp? instalada;
  Actualizacion? nueva;
  double progreso = 0;
  String? error;
  String? _descargada;

  bool get soportada => estado != EstadoActualizacion.noSoportada;
  bool get trabajando => const [
        EstadoActualizacion.buscando,
        EstadoActualizacion.descargando,
        EstadoActualizacion.instalando,
      ].contains(estado);

  void _cambiar(EstadoActualizacion e) {
    estado = e;
    notifyListeners();
  }

  /// Consulta el último release. Si falla la red no molesta: queda en error
  /// con el motivo para quien lo pidió desde Mi cuenta.
  Future<void> buscar() async {
    if (!soportada || trabajando) return;
    _cambiar(EstadoActualizacion.buscando);
    try {
      instalada ??= await _repo.versionInstalada();
      final ultima = await _repo.ultima();
      final actual = instalada;
      if (ultima != null &&
          actual != null &&
          ultima.version.esMayorQue(actual)) {
        if (nueva?.version != ultima.version) _descargada = null;
        nueva = ultima;
        error = null;
        _cambiar(EstadoActualizacion.disponible);
      } else {
        nueva = null;
        _cambiar(EstadoActualizacion.alDia);
      }
    } catch (_) {
      error = 'No se pudo revisar si hay una versión nueva.';
      _cambiar(EstadoActualizacion.error);
    }
  }

  /// Descarga (una sola vez) y abre el instalador. Si Android pide permitir
  /// la instalación, queda en [EstadoActualizacion.faltaPermiso] y el
  /// siguiente toque instala lo ya descargado.
  Future<void> actualizar() async {
    final a = nueva;
    if (a == null || trabajando) return;
    try {
      if (_descargada == null) {
        progreso = 0;
        _cambiar(EstadoActualizacion.descargando);
        _descargada = await _repo.descargar(a, (p) {
          progreso = p.clamp(0, 1).toDouble();
          notifyListeners();
        });
      }
      _cambiar(EstadoActualizacion.instalando);
      await _repo.instalar(_descargada!);
      error = null;
      _cambiar(EstadoActualizacion.disponible);
    } on FaltaPermisoInstalar {
      _cambiar(EstadoActualizacion.faltaPermiso);
    } on ActualizacionInvalida catch (e) {
      _descargada = null;
      error = e.mensaje;
      _cambiar(EstadoActualizacion.error);
    } catch (_) {
      _descargada = null;
      error = 'No se pudo descargar la actualización. Revisa tu conexión.';
      _cambiar(EstadoActualizacion.error);
    }
  }
}

/// El controlador si la app lo registró (las pruebas de pantallas no lo usan).
ActualizacionController? actualizadorDe(BuildContext context) {
  try {
    return context.read<ActualizacionController>();
  } on ProviderNotFoundException {
    return null;
  }
}

/// Diálogo con la versión nueva, sus novedades y el avance de la descarga.
Future<void> ofrecerActualizacion(
    BuildContext context, ActualizacionController c) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => ListenableBuilder(
      listenable: c,
      builder: (ctx, _) {
        final a = c.nueva;
        return AlertDialog(
          title:
              Text(a == null ? 'Actualización' : 'Nueva versión ${a.version}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.instalada != null)
                  Text('Tienes la versión ${c.instalada}.'),
                if (a != null && a.notas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(a.notas.length > 1200
                      ? '${a.notas.substring(0, 1200)}…'
                      : a.notas),
                ],
                const SizedBox(height: 12),
                switch (c.estado) {
                  EstadoActualizacion.descargando => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(value: c.progreso),
                        const SizedBox(height: 4),
                        Text('Descargando ${(c.progreso * 100).round()} %'),
                      ],
                    ),
                  EstadoActualizacion.instalando =>
                    const Text('Abriendo el instalador…'),
                  EstadoActualizacion.faltaPermiso => const Text(
                      'Permite que ÁgilU instale apps en el ajuste que se '
                      'abrió, regresa y toca Instalar.'),
                  EstadoActualizacion.error => Text(c.error ?? '',
                      style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                  _ => const Text('Android te pedirá confirmar la '
                      'instalación. Tus datos se conservan.'),
                },
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: c.trabajando ? null : () => Navigator.pop(ctx),
              child: const Text('Después'),
            ),
            FilledButton(
              onPressed: c.trabajando || a == null ? null : c.actualizar,
              child: Text(c.estado == EstadoActualizacion.faltaPermiso
                  ? 'Instalar'
                  : c.estado == EstadoActualizacion.error
                      ? 'Reintentar'
                      : 'Actualizar'),
            ),
          ],
        );
      },
    ),
  );
}

/// Versión instalada y botón para buscar actualizaciones (Mi cuenta).
class TarjetaVersion extends StatelessWidget {
  const TarjetaVersion({super.key});

  @override
  Widget build(BuildContext context) {
    final c = actualizadorDe(context);
    if (c == null || !c.soportada) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Card(
        child: ListTile(
          leading: const Icon(Icons.system_update_outlined),
          title: const Text('Buscar actualizaciones'),
          subtitle: Text([
            if (c.instalada != null) 'Versión ${c.instalada}',
            if (c.estado == EstadoActualizacion.alDia) 'Es la más reciente',
            if (c.nueva != null) 'Disponible: ${c.nueva!.version}',
          ].join(' · ')),
          trailing: c.estado == EstadoActualizacion.buscando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : null,
          onTap: c.trabajando
              ? null
              : () async {
                  await c.buscar();
                  if (!context.mounted) return;
                  if (c.nueva != null) {
                    await ofrecerActualizacion(context, c);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(c.estado == EstadoActualizacion.error
                            ? c.error!
                            : 'Ya tienes la versión más reciente.')));
                  }
                },
        ),
      ),
    );
  }
}
