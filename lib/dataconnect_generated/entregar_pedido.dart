part of 'agilu.dart';

class EntregarPedidoVariablesBuilder {
  String id;
  String codigo;

  final FirebaseDataConnect _dataConnect;
  EntregarPedidoVariablesBuilder(
    this._dataConnect, {
    required this.id,
    required this.codigo,
  });
  Deserializer<EntregarPedidoData> dataDeserializer =
      (dynamic json) => EntregarPedidoData.fromJson(jsonDecode(json));
  Serializer<EntregarPedidoVariables> varsSerializer =
      (EntregarPedidoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EntregarPedidoData, EntregarPedidoVariables>>
      execute() {
    return ref().execute();
  }

  MutationRef<EntregarPedidoData, EntregarPedidoVariables> ref() {
    EntregarPedidoVariables vars = EntregarPedidoVariables(
      id: id,
      codigo: codigo,
    );
    return _dataConnect.mutation(
        "EntregarPedido", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EntregarPedidoData {
  final AnyValue? resultado;
  EntregarPedidoData.fromJson(dynamic json)
      : resultado = json['resultado'] == null
            ? null
            : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final EntregarPedidoData otherTyped = other as EntregarPedidoData;
    return resultado == otherTyped.resultado;
  }

  @override
  int get hashCode => resultado.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (resultado != null) {
      json['resultado'] = resultado!.toJson();
    }
    return json;
  }

  EntregarPedidoData({
    this.resultado,
  });
}

@immutable
class EntregarPedidoVariables {
  final String id;
  final String codigo;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EntregarPedidoVariables.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']),
        codigo = nativeFromJson<String>(json['codigo']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final EntregarPedidoVariables otherTyped = other as EntregarPedidoVariables;
    return id == otherTyped.id && codigo == otherTyped.codigo;
  }

  @override
  int get hashCode => Object.hashAll([id.hashCode, codigo.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['codigo'] = nativeToJson<String>(codigo);
    return json;
  }

  EntregarPedidoVariables({
    required this.id,
    required this.codigo,
  });
}
