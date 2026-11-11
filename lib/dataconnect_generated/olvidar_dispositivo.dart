part of 'agilu.dart';

class OlvidarDispositivoVariablesBuilder {
  String token;

  final FirebaseDataConnect _dataConnect;
  OlvidarDispositivoVariablesBuilder(this._dataConnect, {required  this.token,});
  Deserializer<OlvidarDispositivoData> dataDeserializer = (dynamic json)  => OlvidarDispositivoData.fromJson(jsonDecode(json));
  Serializer<OlvidarDispositivoVariables> varsSerializer = (OlvidarDispositivoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<OlvidarDispositivoData, OlvidarDispositivoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<OlvidarDispositivoData, OlvidarDispositivoVariables> ref() {
    OlvidarDispositivoVariables vars= OlvidarDispositivoVariables(token: token,);
    return _dataConnect.mutation("OlvidarDispositivo", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class OlvidarDispositivoData {
  final int dispositivoToken_deleteMany;
  OlvidarDispositivoData.fromJson(dynamic json):
  
  dispositivoToken_deleteMany = nativeFromJson<int>(json['dispositivoToken_deleteMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final OlvidarDispositivoData otherTyped = other as OlvidarDispositivoData;
    return dispositivoToken_deleteMany == otherTyped.dispositivoToken_deleteMany;
    
  }
  @override
  int get hashCode => dispositivoToken_deleteMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['dispositivoToken_deleteMany'] = nativeToJson<int>(dispositivoToken_deleteMany);
    return json;
  }

  OlvidarDispositivoData({
    required this.dispositivoToken_deleteMany,
  });
}

@immutable
class OlvidarDispositivoVariables {
  final String token;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  OlvidarDispositivoVariables.fromJson(Map<String, dynamic> json):
  
  token = nativeFromJson<String>(json['token']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final OlvidarDispositivoVariables otherTyped = other as OlvidarDispositivoVariables;
    return token == otherTyped.token;
    
  }
  @override
  int get hashCode => token.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['token'] = nativeToJson<String>(token);
    return json;
  }

  OlvidarDispositivoVariables({
    required this.token,
  });
}

