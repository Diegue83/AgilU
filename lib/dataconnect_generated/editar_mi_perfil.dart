part of 'agilu.dart';

class EditarMiPerfilVariablesBuilder {
  String nombre;
  Optional<String> _telefono = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  EditarMiPerfilVariablesBuilder telefono(String? t) {
   _telefono.value = t;
   return this;
  }

  EditarMiPerfilVariablesBuilder(this._dataConnect, {required  this.nombre,});
  Deserializer<EditarMiPerfilData> dataDeserializer = (dynamic json)  => EditarMiPerfilData.fromJson(jsonDecode(json));
  Serializer<EditarMiPerfilVariables> varsSerializer = (EditarMiPerfilVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditarMiPerfilData, EditarMiPerfilVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditarMiPerfilData, EditarMiPerfilVariables> ref() {
    EditarMiPerfilVariables vars= EditarMiPerfilVariables(nombre: nombre,telefono: _telefono,);
    return _dataConnect.mutation("EditarMiPerfil", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditarMiPerfilUsuarioUpdate {
  final String id;
  EditarMiPerfilUsuarioUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiPerfilUsuarioUpdate otherTyped = other as EditarMiPerfilUsuarioUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EditarMiPerfilUsuarioUpdate({
    required this.id,
  });
}

@immutable
class EditarMiPerfilData {
  final EditarMiPerfilUsuarioUpdate? usuario_update;
  EditarMiPerfilData.fromJson(dynamic json):
  
  usuario_update = json['usuario_update'] == null ? null : EditarMiPerfilUsuarioUpdate.fromJson(json['usuario_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiPerfilData otherTyped = other as EditarMiPerfilData;
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

  EditarMiPerfilData({
    this.usuario_update,
  });
}

@immutable
class EditarMiPerfilVariables {
  final String nombre;
  late final Optional<String>telefono;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditarMiPerfilVariables.fromJson(Map<String, dynamic> json):
  
  nombre = nativeFromJson<String>(json['nombre']) {
  
  
  
    telefono = Optional.optional(nativeFromJson, nativeToJson);
    telefono.value = json['telefono'] == null ? null : nativeFromJson<String>(json['telefono']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiPerfilVariables otherTyped = other as EditarMiPerfilVariables;
    return nombre == otherTyped.nombre && 
    telefono == otherTyped.telefono;
    
  }
  @override
  int get hashCode => Object.hashAll([nombre.hashCode, telefono.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    if(telefono.state == OptionalState.set) {
      json['telefono'] = telefono.toJson();
    }
    return json;
  }

  EditarMiPerfilVariables({
    required this.nombre,
    required this.telefono,
  });
}

