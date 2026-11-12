part of 'agilu.dart';

class MisPendientesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  MisPendientesVariablesBuilder(this._dataConnect, );
  Deserializer<MisPendientesData> dataDeserializer = (dynamic json)  => MisPendientesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<MisPendientesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MisPendientesData, void> ref() {
    
    return _dataConnect.query("MisPendientes", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MisPendientesData {
  final AnyValue? pendientes;
  MisPendientesData.fromJson(dynamic json):
  
  pendientes = json['pendientes'] == null ? null : AnyValue.fromJson(json['pendientes']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisPendientesData otherTyped = other as MisPendientesData;
    return pendientes == otherTyped.pendientes;
    
  }
  @override
  int get hashCode => pendientes.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (pendientes != null) {
      json['pendientes'] = pendientes!.toJson();
    }
    return json;
  }

  MisPendientesData({
    this.pendientes,
  });
}

