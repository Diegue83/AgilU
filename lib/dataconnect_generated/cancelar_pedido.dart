part of 'agilu.dart';

class CancelarPedidoVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  CancelarPedidoVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<CancelarPedidoData> dataDeserializer = (dynamic json)  => CancelarPedidoData.fromJson(jsonDecode(json));
  Serializer<CancelarPedidoVariables> varsSerializer = (CancelarPedidoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CancelarPedidoData, CancelarPedidoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CancelarPedidoData, CancelarPedidoVariables> ref() {
    CancelarPedidoVariables vars= CancelarPedidoVariables(id: id,);
    return _dataConnect.mutation("CancelarPedido", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CancelarPedidoData {
  final int? execute_;
  CancelarPedidoData.fromJson(dynamic json):
  
  execute_ = json['_execute'] == null ? null : nativeFromJson<int>(json['_execute']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CancelarPedidoData otherTyped = other as CancelarPedidoData;
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

  CancelarPedidoData({
    this.execute_,
  });
}

@immutable
class CancelarPedidoVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CancelarPedidoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CancelarPedidoVariables otherTyped = other as CancelarPedidoVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CancelarPedidoVariables({
    required this.id,
  });
}

