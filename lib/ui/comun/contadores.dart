import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/contadores_repository.dart';

/// Mantiene al día los puntos rojos de la navegación: consulta los conteos al
/// abrir una pantalla, cada [intervalo] mientras haya alguien escuchando y
/// cuando se pide (al llegar un aviso o después de una acción).
class ContadoresController extends ChangeNotifier {
  final ContadoresRepository _repo;
  final Duration intervalo;
  ContadoresController(this._repo,
      {this.intervalo = const Duration(seconds: 20)});

  Contadores actual = Contadores.ceros;
  Timer? _timer;
  int _pantallas = 0;
  bool _consultando = false;

  /// Una pantalla con puntos rojos se abrió.
  void activar() {
    _pantallas++;
    actualizar();
    _timer ??= Timer.periodic(intervalo, (_) => actualizar());
  }

  /// Esa pantalla se cerró; sin pantallas no se consulta.
  void desactivar() {
    _pantallas = (_pantallas - 1).clamp(0, 1 << 30);
    if (_pantallas == 0) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> actualizar() async {
    if (_consultando) return;
    _consultando = true;
    try {
      final nuevos = await _repo.misPendientes();
      actual = nuevos;
      notifyListeners();
    } catch (_) {
      // Sin red o sin sesión: se conservan los últimos conteos.
    } finally {
      _consultando = false;
    }
  }

  /// Al cerrar sesión.
  void limpiar() {
    actual = Contadores.ceros;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Ícono con punto rojo y número cuando [cuenta] es mayor que cero.
class IconoConPunto extends StatelessWidget {
  final IconData icono;
  final int cuenta;
  const IconoConPunto(this.icono, this.cuenta, {super.key});

  @override
  Widget build(BuildContext context) => Badge(
        isLabelVisible: cuenta > 0,
        label: Text(cuenta > 99 ? '99+' : '$cuenta'),
        child: Icon(icono),
      );
}

/// Mantiene activos los conteos mientras [child] está en pantalla.
class ConContadores extends StatefulWidget {
  final Widget child;
  const ConContadores({super.key, required this.child});

  @override
  State<ConContadores> createState() => _ConContadoresState();
}

class _ConContadoresState extends State<ConContadores> {
  late final ContadoresController _contadores =
      context.read<ContadoresController>();

  @override
  void initState() {
    super.initState();
    _contadores.activar();
  }

  @override
  void dispose() {
    _contadores.desactivar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
