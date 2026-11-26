part of 'agilu.dart';

class EliminarRolAdminVariablesBuilder {
  String rolId;

  final FirebaseDataConnect _dataConnect;
  EliminarRolAdminVariablesBuilder(this._dataConnect, {required  this.rolId,});
  Deserializer<EliminarRolAdminData> dataDeserializer = (dynamic json)  => EliminarRolAdminData.fromJson(jsonDecode(json));
  Serializer<EliminarRolAdminVariables> varsSerializer = (EliminarRolAdminVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EliminarRolAdminData, EliminarRolAdminVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EliminarRolAdminData, EliminarRolAdminVariables> ref() {
    EliminarRolAdminVariables vars= EliminarRolAdminVariables(rolId: rolId,);
    return _dataConnect.mutation("EliminarRolAdmin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EliminarRolAdminData {
  final AnyValue? resultado;
  EliminarRolAdminData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarRolAdminData otherTyped = other as EliminarRolAdminData;
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

  EliminarRolAdminData({
    this.resultado,
  });
}

@immutable
class EliminarRolAdminVariables {
  final String rolId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EliminarRolAdminVariables.fromJson(Map<String, dynamic> json):
  
  rolId = nativeFromJson<String>(json['rolId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarRolAdminVariables otherTyped = other as EliminarRolAdminVariables;
    return rolId == otherTyped.rolId;
    
  }
  @override
  int get hashCode => rolId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['rolId'] = nativeToJson<String>(rolId);
    return json;
  }

  EliminarRolAdminVariables({
    required this.rolId,
  });
}

