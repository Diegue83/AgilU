part of 'agilu.dart';

class ValidarPagoVariablesBuilder {
  String id;
  bool aprobado;
  Optional<String> _motivo = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  ValidarPagoVariablesBuilder motivo(String? t) {
   _motivo.value = t;
   return this;
  }

  ValidarPagoVariablesBuilder(this._dataConnect, {required  this.id,required  this.aprobado,});
  Deserializer<ValidarPagoData> dataDeserializer = (dynamic json)  => ValidarPagoData.fromJson(jsonDecode(json));
  Serializer<ValidarPagoVariables> varsSerializer = (ValidarPagoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<ValidarPagoData, ValidarPagoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<ValidarPagoData, ValidarPagoVariables> ref() {
    ValidarPagoVariables vars= ValidarPagoVariables(id: id,aprobado: aprobado,motivo: _motivo,);
    return _dataConnect.mutation("ValidarPago", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ValidarPagoData {
  final int? execute_;
  ValidarPagoData.fromJson(dynamic json):
  
  execute_ = json['_execute'] == null ? null : nativeFromJson<int>(json['_execute']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ValidarPagoData otherTyped = other as ValidarPagoData;
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

  ValidarPagoData({
    this.execute_,
  });
}

@immutable
class ValidarPagoVariables {
  final String id;
  final bool aprobado;
  late final Optional<String>motivo;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ValidarPagoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  aprobado = nativeFromJson<bool>(json['aprobado']) {
  
  
  
  
    motivo = Optional.optional(nativeFromJson, nativeToJson);
    motivo.value = json['motivo'] == null ? null : nativeFromJson<String>(json['motivo']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ValidarPagoVariables otherTyped = other as ValidarPagoVariables;
    return id == otherTyped.id && 
    aprobado == otherTyped.aprobado && 
    motivo == otherTyped.motivo;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, aprobado.hashCode, motivo.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['aprobado'] = nativeToJson<bool>(aprobado);
    if(motivo.state == OptionalState.set) {
      json['motivo'] = motivo.toJson();
    }
    return json;
  }

  ValidarPagoVariables({
    required this.id,
    required this.aprobado,
    required this.motivo,
  });
}

