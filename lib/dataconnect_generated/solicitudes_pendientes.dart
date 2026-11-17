part of 'agilu.dart';

class SolicitudesPendientesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  SolicitudesPendientesVariablesBuilder(this._dataConnect, );
  Deserializer<SolicitudesPendientesData> dataDeserializer = (dynamic json)  => SolicitudesPendientesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<SolicitudesPendientesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<SolicitudesPendientesData, void> ref() {
    
    return _dataConnect.query("SolicitudesPendientes", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class SolicitudesPendientesSolicitudEmpleos {
  final Timestamp fechaSolicitud;
  final SolicitudesPendientesSolicitudEmpleosUsuario usuario;
  SolicitudesPendientesSolicitudEmpleos.fromJson(dynamic json):
  
  fechaSolicitud = Timestamp.fromJson(json['fechaSolicitud']),
  usuario = SolicitudesPendientesSolicitudEmpleosUsuario.fromJson(json['usuario']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SolicitudesPendientesSolicitudEmpleos otherTyped = other as SolicitudesPendientesSolicitudEmpleos;
    return fechaSolicitud == otherTyped.fechaSolicitud && 
    usuario == otherTyped.usuario;
    
  }
  @override
  int get hashCode => Object.hashAll([fechaSolicitud.hashCode, usuario.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['fechaSolicitud'] = fechaSolicitud.toJson();
    json['usuario'] = usuario.toJson();
    return json;
  }

  SolicitudesPendientesSolicitudEmpleos({
    required this.fechaSolicitud,
    required this.usuario,
  });
}

@immutable
class SolicitudesPendientesSolicitudEmpleosUsuario {
  final String id;
  final String nombre;
  final String? numeroDeTelefono;
  final SolicitudesPendientesSolicitudEmpleosUsuarioAutenticacionOnUsuario? autenticacion_on_usuario;
  SolicitudesPendientesSolicitudEmpleosUsuario.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  numeroDeTelefono = json['numeroDeTelefono'] == null ? null : nativeFromJson<String>(json['numeroDeTelefono']),
  autenticacion_on_usuario = json['autenticacion_on_usuario'] == null ? null : SolicitudesPendientesSolicitudEmpleosUsuarioAutenticacionOnUsuario.fromJson(json['autenticacion_on_usuario']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SolicitudesPendientesSolicitudEmpleosUsuario otherTyped = other as SolicitudesPendientesSolicitudEmpleosUsuario;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    numeroDeTelefono == otherTyped.numeroDeTelefono && 
    autenticacion_on_usuario == otherTyped.autenticacion_on_usuario;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, numeroDeTelefono.hashCode, autenticacion_on_usuario.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    if (numeroDeTelefono != null) {
      json['numeroDeTelefono'] = nativeToJson<String?>(numeroDeTelefono);
    }
    if (autenticacion_on_usuario != null) {
      json['autenticacion_on_usuario'] = autenticacion_on_usuario!.toJson();
    }
    return json;
  }

  SolicitudesPendientesSolicitudEmpleosUsuario({
    required this.id,
    required this.nombre,
    this.numeroDeTelefono,
    this.autenticacion_on_usuario,
  });
}

@immutable
class SolicitudesPendientesSolicitudEmpleosUsuarioAutenticacionOnUsuario {
  final String correoElectronico;
  SolicitudesPendientesSolicitudEmpleosUsuarioAutenticacionOnUsuario.fromJson(dynamic json):
  
  correoElectronico = nativeFromJson<String>(json['correoElectronico']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SolicitudesPendientesSolicitudEmpleosUsuarioAutenticacionOnUsuario otherTyped = other as SolicitudesPendientesSolicitudEmpleosUsuarioAutenticacionOnUsuario;
    return correoElectronico == otherTyped.correoElectronico;
    
  }
  @override
  int get hashCode => correoElectronico.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['correoElectronico'] = nativeToJson<String>(correoElectronico);
    return json;
  }

  SolicitudesPendientesSolicitudEmpleosUsuarioAutenticacionOnUsuario({
    required this.correoElectronico,
  });
}

@immutable
class SolicitudesPendientesData {
  final List<SolicitudesPendientesSolicitudEmpleos> solicitudEmpleos;
  SolicitudesPendientesData.fromJson(dynamic json):
  
  solicitudEmpleos = (json['solicitudEmpleos'] as List<dynamic>)
        .map((e) => SolicitudesPendientesSolicitudEmpleos.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SolicitudesPendientesData otherTyped = other as SolicitudesPendientesData;
    return solicitudEmpleos == otherTyped.solicitudEmpleos;
    
  }
  @override
  int get hashCode => solicitudEmpleos.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['solicitudEmpleos'] = solicitudEmpleos.map((e) => e.toJson()).toList();
    return json;
  }

  SolicitudesPendientesData({
    required this.solicitudEmpleos,
  });
}

