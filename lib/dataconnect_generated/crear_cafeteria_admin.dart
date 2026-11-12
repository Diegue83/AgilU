part of 'agilu.dart';

class CrearCafeteriaAdminVariablesBuilder {
  String nombre;
  Optional<String> _ubicacion = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CrearCafeteriaAdminVariablesBuilder ubicacion(String? t) {
   _ubicacion.value = t;
   return this;
  }

  CrearCafeteriaAdminVariablesBuilder(this._dataConnect, {required  this.nombre,});
  Deserializer<CrearCafeteriaAdminData> dataDeserializer = (dynamic json)  => CrearCafeteriaAdminData.fromJson(jsonDecode(json));
  Serializer<CrearCafeteriaAdminVariables> varsSerializer = (CrearCafeteriaAdminVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearCafeteriaAdminData, CrearCafeteriaAdminVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearCafeteriaAdminData, CrearCafeteriaAdminVariables> ref() {
    CrearCafeteriaAdminVariables vars= CrearCafeteriaAdminVariables(nombre: nombre,ubicacion: _ubicacion,);
    return _dataConnect.mutation("CrearCafeteriaAdmin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearCafeteriaAdminCafeteriaInsert {
  final String id;
  CrearCafeteriaAdminCafeteriaInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearCafeteriaAdminCafeteriaInsert otherTyped = other as CrearCafeteriaAdminCafeteriaInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CrearCafeteriaAdminCafeteriaInsert({
    required this.id,
  });
}

@immutable
class CrearCafeteriaAdminData {
  final CrearCafeteriaAdminCafeteriaInsert cafeteria_insert;
  CrearCafeteriaAdminData.fromJson(dynamic json):
  
  cafeteria_insert = CrearCafeteriaAdminCafeteriaInsert.fromJson(json['cafeteria_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearCafeteriaAdminData otherTyped = other as CrearCafeteriaAdminData;
    return cafeteria_insert == otherTyped.cafeteria_insert;
    
  }
  @override
  int get hashCode => cafeteria_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cafeteria_insert'] = cafeteria_insert.toJson();
    return json;
  }

  CrearCafeteriaAdminData({
    required this.cafeteria_insert,
  });
}

@immutable
class CrearCafeteriaAdminVariables {
  final String nombre;
  late final Optional<String>ubicacion;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearCafeteriaAdminVariables.fromJson(Map<String, dynamic> json):
  
  nombre = nativeFromJson<String>(json['nombre']) {
  
  
  
    ubicacion = Optional.optional(nativeFromJson, nativeToJson);
    ubicacion.value = json['ubicacion'] == null ? null : nativeFromJson<String>(json['ubicacion']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearCafeteriaAdminVariables otherTyped = other as CrearCafeteriaAdminVariables;
    return nombre == otherTyped.nombre && 
    ubicacion == otherTyped.ubicacion;
    
  }
  @override
  int get hashCode => Object.hashAll([nombre.hashCode, ubicacion.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    if(ubicacion.state == OptionalState.set) {
      json['ubicacion'] = ubicacion.toJson();
    }
    return json;
  }

  CrearCafeteriaAdminVariables({
    required this.nombre,
    required this.ubicacion,
  });
}

