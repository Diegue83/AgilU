part of 'agilu.dart';

class AvanzarPedidoVariablesBuilder {
  String id;
  String estado;

  final FirebaseDataConnect _dataConnect;
  AvanzarPedidoVariablesBuilder(
    this._dataConnect, {
    required this.id,
    required this.estado,
  });
  Deserializer<AvanzarPedidoData> dataDeserializer =
      (dynamic json) => AvanzarPedidoData.fromJson(jsonDecode(json));
  Serializer<AvanzarPedidoVariables> varsSerializer =
      (AvanzarPedidoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AvanzarPedidoData, AvanzarPedidoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AvanzarPedidoData, AvanzarPedidoVariables> ref() {
    AvanzarPedidoVariables vars = AvanzarPedidoVariables(
      id: id,
      estado: estado,
    );
    return _dataConnect.mutation(
        "AvanzarPedido", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AvanzarPedidoData {
  final int? execute_;
  AvanzarPedidoData.fromJson(dynamic json)
      : execute_ = json['_execute'] == null
            ? null
            : nativeFromJson<int>(json['_execute']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AvanzarPedidoData otherTyped = other as AvanzarPedidoData;
    return execute_ == otherTyped.execute_;
  }

  @override
  int get hashCode => execute_.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (execute_ != null) {
      json['_execute'] = nativeToJson<int?>(execute_);
    }
    return json;
  }

  AvanzarPedidoData({
    this.execute_,
  });
}

@immutable
class AvanzarPedidoVariables {
  final String id;
  final String estado;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AvanzarPedidoVariables.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']),
        estado = nativeFromJson<String>(json['estado']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AvanzarPedidoVariables otherTyped = other as AvanzarPedidoVariables;
    return id == otherTyped.id && estado == otherTyped.estado;
  }

  @override
  int get hashCode => Object.hashAll([id.hashCode, estado.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['estado'] = nativeToJson<String>(estado);
    return json;
  }

  AvanzarPedidoVariables({
    required this.id,
    required this.estado,
  });
}
