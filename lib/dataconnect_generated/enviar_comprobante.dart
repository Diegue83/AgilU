part of 'agilu.dart';

class EnviarComprobanteVariablesBuilder {
  String pedidoId;
  String ruta;

  final FirebaseDataConnect _dataConnect;
  EnviarComprobanteVariablesBuilder(this._dataConnect, {required  this.pedidoId,required  this.ruta,});
  Deserializer<EnviarComprobanteData> dataDeserializer = (dynamic json)  => EnviarComprobanteData.fromJson(jsonDecode(json));
  Serializer<EnviarComprobanteVariables> varsSerializer = (EnviarComprobanteVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EnviarComprobanteData, EnviarComprobanteVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EnviarComprobanteData, EnviarComprobanteVariables> ref() {
    EnviarComprobanteVariables vars= EnviarComprobanteVariables(pedidoId: pedidoId,ruta: ruta,);
    return _dataConnect.mutation("EnviarComprobante", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EnviarComprobanteData {
  final AnyValue? resultado;
  EnviarComprobanteData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EnviarComprobanteData otherTyped = other as EnviarComprobanteData;
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

  EnviarComprobanteData({
    this.resultado,
  });
}

@immutable
class EnviarComprobanteVariables {
  final String pedidoId;
  final String ruta;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EnviarComprobanteVariables.fromJson(Map<String, dynamic> json):
  
  pedidoId = nativeFromJson<String>(json['pedidoId']),
  ruta = nativeFromJson<String>(json['ruta']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EnviarComprobanteVariables otherTyped = other as EnviarComprobanteVariables;
    return pedidoId == otherTyped.pedidoId && 
    ruta == otherTyped.ruta;
    
  }
  @override
  int get hashCode => Object.hashAll([pedidoId.hashCode, ruta.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pedidoId'] = nativeToJson<String>(pedidoId);
    json['ruta'] = nativeToJson<String>(ruta);
    return json;
  }

  EnviarComprobanteVariables({
    required this.pedidoId,
    required this.ruta,
  });
}

