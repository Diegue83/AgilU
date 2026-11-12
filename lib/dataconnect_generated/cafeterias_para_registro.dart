part of 'agilu.dart';

class CafeteriasParaRegistroVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  CafeteriasParaRegistroVariablesBuilder(this._dataConnect, );
  Deserializer<CafeteriasParaRegistroData> dataDeserializer = (dynamic json)  => CafeteriasParaRegistroData.fromJson(jsonDecode(json));
  
  Future<QueryResult<CafeteriasParaRegistroData, void>> execute() {
    return ref().execute();
  }

  QueryRef<CafeteriasParaRegistroData, void> ref() {
    
    return _dataConnect.query("CafeteriasParaRegistro", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class CafeteriasParaRegistroCafeterias {
  final String id;
  final String nombre;
  final String? ubicacion;
  CafeteriasParaRegistroCafeterias.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  ubicacion = json['ubicacion'] == null ? null : nativeFromJson<String>(json['ubicacion']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CafeteriasParaRegistroCafeterias otherTyped = other as CafeteriasParaRegistroCafeterias;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    ubicacion == otherTyped.ubicacion;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, ubicacion.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    if (ubicacion != null) {
      json['ubicacion'] = nativeToJson<String?>(ubicacion);
    }
    return json;
  }

  CafeteriasParaRegistroCafeterias({
    required this.id,
    required this.nombre,
    this.ubicacion,
  });
}

@immutable
class CafeteriasParaRegistroData {
  final List<CafeteriasParaRegistroCafeterias> cafeterias;
  CafeteriasParaRegistroData.fromJson(dynamic json):
  
  cafeterias = (json['cafeterias'] as List<dynamic>)
        .map((e) => CafeteriasParaRegistroCafeterias.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CafeteriasParaRegistroData otherTyped = other as CafeteriasParaRegistroData;
    return cafeterias == otherTyped.cafeterias;
    
  }
  @override
  int get hashCode => cafeterias.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cafeterias'] = cafeterias.map((e) => e.toJson()).toList();
    return json;
  }

  CafeteriasParaRegistroData({
    required this.cafeterias,
  });
}

