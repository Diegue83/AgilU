part of 'agilu.dart';

class GuardarFotoProductoVariablesBuilder {
  String id;
  String url;

  final FirebaseDataConnect _dataConnect;
  GuardarFotoProductoVariablesBuilder(this._dataConnect, {required  this.id,required  this.url,});
  Deserializer<GuardarFotoProductoData> dataDeserializer = (dynamic json)  => GuardarFotoProductoData.fromJson(jsonDecode(json));
  Serializer<GuardarFotoProductoVariables> varsSerializer = (GuardarFotoProductoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<GuardarFotoProductoData, GuardarFotoProductoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<GuardarFotoProductoData, GuardarFotoProductoVariables> ref() {
    GuardarFotoProductoVariables vars= GuardarFotoProductoVariables(id: id,url: url,);
    return _dataConnect.mutation("GuardarFotoProducto", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GuardarFotoProductoProductoUpdate {
  final String id;
  GuardarFotoProductoProductoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GuardarFotoProductoProductoUpdate otherTyped = other as GuardarFotoProductoProductoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GuardarFotoProductoProductoUpdate({
    required this.id,
  });
}

@immutable
class GuardarFotoProductoData {
  final GuardarFotoProductoProductoUpdate? producto_update;
  GuardarFotoProductoData.fromJson(dynamic json):
  
  producto_update = json['producto_update'] == null ? null : GuardarFotoProductoProductoUpdate.fromJson(json['producto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GuardarFotoProductoData otherTyped = other as GuardarFotoProductoData;
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

  GuardarFotoProductoData({
    this.producto_update,
  });
}

@immutable
class GuardarFotoProductoVariables {
  final String id;
  final String url;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GuardarFotoProductoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  url = nativeFromJson<String>(json['url']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GuardarFotoProductoVariables otherTyped = other as GuardarFotoProductoVariables;
    return id == otherTyped.id && 
    url == otherTyped.url;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, url.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['url'] = nativeToJson<String>(url);
    return json;
  }

  GuardarFotoProductoVariables({
    required this.id,
    required this.url,
  });
}

