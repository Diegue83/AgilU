part of 'agilu.dart';

class EditarCafeteriaAdminVariablesBuilder {
  String id;
  String nombre;
  Optional<String> _ubicacion = Optional.optional(nativeFromJson, nativeToJson);
  bool activa;

  final FirebaseDataConnect _dataConnect;  EditarCafeteriaAdminVariablesBuilder ubicacion(String? t) {
   _ubicacion.value = t;
   return this;
  }

  EditarCafeteriaAdminVariablesBuilder(this._dataConnect, {required  this.id,required  this.nombre,required  this.activa,});
  Deserializer<EditarCafeteriaAdminData> dataDeserializer = (dynamic json)  => EditarCafeteriaAdminData.fromJson(jsonDecode(json));
  Serializer<EditarCafeteriaAdminVariables> varsSerializer = (EditarCafeteriaAdminVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditarCafeteriaAdminData, EditarCafeteriaAdminVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditarCafeteriaAdminData, EditarCafeteriaAdminVariables> ref() {
    EditarCafeteriaAdminVariables vars= EditarCafeteriaAdminVariables(id: id,nombre: nombre,ubicacion: _ubicacion,activa: activa,);
    return _dataConnect.mutation("EditarCafeteriaAdmin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditarCafeteriaAdminCafeteriaUpdate {
  final String id;
  EditarCafeteriaAdminCafeteriaUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarCafeteriaAdminCafeteriaUpdate otherTyped = other as EditarCafeteriaAdminCafeteriaUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EditarCafeteriaAdminCafeteriaUpdate({
    required this.id,
  });
}

@immutable
class EditarCafeteriaAdminData {
  final EditarCafeteriaAdminCafeteriaUpdate? cafeteria_update;
  EditarCafeteriaAdminData.fromJson(dynamic json):
  
  cafeteria_update = json['cafeteria_update'] == null ? null : EditarCafeteriaAdminCafeteriaUpdate.fromJson(json['cafeteria_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarCafeteriaAdminData otherTyped = other as EditarCafeteriaAdminData;
    return cafeteria_update == otherTyped.cafeteria_update;
    
  }
  @override
  int get hashCode => cafeteria_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (cafeteria_update != null) {
      json['cafeteria_update'] = cafeteria_update!.toJson();
    }
    return json;
  }

  EditarCafeteriaAdminData({
    this.cafeteria_update,
  });
}

@immutable
class EditarCafeteriaAdminVariables {
  final String id;
  final String nombre;
  late final Optional<String>ubicacion;
  final bool activa;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditarCafeteriaAdminVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  activa = nativeFromJson<bool>(json['activa']) {
  
  
  
  
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

    final EditarCafeteriaAdminVariables otherTyped = other as EditarCafeteriaAdminVariables;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    ubicacion == otherTyped.ubicacion && 
    activa == otherTyped.activa;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, ubicacion.hashCode, activa.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    if(ubicacion.state == OptionalState.set) {
      json['ubicacion'] = ubicacion.toJson();
    }
    json['activa'] = nativeToJson<bool>(activa);
    return json;
  }

  EditarCafeteriaAdminVariables({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.activa,
  });
}

