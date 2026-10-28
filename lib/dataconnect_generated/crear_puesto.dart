part of 'agilu.dart';

class CrearPuestoVariablesBuilder {
  String nombre;
  String ubicacion;

  final FirebaseDataConnect _dataConnect;
  CrearPuestoVariablesBuilder(this._dataConnect, {required  this.nombre,required  this.ubicacion,});
  Deserializer<CrearPuestoData> dataDeserializer = (dynamic json)  => CrearPuestoData.fromJson(jsonDecode(json));
  Serializer<CrearPuestoVariables> varsSerializer = (CrearPuestoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearPuestoData, CrearPuestoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearPuestoData, CrearPuestoVariables> ref() {
    CrearPuestoVariables vars= CrearPuestoVariables(nombre: nombre,ubicacion: ubicacion,);
    return _dataConnect.mutation("CrearPuesto", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearPuestoPuestoInsert {
  final String id;
  CrearPuestoPuestoInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPuestoPuestoInsert otherTyped = other as CrearPuestoPuestoInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CrearPuestoPuestoInsert({
    required this.id,
  });
}

@immutable
class CrearPuestoData {
  final CrearPuestoPuestoInsert puesto_insert;
  CrearPuestoData.fromJson(dynamic json):
  
  puesto_insert = CrearPuestoPuestoInsert.fromJson(json['puesto_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPuestoData otherTyped = other as CrearPuestoData;
    return puesto_insert == otherTyped.puesto_insert;
    
  }
  @override
  int get hashCode => puesto_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['puesto_insert'] = puesto_insert.toJson();
    return json;
  }

  CrearPuestoData({
    required this.puesto_insert,
  });
}

@immutable
class CrearPuestoVariables {
  final String nombre;
  final String ubicacion;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearPuestoVariables.fromJson(Map<String, dynamic> json):
  
  nombre = nativeFromJson<String>(json['nombre']),
  ubicacion = nativeFromJson<String>(json['ubicacion']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPuestoVariables otherTyped = other as CrearPuestoVariables;
    return nombre == otherTyped.nombre && 
    ubicacion == otherTyped.ubicacion;
    
  }
  @override
  int get hashCode => Object.hashAll([nombre.hashCode, ubicacion.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    json['ubicacion'] = nativeToJson<String>(ubicacion);
    return json;
  }

  CrearPuestoVariables({
    required this.nombre,
    required this.ubicacion,
  });
}

