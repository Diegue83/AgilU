part of 'agilu.dart';

class MiPerfilVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  MiPerfilVariablesBuilder(this._dataConnect, );
  Deserializer<MiPerfilData> dataDeserializer = (dynamic json)  => MiPerfilData.fromJson(jsonDecode(json));
  
  Future<QueryResult<MiPerfilData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MiPerfilData, void> ref() {
    
    return _dataConnect.query("MiPerfil", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MiPerfilAutenticacion {
  final String correoElectronico;
  final MiPerfilAutenticacionUsuario usuario;
  MiPerfilAutenticacion.fromJson(dynamic json):
  
  correoElectronico = nativeFromJson<String>(json['correoElectronico']),
  usuario = MiPerfilAutenticacionUsuario.fromJson(json['usuario']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacion otherTyped = other as MiPerfilAutenticacion;
    return correoElectronico == otherTyped.correoElectronico && 
    usuario == otherTyped.usuario;
    
  }
  @override
  int get hashCode => Object.hashAll([correoElectronico.hashCode, usuario.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['correoElectronico'] = nativeToJson<String>(correoElectronico);
    json['usuario'] = usuario.toJson();
    return json;
  }

  MiPerfilAutenticacion({
    required this.correoElectronico,
    required this.usuario,
  });
}

@immutable
class MiPerfilAutenticacionUsuario {
  final String id;
  final String nombre;
  final String? numeroDeTelefono;
  final MiPerfilAutenticacionUsuarioRol? rol;
  final MiPerfilAutenticacionUsuarioCafeteria? cafeteria;
  final MiPerfilAutenticacionUsuarioPuesto? puesto;
  final bool avisoPedidoListo;
  final bool avisoPagos;
  final bool avisoPersonal;
  final MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuario? solicitudEmpleo_on_usuario;
  MiPerfilAutenticacionUsuario.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  numeroDeTelefono = json['numeroDeTelefono'] == null ? null : nativeFromJson<String>(json['numeroDeTelefono']),
  rol = json['rol'] == null ? null : MiPerfilAutenticacionUsuarioRol.fromJson(json['rol']),
  cafeteria = json['cafeteria'] == null ? null : MiPerfilAutenticacionUsuarioCafeteria.fromJson(json['cafeteria']),
  puesto = json['puesto'] == null ? null : MiPerfilAutenticacionUsuarioPuesto.fromJson(json['puesto']),
  avisoPedidoListo = nativeFromJson<bool>(json['avisoPedidoListo']),
  avisoPagos = nativeFromJson<bool>(json['avisoPagos']),
  avisoPersonal = nativeFromJson<bool>(json['avisoPersonal']),
  solicitudEmpleo_on_usuario = json['solicitudEmpleo_on_usuario'] == null ? null : MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuario.fromJson(json['solicitudEmpleo_on_usuario']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacionUsuario otherTyped = other as MiPerfilAutenticacionUsuario;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    numeroDeTelefono == otherTyped.numeroDeTelefono && 
    rol == otherTyped.rol && 
    cafeteria == otherTyped.cafeteria && 
    puesto == otherTyped.puesto && 
    avisoPedidoListo == otherTyped.avisoPedidoListo && 
    avisoPagos == otherTyped.avisoPagos && 
    avisoPersonal == otherTyped.avisoPersonal && 
    solicitudEmpleo_on_usuario == otherTyped.solicitudEmpleo_on_usuario;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, numeroDeTelefono.hashCode, rol.hashCode, cafeteria.hashCode, puesto.hashCode, avisoPedidoListo.hashCode, avisoPagos.hashCode, avisoPersonal.hashCode, solicitudEmpleo_on_usuario.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    if (numeroDeTelefono != null) {
      json['numeroDeTelefono'] = nativeToJson<String?>(numeroDeTelefono);
    }
    if (rol != null) {
      json['rol'] = rol!.toJson();
    }
    if (cafeteria != null) {
      json['cafeteria'] = cafeteria!.toJson();
    }
    if (puesto != null) {
      json['puesto'] = puesto!.toJson();
    }
    json['avisoPedidoListo'] = nativeToJson<bool>(avisoPedidoListo);
    json['avisoPagos'] = nativeToJson<bool>(avisoPagos);
    json['avisoPersonal'] = nativeToJson<bool>(avisoPersonal);
    if (solicitudEmpleo_on_usuario != null) {
      json['solicitudEmpleo_on_usuario'] = solicitudEmpleo_on_usuario!.toJson();
    }
    return json;
  }

  MiPerfilAutenticacionUsuario({
    required this.id,
    required this.nombre,
    this.numeroDeTelefono,
    this.rol,
    this.cafeteria,
    this.puesto,
    required this.avisoPedidoListo,
    required this.avisoPagos,
    required this.avisoPersonal,
    this.solicitudEmpleo_on_usuario,
  });
}

@immutable
class MiPerfilAutenticacionUsuarioRol {
  final String nombre;
  final List<MiPerfilAutenticacionUsuarioRolRolPermisosOnRol> rolPermisos_on_rol;
  MiPerfilAutenticacionUsuarioRol.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']),
  rolPermisos_on_rol = (json['rolPermisos_on_rol'] as List<dynamic>)
        .map((e) => MiPerfilAutenticacionUsuarioRolRolPermisosOnRol.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacionUsuarioRol otherTyped = other as MiPerfilAutenticacionUsuarioRol;
    return nombre == otherTyped.nombre && 
    rolPermisos_on_rol == otherTyped.rolPermisos_on_rol;
    
  }
  @override
  int get hashCode => Object.hashAll([nombre.hashCode, rolPermisos_on_rol.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    json['rolPermisos_on_rol'] = rolPermisos_on_rol.map((e) => e.toJson()).toList();
    return json;
  }

  MiPerfilAutenticacionUsuarioRol({
    required this.nombre,
    required this.rolPermisos_on_rol,
  });
}

@immutable
class MiPerfilAutenticacionUsuarioRolRolPermisosOnRol {
  final MiPerfilAutenticacionUsuarioRolRolPermisosOnRolPermiso permiso;
  MiPerfilAutenticacionUsuarioRolRolPermisosOnRol.fromJson(dynamic json):
  
  permiso = MiPerfilAutenticacionUsuarioRolRolPermisosOnRolPermiso.fromJson(json['permiso']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacionUsuarioRolRolPermisosOnRol otherTyped = other as MiPerfilAutenticacionUsuarioRolRolPermisosOnRol;
    return permiso == otherTyped.permiso;
    
  }
  @override
  int get hashCode => permiso.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['permiso'] = permiso.toJson();
    return json;
  }

  MiPerfilAutenticacionUsuarioRolRolPermisosOnRol({
    required this.permiso,
  });
}

@immutable
class MiPerfilAutenticacionUsuarioRolRolPermisosOnRolPermiso {
  final String codigoAccion;
  MiPerfilAutenticacionUsuarioRolRolPermisosOnRolPermiso.fromJson(dynamic json):
  
  codigoAccion = nativeFromJson<String>(json['codigoAccion']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacionUsuarioRolRolPermisosOnRolPermiso otherTyped = other as MiPerfilAutenticacionUsuarioRolRolPermisosOnRolPermiso;
    return codigoAccion == otherTyped.codigoAccion;
    
  }
  @override
  int get hashCode => codigoAccion.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['codigoAccion'] = nativeToJson<String>(codigoAccion);
    return json;
  }

  MiPerfilAutenticacionUsuarioRolRolPermisosOnRolPermiso({
    required this.codigoAccion,
  });
}

@immutable
class MiPerfilAutenticacionUsuarioCafeteria {
  final String id;
  final String nombre;
  MiPerfilAutenticacionUsuarioCafeteria.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacionUsuarioCafeteria otherTyped = other as MiPerfilAutenticacionUsuarioCafeteria;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  MiPerfilAutenticacionUsuarioCafeteria({
    required this.id,
    required this.nombre,
  });
}

@immutable
class MiPerfilAutenticacionUsuarioPuesto {
  final String id;
  final String nombre;
  MiPerfilAutenticacionUsuarioPuesto.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacionUsuarioPuesto otherTyped = other as MiPerfilAutenticacionUsuarioPuesto;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  MiPerfilAutenticacionUsuarioPuesto({
    required this.id,
    required this.nombre,
  });
}

@immutable
class MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuario {
  final MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuarioCafeteria cafeteria;
  MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuario.fromJson(dynamic json):
  
  cafeteria = MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuarioCafeteria.fromJson(json['cafeteria']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuario otherTyped = other as MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuario;
    return cafeteria == otherTyped.cafeteria;
    
  }
  @override
  int get hashCode => cafeteria.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cafeteria'] = cafeteria.toJson();
    return json;
  }

  MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuario({
    required this.cafeteria,
  });
}

@immutable
class MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuarioCafeteria {
  final String nombre;
  MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuarioCafeteria.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuarioCafeteria otherTyped = other as MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuarioCafeteria;
    return nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => nombre.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  MiPerfilAutenticacionUsuarioSolicitudEmpleoOnUsuarioCafeteria({
    required this.nombre,
  });
}

@immutable
class MiPerfilData {
  final MiPerfilAutenticacion? autenticacion;
  MiPerfilData.fromJson(dynamic json):
  
  autenticacion = json['autenticacion'] == null ? null : MiPerfilAutenticacion.fromJson(json['autenticacion']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPerfilData otherTyped = other as MiPerfilData;
    return autenticacion == otherTyped.autenticacion;
    
  }
  @override
  int get hashCode => autenticacion.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (autenticacion != null) {
      json['autenticacion'] = autenticacion!.toJson();
    }
    return json;
  }

  MiPerfilData({
    this.autenticacion,
  });
}

