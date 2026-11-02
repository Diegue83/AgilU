part of 'agilu.dart';

class EliminarEstacionVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  EliminarEstacionVariablesBuilder(
    this._dataConnect, {
    required this.id,
  });
  Deserializer<EliminarEstacionData> dataDeserializer =
      (dynamic json) => EliminarEstacionData.fromJson(jsonDecode(json));
  Serializer<EliminarEstacionVariables> varsSerializer =
      (EliminarEstacionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EliminarEstacionData, EliminarEstacionVariables>>
      execute() {
    return ref().execute();
  }

  MutationRef<EliminarEstacionData, EliminarEstacionVariables> ref() {
    EliminarEstacionVariables vars = EliminarEstacionVariables(
      id: id,
    );
    return _dataConnect.mutation(
        "EliminarEstacion", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EliminarEstacionPuestoDelete {
  final String id;
  EliminarEstacionPuestoDelete.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarEstacionPuestoDelete otherTyped =
        other as EliminarEstacionPuestoDelete;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EliminarEstacionPuestoDelete({
    required this.id,
  });
}

@immutable
class EliminarEstacionData {
  final EliminarEstacionPuestoDelete? puesto_delete;
  EliminarEstacionData.fromJson(dynamic json)
      : puesto_delete = json['puesto_delete'] == null
            ? null
            : EliminarEstacionPuestoDelete.fromJson(json['puesto_delete']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarEstacionData otherTyped = other as EliminarEstacionData;
    return puesto_delete == otherTyped.puesto_delete;
  }

  @override
  int get hashCode => puesto_delete.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (puesto_delete != null) {
      json['puesto_delete'] = puesto_delete!.toJson();
    }
    return json;
  }

  EliminarEstacionData({
    this.puesto_delete,
  });
}

@immutable
class EliminarEstacionVariables {
  final String id;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EliminarEstacionVariables.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarEstacionVariables otherTyped =
        other as EliminarEstacionVariables;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EliminarEstacionVariables({
    required this.id,
  });
}
