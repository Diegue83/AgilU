part of 'agilu.dart';

class CrearEstacionVariablesBuilder {
  String nombre;
  int orden;

  final FirebaseDataConnect _dataConnect;
  CrearEstacionVariablesBuilder(
    this._dataConnect, {
    required this.nombre,
    required this.orden,
  });
  Deserializer<CrearEstacionData> dataDeserializer =
      (dynamic json) => CrearEstacionData.fromJson(jsonDecode(json));
  Serializer<CrearEstacionVariables> varsSerializer =
      (CrearEstacionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearEstacionData, CrearEstacionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearEstacionData, CrearEstacionVariables> ref() {
    CrearEstacionVariables vars = CrearEstacionVariables(
      nombre: nombre,
      orden: orden,
    );
    return _dataConnect.mutation(
        "CrearEstacion", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearEstacionPuestoInsert {
  final String id;
  CrearEstacionPuestoInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearEstacionPuestoInsert otherTyped =
        other as CrearEstacionPuestoInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CrearEstacionPuestoInsert({
    required this.id,
  });
}

@immutable
class CrearEstacionData {
  final CrearEstacionPuestoInsert puesto_insert;
  CrearEstacionData.fromJson(dynamic json)
      : puesto_insert =
            CrearEstacionPuestoInsert.fromJson(json['puesto_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearEstacionData otherTyped = other as CrearEstacionData;
    return puesto_insert == otherTyped.puesto_insert;
  }

  @override
  int get hashCode => puesto_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['puesto_insert'] = puesto_insert.toJson();
    return json;
  }

  CrearEstacionData({
    required this.puesto_insert,
  });
}

@immutable
class CrearEstacionVariables {
  final String nombre;
  final int orden;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearEstacionVariables.fromJson(Map<String, dynamic> json)
      : nombre = nativeFromJson<String>(json['nombre']),
        orden = nativeFromJson<int>(json['orden']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearEstacionVariables otherTyped = other as CrearEstacionVariables;
    return nombre == otherTyped.nombre && orden == otherTyped.orden;
  }

  @override
  int get hashCode => Object.hashAll([nombre.hashCode, orden.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    json['orden'] = nativeToJson<int>(orden);
    return json;
  }

  CrearEstacionVariables({
    required this.nombre,
    required this.orden,
  });
}
