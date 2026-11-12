part of 'agilu.dart';

class MarcarAvisosLeidosVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  MarcarAvisosLeidosVariablesBuilder(this._dataConnect, );
  Deserializer<MarcarAvisosLeidosData> dataDeserializer = (dynamic json)  => MarcarAvisosLeidosData.fromJson(jsonDecode(json));
  
  Future<OperationResult<MarcarAvisosLeidosData, void>> execute() {
    return ref().execute();
  }

  MutationRef<MarcarAvisosLeidosData, void> ref() {
    
    return _dataConnect.mutation("MarcarAvisosLeidos", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MarcarAvisosLeidosData {
  final int notificacion_updateMany;
  MarcarAvisosLeidosData.fromJson(dynamic json):
  
  notificacion_updateMany = nativeFromJson<int>(json['notificacion_updateMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MarcarAvisosLeidosData otherTyped = other as MarcarAvisosLeidosData;
    return notificacion_updateMany == otherTyped.notificacion_updateMany;
    
  }
  @override
  int get hashCode => notificacion_updateMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['notificacion_updateMany'] = nativeToJson<int>(notificacion_updateMany);
    return json;
  }

  MarcarAvisosLeidosData({
    required this.notificacion_updateMany,
  });
}

