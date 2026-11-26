part of 'agilu.dart';

class CobrarAdeudoVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  CobrarAdeudoVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<CobrarAdeudoData> dataDeserializer = (dynamic json)  => CobrarAdeudoData.fromJson(jsonDecode(json));
  Serializer<CobrarAdeudoVariables> varsSerializer = (CobrarAdeudoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CobrarAdeudoData, CobrarAdeudoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CobrarAdeudoData, CobrarAdeudoVariables> ref() {
    CobrarAdeudoVariables vars= CobrarAdeudoVariables(id: id,);
    return _dataConnect.mutation("CobrarAdeudo", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CobrarAdeudoPedidoUpdate {
  final String id;
  CobrarAdeudoPedidoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CobrarAdeudoPedidoUpdate otherTyped = other as CobrarAdeudoPedidoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CobrarAdeudoPedidoUpdate({
    required this.id,
  });
}

@immutable
class CobrarAdeudoData {
  final CobrarAdeudoPedidoUpdate? pedido_update;
  CobrarAdeudoData.fromJson(dynamic json):
  
  pedido_update = json['pedido_update'] == null ? null : CobrarAdeudoPedidoUpdate.fromJson(json['pedido_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CobrarAdeudoData otherTyped = other as CobrarAdeudoData;
    return pedido_update == otherTyped.pedido_update;
    
  }
  @override
  int get hashCode => pedido_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (pedido_update != null) {
      json['pedido_update'] = pedido_update!.toJson();
    }
    return json;
  }

  CobrarAdeudoData({
    this.pedido_update,
  });
}

@immutable
class CobrarAdeudoVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CobrarAdeudoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CobrarAdeudoVariables otherTyped = other as CobrarAdeudoVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CobrarAdeudoVariables({
    required this.id,
  });
}

