part of 'agilu.dart';

class EditarEstacionVariablesBuilder {
  String id;
  String nombre;
  int orden;
  bool activo;

  final FirebaseDataConnect _dataConnect;
  EditarEstacionVariablesBuilder(this._dataConnect, {required  this.id,required  this.nombre,required  this.orden,required  this.activo,});
  Deserializer<EditarEstacionData> dataDeserializer = (dynamic json)  => EditarEstacionData.fromJson(jsonDecode(json));
  Serializer<EditarEstacionVariables> varsSerializer = (EditarEstacionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditarEstacionData, EditarEstacionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditarEstacionData, EditarEstacionVariables> ref() {
    EditarEstacionVariables vars= EditarEstacionVariables(id: id,nombre: nombre,orden: orden,activo: activo,);
    return _dataConnect.mutation("EditarEstacion", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditarEstacionPuestoUpdate {
  final String id;
  EditarEstacionPuestoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarEstacionPuestoUpdate otherTyped = other as EditarEstacionPuestoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EditarEstacionPuestoUpdate({
    required this.id,
  });
}

@immutable
class EditarEstacionData {
  final EditarEstacionPuestoUpdate? puesto_update;
  EditarEstacionData.fromJson(dynamic json):
  
  puesto_update = json['puesto_update'] == null ? null : EditarEstacionPuestoUpdate.fromJson(json['puesto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarEstacionData otherTyped = other as EditarEstacionData;
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

  EditarEstacionData({
    this.puesto_update,
  });
}

@immutable
class EditarEstacionVariables {
  final String id;
  final String nombre;
  final int orden;
  final bool activo;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditarEstacionVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  orden = nativeFromJson<int>(json['orden']),
  activo = nativeFromJson<bool>(json['activo']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarEstacionVariables otherTyped = other as EditarEstacionVariables;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    orden == otherTyped.orden && 
    activo == otherTyped.activo;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, orden.hashCode, activo.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    json['orden'] = nativeToJson<int>(orden);
    json['activo'] = nativeToJson<bool>(activo);
    return json;
  }

  EditarEstacionVariables({
    required this.id,
    required this.nombre,
    required this.orden,
    required this.activo,
  });
}

