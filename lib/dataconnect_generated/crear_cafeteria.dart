part of 'agilu.dart';

class CrearCafeteriaVariablesBuilder {
  String nombre;
  Optional<String> _ubicacion = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;
  CrearCafeteriaVariablesBuilder ubicacion(String? t) {
    _ubicacion.value = t;
    return this;
  }

  CrearCafeteriaVariablesBuilder(
    this._dataConnect, {
    required this.nombre,
  });
  Deserializer<CrearCafeteriaData> dataDeserializer =
      (dynamic json) => CrearCafeteriaData.fromJson(jsonDecode(json));
  Serializer<CrearCafeteriaVariables> varsSerializer =
      (CrearCafeteriaVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearCafeteriaData, CrearCafeteriaVariables>>
      execute() {
    return ref().execute();
  }

  MutationRef<CrearCafeteriaData, CrearCafeteriaVariables> ref() {
    CrearCafeteriaVariables vars = CrearCafeteriaVariables(
      nombre: nombre,
      ubicacion: _ubicacion,
    );
    return _dataConnect.mutation(
        "CrearCafeteria", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearCafeteriaCafeteriaInsert {
  final String id;
  CrearCafeteriaCafeteriaInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearCafeteriaCafeteriaInsert otherTyped =
        other as CrearCafeteriaCafeteriaInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CrearCafeteriaCafeteriaInsert({
    required this.id,
  });
}

@immutable
class CrearCafeteriaData {
  final CrearCafeteriaCafeteriaInsert cafeteria_insert;
  CrearCafeteriaData.fromJson(dynamic json)
      : cafeteria_insert =
            CrearCafeteriaCafeteriaInsert.fromJson(json['cafeteria_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearCafeteriaData otherTyped = other as CrearCafeteriaData;
    return cafeteria_insert == otherTyped.cafeteria_insert;
  }

  @override
  int get hashCode => cafeteria_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cafeteria_insert'] = cafeteria_insert.toJson();
    return json;
  }

  CrearCafeteriaData({
    required this.cafeteria_insert,
  });
}

@immutable
class CrearCafeteriaVariables {
  final String nombre;
  late final Optional<String> ubicacion;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearCafeteriaVariables.fromJson(Map<String, dynamic> json)
      : nombre = nativeFromJson<String>(json['nombre']) {
    ubicacion = Optional.optional(nativeFromJson, nativeToJson);
    ubicacion.value = json['ubicacion'] == null
        ? null
        : nativeFromJson<String>(json['ubicacion']);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearCafeteriaVariables otherTyped = other as CrearCafeteriaVariables;
    return nombre == otherTyped.nombre && ubicacion == otherTyped.ubicacion;
  }

  @override
  int get hashCode => Object.hashAll([nombre.hashCode, ubicacion.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    if (ubicacion.state == OptionalState.set) {
      json['ubicacion'] = ubicacion.toJson();
    }
    return json;
  }

  CrearCafeteriaVariables({
    required this.nombre,
    required this.ubicacion,
  });
}
