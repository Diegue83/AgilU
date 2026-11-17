import 'package:flutter/foundation.dart';

import '../../data/models/perfil.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/perfil_repository.dart';

/// Registro en dos pasos: primero los datos personales y después las
/// credenciales de inicio de sesión.
/// - Alumno (registro normal): la cuenta nueva es de alumno.
/// - Empleado ("Solicitar trabajo"): puede ser alguien externo; la cuenta no
///   es de alumno y queda en espera de que el encargado de la cafetería la
///   apruebe.
class RegistroViewModel extends ChangeNotifier {
  final AuthRepository _auth;
  final PerfilRepository? _perfiles;
  final bool empleado;
  RegistroViewModel(this._auth,
      {PerfilRepository? perfiles, this.empleado = false})
      : _perfiles = perfiles {
    if (empleado) cargarCafeterias();
  }

  List<OpcionCafeteria> cafeterias = [];
  String? cafeteriaId;
  bool cargandoCafeterias = false;

  void elegirCafeteria(String? id) {
    cafeteriaId = id;
    notifyListeners();
  }

  Future<void> cargarCafeterias() async {
    final perfiles = _perfiles;
    if (perfiles == null) return;
    cargandoCafeterias = true;
    notifyListeners();
    try {
      cafeterias = await perfiles.cafeteriasParaRegistro();
    } catch (_) {
      error = 'No se pudieron cargar las cafeterías.';
    } finally {
      cargandoCafeterias = false;
      notifyListeners();
    }
  }

  static final _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _soloLetras = RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' .-]+$");

  int paso = 0;
  bool cargando = false;
  String? error;
  DatosPersonales? _datos;

  /// Teléfono con solo dígitos, o null si se dejó vacío.
  static String? limpiarTelefono(String telefono) {
    final digitos = telefono.replaceAll(RegExp(r'[\s()-]'), '');
    return digitos.isEmpty ? null : digitos;
  }

  /// Problema con los datos personales, o null si son válidos.
  String? validarDatos(String nombre, String apellidos, String telefono) {
    final n = nombre.trim();
    final a = apellidos.trim();
    if (n.isEmpty) return 'Escribe tu nombre.';
    if (a.isEmpty) return 'Escribe tus apellidos.';
    if (!_soloLetras.hasMatch(n) || !_soloLetras.hasMatch(a)) {
      return 'El nombre y los apellidos solo llevan letras.';
    }
    if ('$n $a'.length > 80) return 'El nombre es demasiado largo.';
    final t = limpiarTelefono(telefono);
    if (t != null && !RegExp(r'^[0-9]{10}$').hasMatch(t)) {
      return 'El teléfono debe tener 10 dígitos.';
    }
    return null;
  }

  /// Problema con las credenciales, o null si son válidas.
  String? validarCredenciales(
      String correo, String contrasena, String confirmacion) {
    final c = correo.trim();
    if (c.isEmpty) return 'Escribe tu correo.';
    if (!_formatoCorreo.hasMatch(c)) {
      return 'El correo no tiene un formato válido.';
    }
    if (contrasena.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (contrasena != confirmacion) return 'Las contraseñas no coinciden.';
    return null;
  }

  /// Paso 1 → paso 2. Devuelve false si los datos tienen un problema.
  bool continuar(String nombre, String apellidos, String telefono) {
    final problema = validarDatos(nombre, apellidos, telefono) ??
        (empleado && cafeteriaId == null
            ? 'Elige la cafetería donde trabajas.'
            : null);
    error = problema;
    if (problema == null) {
      _datos = DatosPersonales(
        nombre: nombre.trim(),
        apellidos: apellidos.trim(),
        telefono: limpiarTelefono(telefono),
        cafeteriaSolicitada: empleado ? cafeteriaId : null,
      );
      paso = 1;
    }
    notifyListeners();
    return problema == null;
  }

  void regresar() {
    if (paso == 0 || cargando) return;
    paso = 0;
    error = null;
    notifyListeners();
  }

  /// Crea la cuenta. Devuelve true si quedó registrada y con sesión.
  Future<bool> registrar(
      String correo, String contrasena, String confirmacion) async {
    if (cargando || _datos == null) return false;
    final problema = validarCredenciales(correo, contrasena, confirmacion);
    if (problema != null) {
      error = problema;
      notifyListeners();
      return false;
    }
    cargando = true;
    error = null;
    notifyListeners();
    try {
      await _auth.registrar(correo.trim(), contrasena, _datos!);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
