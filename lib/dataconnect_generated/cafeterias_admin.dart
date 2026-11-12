part of 'agilu.dart';

class CafeteriasAdminVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  CafeteriasAdminVariablesBuilder(this._dataConnect, );
  Deserializer<CafeteriasAdminData> dataDeserializer = (dynamic json)  => CafeteriasAdminData.fromJson(jsonDecode(json));
  
  Future<QueryResult<CafeteriasAdminData, void>> execute() {
    return ref().execute();
  }

  QueryRef<CafeteriasAdminData, void> ref() {
    
    return _dataConnect.query("CafeteriasAdmin", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class CafeteriasAdminData {
  final List<AnyValue>? cafeterias;
  CafeteriasAdminData.fromJson(dynamic json):
  
  cafeterias = json['cafeterias'] == null ? null : (json['cafeterias'] as List<dynamic>)
        .map((e) => AnyValue.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CafeteriasAdminData otherTyped = other as CafeteriasAdminData;
    return cafeterias == otherTyped.cafeterias;
    
  }
  @override
  int get hashCode => cafeterias.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (cafeterias != null) {
      json['cafeterias'] = cafeterias?.map((e) => e!.toJson()).toList();
    }
    return json;
  }

  CafeteriasAdminData({
    this.cafeterias,
  });
}

