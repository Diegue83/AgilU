part of 'agilu.dart';

class MiPersonalVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  MiPersonalVariablesBuilder(this._dataConnect, );
  Deserializer<MiPersonalData> dataDeserializer = (dynamic json)  => MiPersonalData.fromJson(jsonDecode(json));
  
  Future<QueryResult<MiPersonalData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MiPersonalData, void> ref() {
    
    return _dataConnect.query("MiPersonal", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MiPersonalData {
  final List<AnyValue>? personal;
  MiPersonalData.fromJson(dynamic json):
  
  personal = json['personal'] == null ? null : (json['personal'] as List<dynamic>)
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

    final MiPersonalData otherTyped = other as MiPersonalData;
    return personal == otherTyped.personal;
    
  }
  @override
  int get hashCode => personal.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (personal != null) {
      json['personal'] = personal?.map((e) => e!.toJson()).toList();
    }
    return json;
  }

  MiPersonalData({
    this.personal,
  });
}

