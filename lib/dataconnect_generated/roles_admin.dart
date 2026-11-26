part of 'agilu.dart';

class RolesAdminVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  RolesAdminVariablesBuilder(this._dataConnect, );
  Deserializer<RolesAdminData> dataDeserializer = (dynamic json)  => RolesAdminData.fromJson(jsonDecode(json));
  
  Future<QueryResult<RolesAdminData, void>> execute() {
    return ref().execute();
  }

  QueryRef<RolesAdminData, void> ref() {
    
    return _dataConnect.query("RolesAdmin", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class RolesAdminData {
  final List<AnyValue>? roles;
  RolesAdminData.fromJson(dynamic json):
  
  roles = json['roles'] == null ? null : (json['roles'] as List<dynamic>)
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

    final RolesAdminData otherTyped = other as RolesAdminData;
    return roles == otherTyped.roles;
    
  }
  @override
  int get hashCode => roles.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (roles != null) {
      json['roles'] = roles?.map((e) => e!.toJson()).toList();
    }
    return json;
  }

  RolesAdminData({
    this.roles,
  });
}

