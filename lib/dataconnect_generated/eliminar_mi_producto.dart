part of 'agilu.dart';

class EliminarMiProductoVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  EliminarMiProductoVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<EliminarMiProductoData> dataDeserializer = (dynamic json)  => EliminarMiProductoData.fromJson(jsonDecode(json));
  Serializer<EliminarMiProductoVariables> varsSerializer = (EliminarMiProductoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EliminarMiProductoData, EliminarMiProductoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EliminarMiProductoData, EliminarMiProductoVariables> ref() {
    EliminarMiProductoVariables vars= EliminarMiProductoVariables(id: id,);
    return _dataConnect.mutation("EliminarMiProducto", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EliminarMiProductoProductoUpdate {
  final String id;
  EliminarMiProductoProductoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarMiProductoProductoUpdate otherTyped = other as EliminarMiProductoProductoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EliminarMiProductoProductoUpdate({
    required this.id,
  });
}

@immutable
class EliminarMiProductoData {
  final EliminarMiProductoProductoUpdate? producto_update;
  EliminarMiProductoData.fromJson(dynamic json):
  
  producto_update = json['producto_update'] == null ? null : EliminarMiProductoProductoUpdate.fromJson(json['producto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarMiProductoData otherTyped = other as EliminarMiProductoData;
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

  EliminarMiProductoData({
    this.producto_update,
  });
}

@immutable
class EliminarMiProductoVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EliminarMiProductoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EliminarMiProductoVariables otherTyped = other as EliminarMiProductoVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EliminarMiProductoVariables({
    required this.id,
  });
}

