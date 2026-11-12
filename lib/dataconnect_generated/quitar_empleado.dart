part of 'agilu.dart';

class QuitarEmpleadoVariablesBuilder {
  String usuarioId;

  final FirebaseDataConnect _dataConnect;
  QuitarEmpleadoVariablesBuilder(this._dataConnect, {required  this.usuarioId,});
  Deserializer<QuitarEmpleadoData> dataDeserializer = (dynamic json)  => QuitarEmpleadoData.fromJson(jsonDecode(json));
  Serializer<QuitarEmpleadoVariables> varsSerializer = (QuitarEmpleadoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<QuitarEmpleadoData, QuitarEmpleadoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<QuitarEmpleadoData, QuitarEmpleadoVariables> ref() {
    QuitarEmpleadoVariables vars= QuitarEmpleadoVariables(usuarioId: usuarioId,);
    return _dataConnect.mutation("QuitarEmpleado", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class QuitarEmpleadoData {
  final AnyValue? resultado;
  QuitarEmpleadoData.fromJson(dynamic json):
  
  resultado = json['resultado'] == null ? null : AnyValue.fromJson(json['resultado']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final QuitarEmpleadoData otherTyped = other as QuitarEmpleadoData;
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

  QuitarEmpleadoData({
    this.resultado,
  });
}

@immutable
class QuitarEmpleadoVariables {
  final String usuarioId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  QuitarEmpleadoVariables.fromJson(Map<String, dynamic> json):
  
  usuarioId = nativeFromJson<String>(json['usuarioId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final QuitarEmpleadoVariables otherTyped = other as QuitarEmpleadoVariables;
    return usuarioId == otherTyped.usuarioId;
    
  }
  @override
  int get hashCode => usuarioId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuarioId'] = nativeToJson<String>(usuarioId);
    return json;
  }

  QuitarEmpleadoVariables({
    required this.usuarioId,
  });
}

