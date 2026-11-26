part of 'agilu.dart';

class AsignarEstacionVariablesBuilder {
  String usuarioId;
  Optional<String> _estacionId = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  AsignarEstacionVariablesBuilder estacionId(String? t) {
   _estacionId.value = t;
   return this;
  }

  AsignarEstacionVariablesBuilder(this._dataConnect, {required  this.usuarioId,});
  Deserializer<AsignarEstacionData> dataDeserializer = (dynamic json)  => AsignarEstacionData.fromJson(jsonDecode(json));
  Serializer<AsignarEstacionVariables> varsSerializer = (AsignarEstacionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AsignarEstacionData, AsignarEstacionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AsignarEstacionData, AsignarEstacionVariables> ref() {
    AsignarEstacionVariables vars= AsignarEstacionVariables(usuarioId: usuarioId,estacionId: _estacionId,);
    return _dataConnect.mutation("AsignarEstacion", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AsignarEstacionData {
  final AnyValue? resultado;
  AsignarEstacionData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AsignarEstacionData otherTyped = other as AsignarEstacionData;
    return resultado == otherTyped.resultado;
    
  }
  @override
  int get hashCode => resultado.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (resultado != null) {
      json['resultado'] = resultado!.toJson();
    }
    return json;
  }

  AsignarEstacionData({
    this.resultado,
  });
}

@immutable
class AsignarEstacionVariables {
  final String usuarioId;
  late final Optional<String>estacionId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AsignarEstacionVariables.fromJson(Map<String, dynamic> json):
  
  usuarioId = nativeFromJson<String>(json['usuarioId']) {
  
  
  
    estacionId = Optional.optional(nativeFromJson, nativeToJson);
    estacionId.value = json['estacionId'] == null ? null : nativeFromJson<String>(json['estacionId']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AsignarEstacionVariables otherTyped = other as AsignarEstacionVariables;
    return usuarioId == otherTyped.usuarioId && 
    estacionId == otherTyped.estacionId;
    
  }
  @override
  int get hashCode => Object.hashAll([usuarioId.hashCode, estacionId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuarioId'] = nativeToJson<String>(usuarioId);
    if(estacionId.state == OptionalState.set) {
      json['estacionId'] = estacionId.toJson();
    }
    return json;
  }

  AsignarEstacionVariables({
    required this.usuarioId,
    required this.estacionId,
  });
}

