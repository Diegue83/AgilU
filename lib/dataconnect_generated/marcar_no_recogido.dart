part of 'agilu.dart';

class MarcarNoRecogidoVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  MarcarNoRecogidoVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<MarcarNoRecogidoData> dataDeserializer = (dynamic json)  => MarcarNoRecogidoData.fromJson(jsonDecode(json));
  Serializer<MarcarNoRecogidoVariables> varsSerializer = (MarcarNoRecogidoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<MarcarNoRecogidoData, MarcarNoRecogidoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<MarcarNoRecogidoData, MarcarNoRecogidoVariables> ref() {
    MarcarNoRecogidoVariables vars= MarcarNoRecogidoVariables(id: id,);
    return _dataConnect.mutation("MarcarNoRecogido", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class MarcarNoRecogidoData {
  final int? execute_;
  MarcarNoRecogidoData.fromJson(dynamic json):
  
  execute_ = json['_execute'] == null ? null : nativeFromJson<int>(json['_execute']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MarcarNoRecogidoData otherTyped = other as MarcarNoRecogidoData;
    return execute_ == otherTyped.execute_;
    
  }
  @override
  int get hashCode => execute_.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (execute_ != null) {
      json['_execute'] = nativeToJson<int?>(execute_);
    }
    return json;
  }

  MarcarNoRecogidoData({
    this.execute_,
  });
}

@immutable
class MarcarNoRecogidoVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  MarcarNoRecogidoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MarcarNoRecogidoVariables otherTyped = other as MarcarNoRecogidoVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  MarcarNoRecogidoVariables({
    required this.id,
  });
}

