part of 'agilu.dart';

class CrearRolAdminVariablesBuilder {
  String nombre;
  Optional<String> _descripcion = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CrearRolAdminVariablesBuilder descripcion(String? t) {
   _descripcion.value = t;
   return this;
  }

  CrearRolAdminVariablesBuilder(this._dataConnect, {required  this.nombre,});
  Deserializer<CrearRolAdminData> dataDeserializer = (dynamic json)  => CrearRolAdminData.fromJson(jsonDecode(json));
  Serializer<CrearRolAdminVariables> varsSerializer = (CrearRolAdminVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearRolAdminData, CrearRolAdminVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearRolAdminData, CrearRolAdminVariables> ref() {
    CrearRolAdminVariables vars= CrearRolAdminVariables(nombre: nombre,descripcion: _descripcion,);
    return _dataConnect.mutation("CrearRolAdmin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearRolAdminData {
  final AnyValue? resultado;
  CrearRolAdminData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearRolAdminData otherTyped = other as CrearRolAdminData;
    return resultado == otherTyped.resultado;
    
  }
  @override
  int get hashCode => resultado.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (resultado != null) {
      json['resultado'] = resultado!.toJson();
    }
    return json;
  }

  CrearRolAdminData({
    this.resultado,
  });
}

@immutable
class CrearRolAdminVariables {
  final String nombre;
  late final Optional<String>descripcion;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearRolAdminVariables.fromJson(Map<String, dynamic> json):
  
  nombre = nativeFromJson<String>(json['nombre']) {
  
  
  
    descripcion = Optional.optional(nativeFromJson, nativeToJson);
    descripcion.value = json['descripcion'] == null ? null : nativeFromJson<String>(json['descripcion']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearRolAdminVariables otherTyped = other as CrearRolAdminVariables;
    return nombre == otherTyped.nombre && 
    descripcion == otherTyped.descripcion;
    
  }
  @override
  int get hashCode => Object.hashAll([nombre.hashCode, descripcion.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    if(descripcion.state == OptionalState.set) {
      json['descripcion'] = descripcion.toJson();
    }
    return json;
  }

  CrearRolAdminVariables({
    required this.nombre,
    required this.descripcion,
  });
}

