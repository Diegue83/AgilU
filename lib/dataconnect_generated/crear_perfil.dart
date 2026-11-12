part of 'agilu.dart';

class CrearPerfilVariablesBuilder {
  String nombre;
  Optional<String> _telefono = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CrearPerfilVariablesBuilder telefono(String? t) {
   _telefono.value = t;
   return this;
  }

  CrearPerfilVariablesBuilder(this._dataConnect, {required  this.nombre,});
  Deserializer<CrearPerfilData> dataDeserializer = (dynamic json)  => CrearPerfilData.fromJson(jsonDecode(json));
  Serializer<CrearPerfilVariables> varsSerializer = (CrearPerfilVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearPerfilData, CrearPerfilVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearPerfilData, CrearPerfilVariables> ref() {
    CrearPerfilVariables vars= CrearPerfilVariables(nombre: nombre,telefono: _telefono,);
    return _dataConnect.mutation("CrearPerfil", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearPerfilUsuarioInsert {
  final String id;
  CrearPerfilUsuarioInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPerfilUsuarioInsert otherTyped = other as CrearPerfilUsuarioInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CrearPerfilUsuarioInsert({
    required this.id,
  });
}

@immutable
class CrearPerfilAutenticacionInsert {
  final String firebaseAuthUid;
  CrearPerfilAutenticacionInsert.fromJson(dynamic json):
  
  firebaseAuthUid = nativeFromJson<String>(json['firebaseAuthUid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPerfilAutenticacionInsert otherTyped = other as CrearPerfilAutenticacionInsert;
    return firebaseAuthUid == otherTyped.firebaseAuthUid;
    
  }
  @override
  int get hashCode => firebaseAuthUid.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['firebaseAuthUid'] = nativeToJson<String>(firebaseAuthUid);
    return json;
  }

  CrearPerfilAutenticacionInsert({
    required this.firebaseAuthUid,
  });
}

@immutable
class CrearPerfilData {
  final CrearPerfilUsuarioInsert usuario_insert;
  final CrearPerfilAutenticacionInsert autenticacion_insert;
  CrearPerfilData.fromJson(dynamic json):
  
  usuario_insert = CrearPerfilUsuarioInsert.fromJson(json['usuario_insert']),
  autenticacion_insert = CrearPerfilAutenticacionInsert.fromJson(json['autenticacion_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPerfilData otherTyped = other as CrearPerfilData;
    return usuario_insert == otherTyped.usuario_insert && 
    autenticacion_insert == otherTyped.autenticacion_insert;
    
  }
  @override
  int get hashCode => Object.hashAll([usuario_insert.hashCode, autenticacion_insert.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuario_insert'] = usuario_insert.toJson();
    json['autenticacion_insert'] = autenticacion_insert.toJson();
    return json;
  }

  CrearPerfilData({
    required this.usuario_insert,
    required this.autenticacion_insert,
  });
}

@immutable
class CrearPerfilVariables {
  final String nombre;
  late final Optional<String>telefono;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearPerfilVariables.fromJson(Map<String, dynamic> json):
  
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

    final CrearPerfilVariables otherTyped = other as CrearPerfilVariables;
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

  CrearPerfilVariables({
    required this.nombre,
    required this.telefono,
  });
}

