part of 'agilu.dart';

class QuitarPermisoAdminVariablesBuilder {
  String rolId;
  String codigo;

  final FirebaseDataConnect _dataConnect;
  QuitarPermisoAdminVariablesBuilder(this._dataConnect, {required  this.rolId,required  this.codigo,});
  Deserializer<QuitarPermisoAdminData> dataDeserializer = (dynamic json)  => QuitarPermisoAdminData.fromJson(jsonDecode(json));
  Serializer<QuitarPermisoAdminVariables> varsSerializer = (QuitarPermisoAdminVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<QuitarPermisoAdminData, QuitarPermisoAdminVariables>> execute() {
    return ref().execute();
  }

  MutationRef<QuitarPermisoAdminData, QuitarPermisoAdminVariables> ref() {
    QuitarPermisoAdminVariables vars= QuitarPermisoAdminVariables(rolId: rolId,codigo: codigo,);
    return _dataConnect.mutation("QuitarPermisoAdmin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class QuitarPermisoAdminData {
  final int? execute_;
  QuitarPermisoAdminData.fromJson(dynamic json):
  
  execute_ = json['_execute'] == null ? null : nativeFromJson<int>(json['_execute']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final QuitarPermisoAdminData otherTyped = other as QuitarPermisoAdminData;
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

  QuitarPermisoAdminData({
    this.execute_,
  });
}

@immutable
class QuitarPermisoAdminVariables {
  final String rolId;
  final String codigo;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  QuitarPermisoAdminVariables.fromJson(Map<String, dynamic> json):
  
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

    final QuitarPermisoAdminVariables otherTyped = other as QuitarPermisoAdminVariables;
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

  QuitarPermisoAdminVariables({
    required this.rolId,
    required this.codigo,
  });
}

