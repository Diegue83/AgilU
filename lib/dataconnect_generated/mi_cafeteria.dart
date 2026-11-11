part of 'agilu.dart';

class MiCafeteriaVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  MiCafeteriaVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<MiCafeteriaData> dataDeserializer =
      (dynamic json) => MiCafeteriaData.fromJson(jsonDecode(json));

  Future<QueryResult<MiCafeteriaData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MiCafeteriaData, void> ref() {
    return _dataConnect.query(
        "MiCafeteria", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MiCafeteriaAutenticacion {
  final MiCafeteriaAutenticacionUsuario usuario;
  MiCafeteriaAutenticacion.fromJson(dynamic json)
      : usuario = MiCafeteriaAutenticacionUsuario.fromJson(json['usuario']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MiCafeteriaAutenticacion otherTyped =
        other as MiCafeteriaAutenticacion;
    return usuario == otherTyped.usuario;
  }

  @override
  int get hashCode => usuario.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuario'] = usuario.toJson();
    return json;
  }

  MiCafeteriaAutenticacion({
    required this.usuario,
  });
}

@immutable
class MiCafeteriaAutenticacionUsuario {
  final MiCafeteriaAutenticacionUsuarioRol? rol;
  final MiCafeteriaAutenticacionUsuarioCafeteria? cafeteria;
  MiCafeteriaAutenticacionUsuario.fromJson(dynamic json)
      : rol = json['rol'] == null
            ? null
            : MiCafeteriaAutenticacionUsuarioRol.fromJson(json['rol']),
        cafeteria = json['cafeteria'] == null
            ? null
            : MiCafeteriaAutenticacionUsuarioCafeteria.fromJson(
                json['cafeteria']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MiCafeteriaAutenticacionUsuario otherTyped =
        other as MiCafeteriaAutenticacionUsuario;
    return rol == otherTyped.rol && cafeteria == otherTyped.cafeteria;
  }

  @override
  int get hashCode => Object.hashAll([rol.hashCode, cafeteria.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (rol != null) {
      json['rol'] = rol!.toJson();
    }
    if (cafeteria != null) {
      json['cafeteria'] = cafeteria!.toJson();
    }
    return json;
  }

  MiCafeteriaAutenticacionUsuario({
    this.rol,
    this.cafeteria,
  });
}

@immutable
class MiCafeteriaAutenticacionUsuarioRol {
  final String nombre;
  MiCafeteriaAutenticacionUsuarioRol.fromJson(dynamic json)
      : nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MiCafeteriaAutenticacionUsuarioRol otherTyped =
        other as MiCafeteriaAutenticacionUsuarioRol;
    return nombre == otherTyped.nombre;
  }

  @override
  int get hashCode => nombre.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  MiCafeteriaAutenticacionUsuarioRol({
    required this.nombre,
  });
}

@immutable
class MiCafeteriaAutenticacionUsuarioCafeteria {
  final String id;
  final String nombre;
  final int aperturaMinutos;
  final int cierreMinutos;
  final int anticipacionMinutos;
  final int intervaloMinutos;
  final int capacidadPorFranja;
  final bool permitirInmediatos;
  MiCafeteriaAutenticacionUsuarioCafeteria.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        nombre = nativeFromJson<String>(json['nombre']),
        aperturaMinutos = nativeFromJson<int>(json['aperturaMinutos']),
        cierreMinutos = nativeFromJson<int>(json['cierreMinutos']),
        anticipacionMinutos = nativeFromJson<int>(json['anticipacionMinutos']),
        intervaloMinutos = nativeFromJson<int>(json['intervaloMinutos']),
        capacidadPorFranja = nativeFromJson<int>(json['capacidadPorFranja']),
        permitirInmediatos = nativeFromJson<bool>(json['permitirInmediatos']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MiCafeteriaAutenticacionUsuarioCafeteria otherTyped =
        other as MiCafeteriaAutenticacionUsuarioCafeteria;
    return id == otherTyped.id &&
        nombre == otherTyped.nombre &&
        aperturaMinutos == otherTyped.aperturaMinutos &&
        cierreMinutos == otherTyped.cierreMinutos &&
        anticipacionMinutos == otherTyped.anticipacionMinutos &&
        intervaloMinutos == otherTyped.intervaloMinutos &&
        capacidadPorFranja == otherTyped.capacidadPorFranja &&
        permitirInmediatos == otherTyped.permitirInmediatos;
  }

  @override
  int get hashCode => Object.hashAll([
        id.hashCode,
        nombre.hashCode,
        aperturaMinutos.hashCode,
        cierreMinutos.hashCode,
        anticipacionMinutos.hashCode,
        intervaloMinutos.hashCode,
        capacidadPorFranja.hashCode,
        permitirInmediatos.hashCode
      ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    json['aperturaMinutos'] = nativeToJson<int>(aperturaMinutos);
    json['cierreMinutos'] = nativeToJson<int>(cierreMinutos);
    json['anticipacionMinutos'] = nativeToJson<int>(anticipacionMinutos);
    json['intervaloMinutos'] = nativeToJson<int>(intervaloMinutos);
    json['capacidadPorFranja'] = nativeToJson<int>(capacidadPorFranja);
    json['permitirInmediatos'] = nativeToJson<bool>(permitirInmediatos);
    return json;
  }

  MiCafeteriaAutenticacionUsuarioCafeteria({
    required this.id,
    required this.nombre,
    required this.aperturaMinutos,
    required this.cierreMinutos,
    required this.anticipacionMinutos,
    required this.intervaloMinutos,
    required this.capacidadPorFranja,
    required this.permitirInmediatos,
  });
}

@immutable
class MiCafeteriaData {
  final MiCafeteriaAutenticacion? autenticacion;
  MiCafeteriaData.fromJson(dynamic json)
      : autenticacion = json['autenticacion'] == null
            ? null
            : MiCafeteriaAutenticacion.fromJson(json['autenticacion']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MiCafeteriaData otherTyped = other as MiCafeteriaData;
    return autenticacion == otherTyped.autenticacion;
  }

  @override
  int get hashCode => autenticacion.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (autenticacion != null) {
      json['autenticacion'] = autenticacion!.toJson();
    }
    return json;
  }

  MiCafeteriaData({
    this.autenticacion,
  });
}
