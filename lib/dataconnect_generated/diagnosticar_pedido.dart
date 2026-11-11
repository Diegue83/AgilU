part of 'agilu.dart';

class DiagnosticarPedidoVariablesBuilder {
  String cafeteriaId;
  Timestamp recogerA;
  AnyValue items;

  final FirebaseDataConnect _dataConnect;
  DiagnosticarPedidoVariablesBuilder(
    this._dataConnect, {
    required this.cafeteriaId,
    required this.recogerA,
    required this.items,
  });
  Deserializer<DiagnosticarPedidoData> dataDeserializer =
      (dynamic json) => DiagnosticarPedidoData.fromJson(jsonDecode(json));
  Serializer<DiagnosticarPedidoVariables> varsSerializer =
      (DiagnosticarPedidoVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<DiagnosticarPedidoData, DiagnosticarPedidoVariables>>
      execute() {
    return ref().execute();
  }

  QueryRef<DiagnosticarPedidoData, DiagnosticarPedidoVariables> ref() {
    DiagnosticarPedidoVariables vars = DiagnosticarPedidoVariables(
      cafeteriaId: cafeteriaId,
      recogerA: recogerA,
      items: items,
    );
    return _dataConnect.query(
        "DiagnosticarPedido", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DiagnosticarPedidoData {
  final AnyValue? diagnostico;
  DiagnosticarPedidoData.fromJson(dynamic json)
      : diagnostico = json['diagnostico'] == null
            ? null
            : AnyValue.fromJson(json['diagnostico']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DiagnosticarPedidoData otherTyped = other as DiagnosticarPedidoData;
    return diagnostico == otherTyped.diagnostico;
  }

  @override
  int get hashCode => diagnostico.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (diagnostico != null) {
      json['diagnostico'] = diagnostico!.toJson();
    }
    return json;
  }

  DiagnosticarPedidoData({
    this.diagnostico,
  });
}

@immutable
class DiagnosticarPedidoVariables {
  final String cafeteriaId;
  final Timestamp recogerA;
  final AnyValue items;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DiagnosticarPedidoVariables.fromJson(Map<String, dynamic> json)
      : cafeteriaId = nativeFromJson<String>(json['cafeteriaId']),
        recogerA = Timestamp.fromJson(json['recogerA']),
        items = AnyValue.fromJson(json['items']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DiagnosticarPedidoVariables otherTyped =
        other as DiagnosticarPedidoVariables;
    return cafeteriaId == otherTyped.cafeteriaId &&
        recogerA == otherTyped.recogerA &&
        items == otherTyped.items;
  }

  @override
  int get hashCode =>
      Object.hashAll([cafeteriaId.hashCode, recogerA.hashCode, items.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cafeteriaId'] = nativeToJson<String>(cafeteriaId);
    json['recogerA'] = recogerA.toJson();
    json['items'] = items.toJson();
    return json;
  }

  DiagnosticarPedidoVariables({
    required this.cafeteriaId,
    required this.recogerA,
    required this.items,
  });
}
