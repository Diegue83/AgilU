part of 'agilu.dart';

class AsignarRolAdminVariablesBuilder {
  String correo;
  String rol;
  Optional<String> _cafeteriaId = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  AsignarRolAdminVariablesBuilder cafeteriaId(String? t) {
   _cafeteriaId.value = t;
   return this;
  }

  AsignarRolAdminVariablesBuilder(this._dataConnect, {required  this.correo,required  this.rol,});
  Deserializer<AsignarRolAdminData> dataDeserializer = (dynamic json)  => AsignarRolAdminData.fromJson(jsonDecode(json));
  Serializer<AsignarRolAdminVariables> varsSerializer = (AsignarRolAdminVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AsignarRolAdminData, AsignarRolAdminVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AsignarRolAdminData, AsignarRolAdminVariables> ref() {
    AsignarRolAdminVariables vars= AsignarRolAdminVariables(correo: correo,rol: rol,cafeteriaId: _cafeteriaId,);
    return _dataConnect.mutation("AsignarRolAdmin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AsignarRolAdminData {
  final AnyValue? resultado;
  AsignarRolAdminData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AsignarRolAdminData otherTyped = other as AsignarRolAdminData;
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

  AsignarRolAdminData({
    this.resultado,
  });
}

@immutable
class AsignarRolAdminVariables {
  final String correo;
  final String rol;
  late final Optional<String>cafeteriaId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AsignarRolAdminVariables.fromJson(Map<String, dynamic> json):
  
  correo = nativeFromJson<String>(json['correo']),
  rol = nativeFromJson<String>(json['rol']) {
  
  
  
  
    cafeteriaId = Optional.optional(nativeFromJson, nativeToJson);
    cafeteriaId.value = json['cafeteriaId'] == null ? null : nativeFromJson<String>(json['cafeteriaId']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AsignarRolAdminVariables otherTyped = other as AsignarRolAdminVariables;
    return correo == otherTyped.correo && 
    rol == otherTyped.rol && 
    cafeteriaId == otherTyped.cafeteriaId;
    
  }
  @override
  int get hashCode => Object.hashAll([correo.hashCode, rol.hashCode, cafeteriaId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['correo'] = nativeToJson<String>(correo);
    json['rol'] = nativeToJson<String>(rol);
    if(cafeteriaId.state == OptionalState.set) {
      json['cafeteriaId'] = cafeteriaId.toJson();
    }
    return json;
  }

  AsignarRolAdminVariables({
    required this.correo,
    required this.rol,
    required this.cafeteriaId,
  });
}

