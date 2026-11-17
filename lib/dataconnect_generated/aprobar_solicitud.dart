part of 'agilu.dart';

class AprobarSolicitudVariablesBuilder {
  String usuarioId;

  final FirebaseDataConnect _dataConnect;
  AprobarSolicitudVariablesBuilder(this._dataConnect, {required  this.usuarioId,});
  Deserializer<AprobarSolicitudData> dataDeserializer = (dynamic json)  => AprobarSolicitudData.fromJson(jsonDecode(json));
  Serializer<AprobarSolicitudVariables> varsSerializer = (AprobarSolicitudVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AprobarSolicitudData, AprobarSolicitudVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AprobarSolicitudData, AprobarSolicitudVariables> ref() {
    AprobarSolicitudVariables vars= AprobarSolicitudVariables(usuarioId: usuarioId,);
    return _dataConnect.mutation("AprobarSolicitud", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AprobarSolicitudUsuarioUpdate {
  final String id;
  AprobarSolicitudUsuarioUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AprobarSolicitudUsuarioUpdate otherTyped = other as AprobarSolicitudUsuarioUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AprobarSolicitudUsuarioUpdate({
    required this.id,
  });
}

@immutable
class AprobarSolicitudSolicitudEmpleoDelete {
  final String usuarioId;
  AprobarSolicitudSolicitudEmpleoDelete.fromJson(dynamic json):
  
  usuarioId = nativeFromJson<String>(json['usuarioId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AprobarSolicitudSolicitudEmpleoDelete otherTyped = other as AprobarSolicitudSolicitudEmpleoDelete;
    return usuarioId == otherTyped.usuarioId;
    
  }
  @override
  int get hashCode => usuarioId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuarioId'] = nativeToJson<String>(usuarioId);
    return json;
  }

  AprobarSolicitudSolicitudEmpleoDelete({
    required this.usuarioId,
  });
}

@immutable
class AprobarSolicitudData {
  final AprobarSolicitudUsuarioUpdate? usuario_update;
  final AprobarSolicitudSolicitudEmpleoDelete? solicitudEmpleo_delete;
  AprobarSolicitudData.fromJson(dynamic json):
  
  usuario_update = json['usuario_update'] == null ? null : AprobarSolicitudUsuarioUpdate.fromJson(json['usuario_update']),
  solicitudEmpleo_delete = json['solicitudEmpleo_delete'] == null ? null : AprobarSolicitudSolicitudEmpleoDelete.fromJson(json['solicitudEmpleo_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AprobarSolicitudData otherTyped = other as AprobarSolicitudData;
    return usuario_update == otherTyped.usuario_update && 
    solicitudEmpleo_delete == otherTyped.solicitudEmpleo_delete;
    
  }
  @override
  int get hashCode => Object.hashAll([usuario_update.hashCode, solicitudEmpleo_delete.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (usuario_update != null) {
      json['usuario_update'] = usuario_update!.toJson();
    }
    if (solicitudEmpleo_delete != null) {
      json['solicitudEmpleo_delete'] = solicitudEmpleo_delete!.toJson();
    }
    return json;
  }

  AprobarSolicitudData({
    this.usuario_update,
    this.solicitudEmpleo_delete,
  });
}

@immutable
class AprobarSolicitudVariables {
  final String usuarioId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AprobarSolicitudVariables.fromJson(Map<String, dynamic> json):
  
  usuarioId = nativeFromJson<String>(json['usuarioId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AprobarSolicitudVariables otherTyped = other as AprobarSolicitudVariables;
    return usuarioId == otherTyped.usuarioId;
    
  }
  @override
  int get hashCode => usuarioId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuarioId'] = nativeToJson<String>(usuarioId);
    return json;
  }

  AprobarSolicitudVariables({
    required this.usuarioId,
  });
}

