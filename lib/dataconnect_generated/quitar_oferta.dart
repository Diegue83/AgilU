part of 'agilu.dart';

class QuitarOfertaVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  QuitarOfertaVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<QuitarOfertaData> dataDeserializer = (dynamic json)  => QuitarOfertaData.fromJson(jsonDecode(json));
  Serializer<QuitarOfertaVariables> varsSerializer = (QuitarOfertaVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<QuitarOfertaData, QuitarOfertaVariables>> execute() {
    return ref().execute();
  }

  MutationRef<QuitarOfertaData, QuitarOfertaVariables> ref() {
    QuitarOfertaVariables vars= QuitarOfertaVariables(id: id,);
    return _dataConnect.mutation("QuitarOferta", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class QuitarOfertaProductoUpdate {
  final String id;
  QuitarOfertaProductoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final QuitarOfertaProductoUpdate otherTyped = other as QuitarOfertaProductoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  QuitarOfertaProductoUpdate({
    required this.id,
  });
}

@immutable
class QuitarOfertaData {
  final QuitarOfertaProductoUpdate? producto_update;
  QuitarOfertaData.fromJson(dynamic json):
  
  producto_update = json['producto_update'] == null ? null : QuitarOfertaProductoUpdate.fromJson(json['producto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final QuitarOfertaData otherTyped = other as QuitarOfertaData;
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

  QuitarOfertaData({
    this.producto_update,
  });
}

@immutable
class QuitarOfertaVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  QuitarOfertaVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final QuitarOfertaVariables otherTyped = other as QuitarOfertaVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  QuitarOfertaVariables({
    required this.id,
  });
}

