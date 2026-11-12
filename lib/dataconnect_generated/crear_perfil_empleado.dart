part of 'agilu.dart';

class CrearPerfilEmpleadoVariablesBuilder {
  String nombre;
  Optional<String> _telefono = Optional.optional(nativeFromJson, nativeToJson);
  String cafeteriaId;

  final FirebaseDataConnect _dataConnect;  CrearPerfilEmpleadoVariablesBuilder telefono(String? t) {
   _telefono.value = t;
   return this;
  }

  CrearPerfilEmpleadoVariablesBuilder(this._dataConnect, {required  this.nombre,required  this.cafeteriaId,});
  Deserializer<CrearPerfilEmpleadoData> dataDeserializer = (dynamic json)  => CrearPerfilEmpleadoData.fromJson(jsonDecode(json));
  Serializer<CrearPerfilEmpleadoVariables> varsSerializer = (CrearPerfilEmpleadoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearPerfilEmpleadoData, CrearPerfilEmpleadoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearPerfilEmpleadoData, CrearPerfilEmpleadoVariables> ref() {
    CrearPerfilEmpleadoVariables vars= CrearPerfilEmpleadoVariables(nombre: nombre,telefono: _telefono,cafeteriaId: cafeteriaId,);
    return _dataConnect.mutation("CrearPerfilEmpleado", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearPerfilEmpleadoUsuarioInsert {
  final String id;
  CrearPerfilEmpleadoUsuarioInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPerfilEmpleadoUsuarioInsert otherTyped = other as CrearPerfilEmpleadoUsuarioInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CrearPerfilEmpleadoUsuarioInsert({
    required this.id,
  });
}

@immutable
class CrearPerfilEmpleadoAutenticacionInsert {
  final String firebaseAuthUid;
  CrearPerfilEmpleadoAutenticacionInsert.fromJson(dynamic json):
  
  firebaseAuthUid = nativeFromJson<String>(json['firebaseAuthUid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPerfilEmpleadoAutenticacionInsert otherTyped = other as CrearPerfilEmpleadoAutenticacionInsert;
    return firebaseAuthUid == otherTyped.firebaseAuthUid;
    
  }
  @override
  int get hashCode => firebaseAuthUid.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['firebaseAuthUid'] = nativeToJson<String>(firebaseAuthUid);
    return json;
  }

  CrearPerfilEmpleadoAutenticacionInsert({
    required this.firebaseAuthUid,
  });
}

@immutable
class CrearPerfilEmpleadoSolicitudEmpleoInsert {
  final String usuarioId;
  CrearPerfilEmpleadoSolicitudEmpleoInsert.fromJson(dynamic json):
  
  usuarioId = nativeFromJson<String>(json['usuarioId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPerfilEmpleadoSolicitudEmpleoInsert otherTyped = other as CrearPerfilEmpleadoSolicitudEmpleoInsert;
    return usuarioId == otherTyped.usuarioId;
    
  }
  @override
  int get hashCode => usuarioId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuarioId'] = nativeToJson<String>(usuarioId);
    return json;
  }

  CrearPerfilEmpleadoSolicitudEmpleoInsert({
    required this.usuarioId,
  });
}

@immutable
class CrearPerfilEmpleadoData {
  final CrearPerfilEmpleadoUsuarioInsert usuario_insert;
  final CrearPerfilEmpleadoAutenticacionInsert autenticacion_insert;
  final CrearPerfilEmpleadoSolicitudEmpleoInsert solicitudEmpleo_insert;
  CrearPerfilEmpleadoData.fromJson(dynamic json):
  
  usuario_insert = CrearPerfilEmpleadoUsuarioInsert.fromJson(json['usuario_insert']),
  autenticacion_insert = CrearPerfilEmpleadoAutenticacionInsert.fromJson(json['autenticacion_insert']),
  solicitudEmpleo_insert = CrearPerfilEmpleadoSolicitudEmpleoInsert.fromJson(json['solicitudEmpleo_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPerfilEmpleadoData otherTyped = other as CrearPerfilEmpleadoData;
    return usuario_insert == otherTyped.usuario_insert && 
    autenticacion_insert == otherTyped.autenticacion_insert && 
    solicitudEmpleo_insert == otherTyped.solicitudEmpleo_insert;
    
  }
  @override
  int get hashCode => Object.hashAll([usuario_insert.hashCode, autenticacion_insert.hashCode, solicitudEmpleo_insert.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuario_insert'] = usuario_insert.toJson();
    json['autenticacion_insert'] = autenticacion_insert.toJson();
    json['solicitudEmpleo_insert'] = solicitudEmpleo_insert.toJson();
    return json;
  }

  CrearPerfilEmpleadoData({
    required this.usuario_insert,
    required this.autenticacion_insert,
    required this.solicitudEmpleo_insert,
  });
}

@immutable
class CrearPerfilEmpleadoVariables {
  final String nombre;
  late final Optional<String>telefono;
  final String cafeteriaId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearPerfilEmpleadoVariables.fromJson(Map<String, dynamic> json):
  
  nombre = nativeFromJson<String>(json['nombre']),
  cafeteriaId = nativeFromJson<String>(json['cafeteriaId']) {
  
  
  
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

    final CrearPerfilEmpleadoVariables otherTyped = other as CrearPerfilEmpleadoVariables;
    return nombre == otherTyped.nombre && 
    telefono == otherTyped.telefono && 
    cafeteriaId == otherTyped.cafeteriaId;
    
  }
  @override
  int get hashCode => Object.hashAll([nombre.hashCode, telefono.hashCode, cafeteriaId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    if(telefono.state == OptionalState.set) {
      json['telefono'] = telefono.toJson();
    }
    json['cafeteriaId'] = nativeToJson<String>(cafeteriaId);
    return json;
  }

  CrearPerfilEmpleadoVariables({
    required this.nombre,
    required this.telefono,
    required this.cafeteriaId,
  });
}

