part of 'agilu.dart';

class CancelarMiPedidoVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  CancelarMiPedidoVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<CancelarMiPedidoData> dataDeserializer = (dynamic json)  => CancelarMiPedidoData.fromJson(jsonDecode(json));
  Serializer<CancelarMiPedidoVariables> varsSerializer = (CancelarMiPedidoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CancelarMiPedidoData, CancelarMiPedidoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CancelarMiPedidoData, CancelarMiPedidoVariables> ref() {
    CancelarMiPedidoVariables vars= CancelarMiPedidoVariables(id: id,);
    return _dataConnect.mutation("CancelarMiPedido", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CancelarMiPedidoData {
  final AnyValue? resultado;
  CancelarMiPedidoData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CancelarMiPedidoData otherTyped = other as CancelarMiPedidoData;
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

  CancelarMiPedidoData({
    this.resultado,
  });
}

@immutable
class CancelarMiPedidoVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CancelarMiPedidoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CancelarMiPedidoVariables otherTyped = other as CancelarMiPedidoVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CancelarMiPedidoVariables({
    required this.id,
  });
}

