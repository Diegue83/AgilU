part of 'agilu.dart';

class OcupacionFranjasVariablesBuilder {
  String cafeteriaId;

  final FirebaseDataConnect _dataConnect;
  OcupacionFranjasVariablesBuilder(
    this._dataConnect, {
    required this.cafeteriaId,
  });
  Deserializer<OcupacionFranjasData> dataDeserializer =
      (dynamic json) => OcupacionFranjasData.fromJson(jsonDecode(json));
  Serializer<OcupacionFranjasVariables> varsSerializer =
      (OcupacionFranjasVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<OcupacionFranjasData, OcupacionFranjasVariables>>
      execute() {
    return ref().execute();
  }

  QueryRef<OcupacionFranjasData, OcupacionFranjasVariables> ref() {
    OcupacionFranjasVariables vars = OcupacionFranjasVariables(
      cafeteriaId: cafeteriaId,
    );
    return _dataConnect.query(
        "OcupacionFranjas", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class OcupacionFranjasData {
  final List<AnyValue>? franjas;
  OcupacionFranjasData.fromJson(dynamic json)
      : franjas = json['franjas'] == null
            ? null
            : (json['franjas'] as List<dynamic>)
                .map((e) => AnyValue.fromJson(e))
                .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final OcupacionFranjasData otherTyped = other as OcupacionFranjasData;
    return franjas == otherTyped.franjas;
  }

  @override
  int get hashCode => franjas.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (franjas != null) {
      json['franjas'] = franjas?.map((e) => e!.toJson()).toList();
    }
    return json;
  }

  OcupacionFranjasData({
    this.franjas,
  });
}

@immutable
class OcupacionFranjasVariables {
  final String cafeteriaId;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  OcupacionFranjasVariables.fromJson(Map<String, dynamic> json)
      : cafeteriaId = nativeFromJson<String>(json['cafeteriaId']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final OcupacionFranjasVariables otherTyped =
        other as OcupacionFranjasVariables;
    return cafeteriaId == otherTyped.cafeteriaId;
  }

  @override
  int get hashCode => cafeteriaId.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cafeteriaId'] = nativeToJson<String>(cafeteriaId);
    return json;
  }

  OcupacionFranjasVariables({
    required this.cafeteriaId,
  });
}
