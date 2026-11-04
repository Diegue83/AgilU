part of 'agilu.dart';

class EstablecerDisponibilidadVariablesBuilder {
  String id;
  bool disponible;

  final FirebaseDataConnect _dataConnect;
  EstablecerDisponibilidadVariablesBuilder(this._dataConnect, {required  this.id,required  this.disponible,});
  Deserializer<EstablecerDisponibilidadData> dataDeserializer = (dynamic json)  => EstablecerDisponibilidadData.fromJson(jsonDecode(json));
  Serializer<EstablecerDisponibilidadVariables> varsSerializer = (EstablecerDisponibilidadVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EstablecerDisponibilidadData, EstablecerDisponibilidadVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EstablecerDisponibilidadData, EstablecerDisponibilidadVariables> ref() {
    EstablecerDisponibilidadVariables vars= EstablecerDisponibilidadVariables(id: id,disponible: disponible,);
    return _dataConnect.mutation("EstablecerDisponibilidad", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EstablecerDisponibilidadProductoUpdate {
  final String id;
  EstablecerDisponibilidadProductoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EstablecerDisponibilidadProductoUpdate otherTyped = other as EstablecerDisponibilidadProductoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EstablecerDisponibilidadProductoUpdate({
    required this.id,
  });
}

@immutable
class EstablecerDisponibilidadData {
  final EstablecerDisponibilidadProductoUpdate? producto_update;
  EstablecerDisponibilidadData.fromJson(dynamic json):
  
  producto_update = json['producto_update'] == null ? null : EstablecerDisponibilidadProductoUpdate.fromJson(json['producto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EstablecerDisponibilidadData otherTyped = other as EstablecerDisponibilidadData;
    return producto_update == otherTyped.producto_update;
    
  }
  @override
  int get hashCode => producto_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (producto_update != null) {
      json['producto_update'] = producto_update!.toJson();
    }
    return json;
  }

  EstablecerDisponibilidadData({
    this.producto_update,
  });
}

@immutable
class EstablecerDisponibilidadVariables {
  final String id;
  final bool disponible;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EstablecerDisponibilidadVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  disponible = nativeFromJson<bool>(json['disponible']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EstablecerDisponibilidadVariables otherTyped = other as EstablecerDisponibilidadVariables;
    return id == otherTyped.id && 
    disponible == otherTyped.disponible;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, disponible.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['disponible'] = nativeToJson<bool>(disponible);
    return json;
  }

  EstablecerDisponibilidadVariables({
    required this.id,
    required this.disponible,
  });
}

