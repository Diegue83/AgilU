part of 'agilu.dart';

class ActivarEstacionVariablesBuilder {
  String id;
  bool activo;

  final FirebaseDataConnect _dataConnect;
  ActivarEstacionVariablesBuilder(this._dataConnect, {required  this.id,required  this.activo,});
  Deserializer<ActivarEstacionData> dataDeserializer = (dynamic json)  => ActivarEstacionData.fromJson(jsonDecode(json));
  Serializer<ActivarEstacionVariables> varsSerializer = (ActivarEstacionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<ActivarEstacionData, ActivarEstacionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<ActivarEstacionData, ActivarEstacionVariables> ref() {
    ActivarEstacionVariables vars= ActivarEstacionVariables(id: id,activo: activo,);
    return _dataConnect.mutation("ActivarEstacion", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ActivarEstacionPuestoUpdate {
  final String id;
  ActivarEstacionPuestoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ActivarEstacionPuestoUpdate otherTyped = other as ActivarEstacionPuestoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ActivarEstacionPuestoUpdate({
    required this.id,
  });
}

@immutable
class ActivarEstacionData {
  final ActivarEstacionPuestoUpdate? puesto_update;
  ActivarEstacionData.fromJson(dynamic json):
  
  puesto_update = json['puesto_update'] == null ? null : ActivarEstacionPuestoUpdate.fromJson(json['puesto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ActivarEstacionData otherTyped = other as ActivarEstacionData;
    return puesto_update == otherTyped.puesto_update;
    
  }
  @override
  int get hashCode => puesto_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (puesto_update != null) {
      json['puesto_update'] = puesto_update!.toJson();
    }
    return json;
  }

  ActivarEstacionData({
    this.puesto_update,
  });
}

@immutable
class ActivarEstacionVariables {
  final String id;
  final bool activo;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ActivarEstacionVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  activo = nativeFromJson<bool>(json['activo']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ActivarEstacionVariables otherTyped = other as ActivarEstacionVariables;
    return id == otherTyped.id && 
    activo == otherTyped.activo;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, activo.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['activo'] = nativeToJson<bool>(activo);
    return json;
  }

  ActivarEstacionVariables({
    required this.id,
    required this.activo,
  });
}

