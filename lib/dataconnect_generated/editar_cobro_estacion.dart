part of 'agilu.dart';

class EditarCobroEstacionVariablesBuilder {
  String id;
  Optional<String> _banco = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _clabe = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _titular = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  EditarCobroEstacionVariablesBuilder banco(String? t) {
   _banco.value = t;
   return this;
  }
  EditarCobroEstacionVariablesBuilder clabe(String? t) {
   _clabe.value = t;
   return this;
  }
  EditarCobroEstacionVariablesBuilder titular(String? t) {
   _titular.value = t;
   return this;
  }

  EditarCobroEstacionVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<EditarCobroEstacionData> dataDeserializer = (dynamic json)  => EditarCobroEstacionData.fromJson(jsonDecode(json));
  Serializer<EditarCobroEstacionVariables> varsSerializer = (EditarCobroEstacionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditarCobroEstacionData, EditarCobroEstacionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditarCobroEstacionData, EditarCobroEstacionVariables> ref() {
    EditarCobroEstacionVariables vars= EditarCobroEstacionVariables(id: id,banco: _banco,clabe: _clabe,titular: _titular,);
    return _dataConnect.mutation("EditarCobroEstacion", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditarCobroEstacionPuestoUpdate {
  final String id;
  EditarCobroEstacionPuestoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarCobroEstacionPuestoUpdate otherTyped = other as EditarCobroEstacionPuestoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EditarCobroEstacionPuestoUpdate({
    required this.id,
  });
}

@immutable
class EditarCobroEstacionData {
  final EditarCobroEstacionPuestoUpdate? puesto_update;
  EditarCobroEstacionData.fromJson(dynamic json):
  
  puesto_update = json['puesto_update'] == null ? null : EditarCobroEstacionPuestoUpdate.fromJson(json['puesto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarCobroEstacionData otherTyped = other as EditarCobroEstacionData;
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

  EditarCobroEstacionData({
    this.puesto_update,
  });
}

@immutable
class EditarCobroEstacionVariables {
  final String id;
  late final Optional<String>banco;
  late final Optional<String>clabe;
  late final Optional<String>titular;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditarCobroEstacionVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']) {
  
  
  
    banco = Optional.optional(nativeFromJson, nativeToJson);
    banco.value = json['banco'] == null ? null : nativeFromJson<String>(json['banco']);
  
  
    clabe = Optional.optional(nativeFromJson, nativeToJson);
    clabe.value = json['clabe'] == null ? null : nativeFromJson<String>(json['clabe']);
  
  
    titular = Optional.optional(nativeFromJson, nativeToJson);
    titular.value = json['titular'] == null ? null : nativeFromJson<String>(json['titular']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarCobroEstacionVariables otherTyped = other as EditarCobroEstacionVariables;
    return id == otherTyped.id && 
    banco == otherTyped.banco && 
    clabe == otherTyped.clabe && 
    titular == otherTyped.titular;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, banco.hashCode, clabe.hashCode, titular.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    if(banco.state == OptionalState.set) {
      json['banco'] = banco.toJson();
    }
    if(clabe.state == OptionalState.set) {
      json['clabe'] = clabe.toJson();
    }
    if(titular.state == OptionalState.set) {
      json['titular'] = titular.toJson();
    }
    return json;
  }

  EditarCobroEstacionVariables({
    required this.id,
    required this.banco,
    required this.clabe,
    required this.titular,
  });
}

