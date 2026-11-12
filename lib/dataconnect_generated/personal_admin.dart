part of 'agilu.dart';

class PersonalAdminVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  PersonalAdminVariablesBuilder(this._dataConnect, );
  Deserializer<PersonalAdminData> dataDeserializer = (dynamic json)  => PersonalAdminData.fromJson(jsonDecode(json));
  
  Future<QueryResult<PersonalAdminData, void>> execute() {
    return ref().execute();
  }

  QueryRef<PersonalAdminData, void> ref() {
    
    return _dataConnect.query("PersonalAdmin", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class PersonalAdminData {
  final List<AnyValue>? personal;
  PersonalAdminData.fromJson(dynamic json):
  
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

    final PersonalAdminData otherTyped = other as PersonalAdminData;
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

  PersonalAdminData({
    this.personal,
  });
}

