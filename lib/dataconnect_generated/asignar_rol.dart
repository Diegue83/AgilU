part of 'agilu.dart';

class AsignarRolVariablesBuilder {
  String correo;
  String rol;
  Optional<String> _cafeteriaId = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  AsignarRolVariablesBuilder cafeteriaId(String? t) {
   _cafeteriaId.value = t;
   return this;
  }

  AsignarRolVariablesBuilder(this._dataConnect, {required  this.correo,required  this.rol,});
  Deserializer<AsignarRolData> dataDeserializer = (dynamic json)  => AsignarRolData.fromJson(jsonDecode(json));
  Serializer<AsignarRolVariables> varsSerializer = (AsignarRolVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AsignarRolData, AsignarRolVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AsignarRolData, AsignarRolVariables> ref() {
    AsignarRolVariables vars= AsignarRolVariables(correo: correo,rol: rol,cafeteriaId: _cafeteriaId,);
    return _dataConnect.mutation("AsignarRol", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AsignarRolUsuarioUpdate {
  final String id;
  AsignarRolUsuarioUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AsignarRolUsuarioUpdate otherTyped = other as AsignarRolUsuarioUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AsignarRolUsuarioUpdate({
    required this.id,
  });
}

@immutable
class AsignarRolData {
  final AsignarRolUsuarioUpdate? usuario_update;
  AsignarRolData.fromJson(dynamic json):
  
  usuario_update = json['usuario_update'] == null ? null : AsignarRolUsuarioUpdate.fromJson(json['usuario_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AsignarRolData otherTyped = other as AsignarRolData;
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

  AsignarRolData({
    this.usuario_update,
  });
}

@immutable
class AsignarRolVariables {
  final String correo;
  final String rol;
  late final Optional<String>cafeteriaId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AsignarRolVariables.fromJson(Map<String, dynamic> json):
  
  correo = nativeFromJson<String>(json['correo']),
  rol = nativeFromJson<String>(json['rol']) {
  
  
  
  
    cafeteriaId = Optional.optional(nativeFromJson, nativeToJson);
    cafeteriaId.value = json['cafeteriaId'] == null ? null : nativeFromJson<String>(json['cafeteriaId']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AsignarRolVariables otherTyped = other as AsignarRolVariables;
    return correo == otherTyped.correo && 
    rol == otherTyped.rol && 
    cafeteriaId == otherTyped.cafeteriaId;
    
  }
  @override
  int get hashCode => Object.hashAll([correo.hashCode, rol.hashCode, cafeteriaId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['correo'] = nativeToJson<String>(correo);
    json['rol'] = nativeToJson<String>(rol);
    if(cafeteriaId.state == OptionalState.set) {
      json['cafeteriaId'] = cafeteriaId.toJson();
    }
    return json;
  }

  AsignarRolVariables({
    required this.correo,
    required this.rol,
    required this.cafeteriaId,
  });
}

