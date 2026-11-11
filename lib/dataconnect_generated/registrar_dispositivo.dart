part of 'agilu.dart';

class RegistrarDispositivoVariablesBuilder {
  String token;
  String plataforma;

  final FirebaseDataConnect _dataConnect;
  RegistrarDispositivoVariablesBuilder(
    this._dataConnect, {
    required this.token,
    required this.plataforma,
  });
  Deserializer<RegistrarDispositivoData> dataDeserializer =
      (dynamic json) => RegistrarDispositivoData.fromJson(jsonDecode(json));
  Serializer<RegistrarDispositivoVariables> varsSerializer =
      (RegistrarDispositivoVariables vars) => jsonEncode(vars.toJson());
  Future<
      OperationResult<RegistrarDispositivoData,
          RegistrarDispositivoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<RegistrarDispositivoData, RegistrarDispositivoVariables> ref() {
    RegistrarDispositivoVariables vars = RegistrarDispositivoVariables(
      token: token,
      plataforma: plataforma,
    );
    return _dataConnect.mutation(
        "RegistrarDispositivo", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class RegistrarDispositivoDispositivoTokenUpsert {
  final String token;
  RegistrarDispositivoDispositivoTokenUpsert.fromJson(dynamic json)
      : token = nativeFromJson<String>(json['token']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final RegistrarDispositivoDispositivoTokenUpsert otherTyped =
        other as RegistrarDispositivoDispositivoTokenUpsert;
    return token == otherTyped.token;
  }

  @override
  int get hashCode => token.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['token'] = nativeToJson<String>(token);
    return json;
  }

  RegistrarDispositivoDispositivoTokenUpsert({
    required this.token,
  });
}

@immutable
class RegistrarDispositivoData {
  final RegistrarDispositivoDispositivoTokenUpsert dispositivoToken_upsert;
  RegistrarDispositivoData.fromJson(dynamic json)
      : dispositivoToken_upsert =
            RegistrarDispositivoDispositivoTokenUpsert.fromJson(
                json['dispositivoToken_upsert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final RegistrarDispositivoData otherTyped =
        other as RegistrarDispositivoData;
    return dispositivoToken_upsert == otherTyped.dispositivoToken_upsert;
  }

  @override
  int get hashCode => dispositivoToken_upsert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['dispositivoToken_upsert'] = dispositivoToken_upsert.toJson();
    return json;
  }

  RegistrarDispositivoData({
    required this.dispositivoToken_upsert,
  });
}

@immutable
class RegistrarDispositivoVariables {
  final String token;
  final String plataforma;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  RegistrarDispositivoVariables.fromJson(Map<String, dynamic> json)
      : token = nativeFromJson<String>(json['token']),
        plataforma = nativeFromJson<String>(json['plataforma']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final RegistrarDispositivoVariables otherTyped =
        other as RegistrarDispositivoVariables;
    return token == otherTyped.token && plataforma == otherTyped.plataforma;
  }

  @override
  int get hashCode => Object.hashAll([token.hashCode, plataforma.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['token'] = nativeToJson<String>(token);
    json['plataforma'] = nativeToJson<String>(plataforma);
    return json;
  }

  RegistrarDispositivoVariables({
    required this.token,
    required this.plataforma,
  });
}
