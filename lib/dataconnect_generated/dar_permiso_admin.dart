part of 'agilu.dart';

class DarPermisoAdminVariablesBuilder {
  String rolId;
  String codigo;

  final FirebaseDataConnect _dataConnect;
  DarPermisoAdminVariablesBuilder(this._dataConnect, {required  this.rolId,required  this.codigo,});
  Deserializer<DarPermisoAdminData> dataDeserializer = (dynamic json)  => DarPermisoAdminData.fromJson(jsonDecode(json));
  Serializer<DarPermisoAdminVariables> varsSerializer = (DarPermisoAdminVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DarPermisoAdminData, DarPermisoAdminVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DarPermisoAdminData, DarPermisoAdminVariables> ref() {
    DarPermisoAdminVariables vars= DarPermisoAdminVariables(rolId: rolId,codigo: codigo,);
    return _dataConnect.mutation("DarPermisoAdmin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DarPermisoAdminData {
  final int? execute_;
  DarPermisoAdminData.fromJson(dynamic json):
  
  execute_ = json['_execute'] == null ? null : nativeFromJson<int>(json['_execute']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DarPermisoAdminData otherTyped = other as DarPermisoAdminData;
    return execute_ == otherTyped.execute_;
    
  }
  @override
  int get hashCode => execute_.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (execute_ != null) {
      json['_execute'] = nativeToJson<int?>(execute_);
    }
    return json;
  }

  DarPermisoAdminData({
    this.execute_,
  });
}

@immutable
class DarPermisoAdminVariables {
  final String rolId;
  final String codigo;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DarPermisoAdminVariables.fromJson(Map<String, dynamic> json):
  
  rolId = nativeFromJson<String>(json['rolId']),
  codigo = nativeFromJson<String>(json['codigo']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DarPermisoAdminVariables otherTyped = other as DarPermisoAdminVariables;
    return rolId == otherTyped.rolId && 
    codigo == otherTyped.codigo;
    
  }
  @override
  int get hashCode => Object.hashAll([rolId.hashCode, codigo.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['rolId'] = nativeToJson<String>(rolId);
    json['codigo'] = nativeToJson<String>(codigo);
    return json;
  }

  DarPermisoAdminVariables({
    required this.rolId,
    required this.codigo,
  });
}

