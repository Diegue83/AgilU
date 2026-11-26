part of 'agilu.dart';

class EditarMisAvisosVariablesBuilder {
  bool pedidoListo;
  bool pagos;
  bool personal;

  final FirebaseDataConnect _dataConnect;
  EditarMisAvisosVariablesBuilder(this._dataConnect, {required  this.pedidoListo,required  this.pagos,required  this.personal,});
  Deserializer<EditarMisAvisosData> dataDeserializer = (dynamic json)  => EditarMisAvisosData.fromJson(jsonDecode(json));
  Serializer<EditarMisAvisosVariables> varsSerializer = (EditarMisAvisosVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditarMisAvisosData, EditarMisAvisosVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditarMisAvisosData, EditarMisAvisosVariables> ref() {
    EditarMisAvisosVariables vars= EditarMisAvisosVariables(pedidoListo: pedidoListo,pagos: pagos,personal: personal,);
    return _dataConnect.mutation("EditarMisAvisos", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditarMisAvisosUsuarioUpdate {
  final String id;
  EditarMisAvisosUsuarioUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMisAvisosUsuarioUpdate otherTyped = other as EditarMisAvisosUsuarioUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EditarMisAvisosUsuarioUpdate({
    required this.id,
  });
}

@immutable
class EditarMisAvisosData {
  final EditarMisAvisosUsuarioUpdate? usuario_update;
  EditarMisAvisosData.fromJson(dynamic json):
  
  usuario_update = json['usuario_update'] == null ? null : EditarMisAvisosUsuarioUpdate.fromJson(json['usuario_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMisAvisosData otherTyped = other as EditarMisAvisosData;
    return usuario_update == otherTyped.usuario_update;
    
  }
  @override
  int get hashCode => usuario_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (usuario_update != null) {
      json['usuario_update'] = usuario_update!.toJson();
    }
    return json;
  }

  EditarMisAvisosData({
    this.usuario_update,
  });
}

@immutable
class EditarMisAvisosVariables {
  final bool pedidoListo;
  final bool pagos;
  final bool personal;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditarMisAvisosVariables.fromJson(Map<String, dynamic> json):
  
  pedidoListo = nativeFromJson<bool>(json['pedidoListo']),
  pagos = nativeFromJson<bool>(json['pagos']),
  personal = nativeFromJson<bool>(json['personal']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMisAvisosVariables otherTyped = other as EditarMisAvisosVariables;
    return pedidoListo == otherTyped.pedidoListo && 
    pagos == otherTyped.pagos && 
    personal == otherTyped.personal;
    
  }
  @override
  int get hashCode => Object.hashAll([pedidoListo.hashCode, pagos.hashCode, personal.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pedidoListo'] = nativeToJson<bool>(pedidoListo);
    json['pagos'] = nativeToJson<bool>(pagos);
    json['personal'] = nativeToJson<bool>(personal);
    return json;
  }

  EditarMisAvisosVariables({
    required this.pedidoListo,
    required this.pagos,
    required this.personal,
  });
}

