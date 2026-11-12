part of 'agilu.dart';

class EliminarMiCuentaVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  EliminarMiCuentaVariablesBuilder(this._dataConnect, );
  Deserializer<EliminarMiCuentaData> dataDeserializer = (dynamic json)  => EliminarMiCuentaData.fromJson(jsonDecode(json));
  
  Future<OperationResult<EliminarMiCuentaData, void>> execute() {
    return ref().execute();
  }

  MutationRef<EliminarMiCuentaData, void> ref() {
    
    return _dataConnect.mutation("EliminarMiCuenta", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class EliminarMiCuentaUsuarioUpdate {
  final String id;
  EliminarMiCuentaUsuarioUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarMiCuentaUsuarioUpdate otherTyped = other as EliminarMiCuentaUsuarioUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EliminarMiCuentaUsuarioUpdate({
    required this.id,
  });
}

@immutable
class EliminarMiCuentaAutenticacionDelete {
  final String firebaseAuthUid;
  EliminarMiCuentaAutenticacionDelete.fromJson(dynamic json):
  
  firebaseAuthUid = nativeFromJson<String>(json['firebaseAuthUid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarMiCuentaAutenticacionDelete otherTyped = other as EliminarMiCuentaAutenticacionDelete;
    return firebaseAuthUid == otherTyped.firebaseAuthUid;
    
  }
  @override
  int get hashCode => firebaseAuthUid.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['firebaseAuthUid'] = nativeToJson<String>(firebaseAuthUid);
    return json;
  }

  EliminarMiCuentaAutenticacionDelete({
    required this.firebaseAuthUid,
  });
}

@immutable
class EliminarMiCuentaData {
  final int dispositivoToken_deleteMany;
  final int notificacion_deleteMany;
  final EliminarMiCuentaUsuarioUpdate? usuario_update;
  final EliminarMiCuentaAutenticacionDelete? autenticacion_delete;
  EliminarMiCuentaData.fromJson(dynamic json):
  
  dispositivoToken_deleteMany = nativeFromJson<int>(json['dispositivoToken_deleteMany']),
  notificacion_deleteMany = nativeFromJson<int>(json['notificacion_deleteMany']),
  usuario_update = json['usuario_update'] == null ? null : EliminarMiCuentaUsuarioUpdate.fromJson(json['usuario_update']),
  autenticacion_delete = json['autenticacion_delete'] == null ? null : EliminarMiCuentaAutenticacionDelete.fromJson(json['autenticacion_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarMiCuentaData otherTyped = other as EliminarMiCuentaData;
    return dispositivoToken_deleteMany == otherTyped.dispositivoToken_deleteMany && 
    notificacion_deleteMany == otherTyped.notificacion_deleteMany && 
    usuario_update == otherTyped.usuario_update && 
    autenticacion_delete == otherTyped.autenticacion_delete;
    
  }
  @override
  int get hashCode => Object.hashAll([dispositivoToken_deleteMany.hashCode, notificacion_deleteMany.hashCode, usuario_update.hashCode, autenticacion_delete.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['dispositivoToken_deleteMany'] = nativeToJson<int>(dispositivoToken_deleteMany);
    json['notificacion_deleteMany'] = nativeToJson<int>(notificacion_deleteMany);
    if (usuario_update != null) {
      json['usuario_update'] = usuario_update!.toJson();
    }
    if (autenticacion_delete != null) {
      json['autenticacion_delete'] = autenticacion_delete!.toJson();
    }
    return json;
  }

  EliminarMiCuentaData({
    required this.dispositivoToken_deleteMany,
    required this.notificacion_deleteMany,
    this.usuario_update,
    this.autenticacion_delete,
  });
}

