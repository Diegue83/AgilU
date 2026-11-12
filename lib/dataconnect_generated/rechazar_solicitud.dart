part of 'agilu.dart';

class RechazarSolicitudVariablesBuilder {
  String usuarioId;

  final FirebaseDataConnect _dataConnect;
  RechazarSolicitudVariablesBuilder(this._dataConnect, {required  this.usuarioId,});
  Deserializer<RechazarSolicitudData> dataDeserializer = (dynamic json)  => RechazarSolicitudData.fromJson(jsonDecode(json));
  Serializer<RechazarSolicitudVariables> varsSerializer = (RechazarSolicitudVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<RechazarSolicitudData, RechazarSolicitudVariables>> execute() {
    return ref().execute();
  }

  MutationRef<RechazarSolicitudData, RechazarSolicitudVariables> ref() {
    RechazarSolicitudVariables vars= RechazarSolicitudVariables(usuarioId: usuarioId,);
    return _dataConnect.mutation("RechazarSolicitud", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class RechazarSolicitudData {
  final int solicitudEmpleo_deleteMany;
  RechazarSolicitudData.fromJson(dynamic json):
  
  solicitudEmpleo_deleteMany = nativeFromJson<int>(json['solicitudEmpleo_deleteMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RechazarSolicitudData otherTyped = other as RechazarSolicitudData;
    return solicitudEmpleo_deleteMany == otherTyped.solicitudEmpleo_deleteMany;
    
  }
  @override
  int get hashCode => solicitudEmpleo_deleteMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['solicitudEmpleo_deleteMany'] = nativeToJson<int>(solicitudEmpleo_deleteMany);
    return json;
  }

  RechazarSolicitudData({
    required this.solicitudEmpleo_deleteMany,
  });
}

@immutable
class RechazarSolicitudVariables {
  final String usuarioId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  RechazarSolicitudVariables.fromJson(Map<String, dynamic> json):
  
  usuarioId = nativeFromJson<String>(json['usuarioId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RechazarSolicitudVariables otherTyped = other as RechazarSolicitudVariables;
    return usuarioId == otherTyped.usuarioId;
    
  }
  @override
  int get hashCode => usuarioId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['usuarioId'] = nativeToJson<String>(usuarioId);
    return json;
  }

  RechazarSolicitudVariables({
    required this.usuarioId,
  });
}

