part of 'agilu.dart';

class AgregarEmpleadoVariablesBuilder {
  String correo;

  final FirebaseDataConnect _dataConnect;
  AgregarEmpleadoVariablesBuilder(this._dataConnect, {required  this.correo,});
  Deserializer<AgregarEmpleadoData> dataDeserializer = (dynamic json)  => AgregarEmpleadoData.fromJson(jsonDecode(json));
  Serializer<AgregarEmpleadoVariables> varsSerializer = (AgregarEmpleadoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AgregarEmpleadoData, AgregarEmpleadoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AgregarEmpleadoData, AgregarEmpleadoVariables> ref() {
    AgregarEmpleadoVariables vars= AgregarEmpleadoVariables(correo: correo,);
    return _dataConnect.mutation("AgregarEmpleado", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AgregarEmpleadoData {
  final AnyValue? resultado;
  AgregarEmpleadoData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AgregarEmpleadoData otherTyped = other as AgregarEmpleadoData;
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

  AgregarEmpleadoData({
    this.resultado,
  });
}

@immutable
class AgregarEmpleadoVariables {
  final String correo;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AgregarEmpleadoVariables.fromJson(Map<String, dynamic> json):
  
  correo = nativeFromJson<String>(json['correo']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AgregarEmpleadoVariables otherTyped = other as AgregarEmpleadoVariables;
    return correo == otherTyped.correo;
    
  }
  @override
  int get hashCode => correo.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['correo'] = nativeToJson<String>(correo);
    return json;
  }

  AgregarEmpleadoVariables({
    required this.correo,
  });
}

