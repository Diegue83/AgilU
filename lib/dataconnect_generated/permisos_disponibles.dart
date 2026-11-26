part of 'agilu.dart';

class PermisosDisponiblesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  PermisosDisponiblesVariablesBuilder(this._dataConnect, );
  Deserializer<PermisosDisponiblesData> dataDeserializer = (dynamic json)  => PermisosDisponiblesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<PermisosDisponiblesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<PermisosDisponiblesData, void> ref() {
    
    return _dataConnect.query("PermisosDisponibles", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class PermisosDisponiblesPermisos {
  final String id;
  final String nombre;
  final String codigoAccion;
  PermisosDisponiblesPermisos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  codigoAccion = nativeFromJson<String>(json['codigoAccion']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final PermisosDisponiblesPermisos otherTyped = other as PermisosDisponiblesPermisos;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    codigoAccion == otherTyped.codigoAccion;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, codigoAccion.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    json['codigoAccion'] = nativeToJson<String>(codigoAccion);
    return json;
  }

  PermisosDisponiblesPermisos({
    required this.id,
    required this.nombre,
    required this.codigoAccion,
  });
}

@immutable
class PermisosDisponiblesData {
  final List<PermisosDisponiblesPermisos> permisos;
  PermisosDisponiblesData.fromJson(dynamic json):
  
  permisos = (json['permisos'] as List<dynamic>)
        .map((e) => PermisosDisponiblesPermisos.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final PermisosDisponiblesData otherTyped = other as PermisosDisponiblesData;
    return permisos == otherTyped.permisos;
    
  }
  @override
  int get hashCode => permisos.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['permisos'] = permisos.map((e) => e.toJson()).toList();
    return json;
  }

  PermisosDisponiblesData({
    required this.permisos,
  });
}

