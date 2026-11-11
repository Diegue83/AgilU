part of 'agilu.dart';

class PublicarOfertaVariablesBuilder {
  String id;
  double precioOferta;
  Timestamp hasta;
  bool esEspecialidad;

  final FirebaseDataConnect _dataConnect;
  PublicarOfertaVariablesBuilder(this._dataConnect, {required  this.id,required  this.precioOferta,required  this.hasta,required  this.esEspecialidad,});
  Deserializer<PublicarOfertaData> dataDeserializer = (dynamic json)  => PublicarOfertaData.fromJson(jsonDecode(json));
  Serializer<PublicarOfertaVariables> varsSerializer = (PublicarOfertaVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<PublicarOfertaData, PublicarOfertaVariables>> execute() {
    return ref().execute();
  }

  MutationRef<PublicarOfertaData, PublicarOfertaVariables> ref() {
    PublicarOfertaVariables vars= PublicarOfertaVariables(id: id,precioOferta: precioOferta,hasta: hasta,esEspecialidad: esEspecialidad,);
    return _dataConnect.mutation("PublicarOferta", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class PublicarOfertaProductoUpdate {
  final String id;
  PublicarOfertaProductoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final PublicarOfertaProductoUpdate otherTyped = other as PublicarOfertaProductoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  PublicarOfertaProductoUpdate({
    required this.id,
  });
}

@immutable
class PublicarOfertaData {
  final PublicarOfertaProductoUpdate? producto_update;
  PublicarOfertaData.fromJson(dynamic json):
  
  producto_update = json['producto_update'] == null ? null : PublicarOfertaProductoUpdate.fromJson(json['producto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final PublicarOfertaData otherTyped = other as PublicarOfertaData;
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

  PublicarOfertaData({
    this.producto_update,
  });
}

@immutable
class PublicarOfertaVariables {
  final String id;
  final double precioOferta;
  final Timestamp hasta;
  final bool esEspecialidad;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  PublicarOfertaVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  precioOferta = nativeFromJson<double>(json['precioOferta']),
  hasta = Timestamp.fromJson(json['hasta']),
  esEspecialidad = nativeFromJson<bool>(json['esEspecialidad']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final PublicarOfertaVariables otherTyped = other as PublicarOfertaVariables;
    return id == otherTyped.id && 
    precioOferta == otherTyped.precioOferta && 
    hasta == otherTyped.hasta && 
    esEspecialidad == otherTyped.esEspecialidad;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, precioOferta.hashCode, hasta.hashCode, esEspecialidad.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['precioOferta'] = nativeToJson<double>(precioOferta);
    json['hasta'] = hasta.toJson();
    json['esEspecialidad'] = nativeToJson<bool>(esEspecialidad);
    return json;
  }

  PublicarOfertaVariables({
    required this.id,
    required this.precioOferta,
    required this.hasta,
    required this.esEspecialidad,
  });
}

