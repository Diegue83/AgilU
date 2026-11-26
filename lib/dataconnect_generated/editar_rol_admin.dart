part of 'agilu.dart';

class EditarRolAdminVariablesBuilder {
  String rolId;
  Optional<String> _descripcion = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  EditarRolAdminVariablesBuilder descripcion(String? t) {
   _descripcion.value = t;
   return this;
  }

  EditarRolAdminVariablesBuilder(this._dataConnect, {required  this.rolId,});
  Deserializer<EditarRolAdminData> dataDeserializer = (dynamic json)  => EditarRolAdminData.fromJson(jsonDecode(json));
  Serializer<EditarRolAdminVariables> varsSerializer = (EditarRolAdminVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditarRolAdminData, EditarRolAdminVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditarRolAdminData, EditarRolAdminVariables> ref() {
    EditarRolAdminVariables vars= EditarRolAdminVariables(rolId: rolId,descripcion: _descripcion,);
    return _dataConnect.mutation("EditarRolAdmin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditarRolAdminData {
  final AnyValue? resultado;
  EditarRolAdminData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarRolAdminData otherTyped = other as EditarRolAdminData;
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

  EditarRolAdminData({
    this.resultado,
  });
}

@immutable
class EditarRolAdminVariables {
  final String rolId;
  late final Optional<String>descripcion;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditarRolAdminVariables.fromJson(Map<String, dynamic> json):
  
  rolId = nativeFromJson<String>(json['rolId']) {
  
  
  
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

    final EditarRolAdminVariables otherTyped = other as EditarRolAdminVariables;
    return rolId == otherTyped.rolId && 
    descripcion == otherTyped.descripcion;
    
  }
  @override
  int get hashCode => Object.hashAll([rolId.hashCode, descripcion.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['rolId'] = nativeToJson<String>(rolId);
    if(descripcion.state == OptionalState.set) {
      json['descripcion'] = descripcion.toJson();
    }
    return json;
  }

  EditarRolAdminVariables({
    required this.rolId,
    required this.descripcion,
  });
}

