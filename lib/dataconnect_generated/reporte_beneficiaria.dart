part of 'agilu.dart';

class ReporteBeneficiariaVariablesBuilder {
  Timestamp desde;
  Timestamp hasta;

  final FirebaseDataConnect _dataConnect;
  ReporteBeneficiariaVariablesBuilder(this._dataConnect, {required  this.desde,required  this.hasta,});
  Deserializer<ReporteBeneficiariaData> dataDeserializer = (dynamic json)  => ReporteBeneficiariaData.fromJson(jsonDecode(json));
  Serializer<ReporteBeneficiariaVariables> varsSerializer = (ReporteBeneficiariaVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ReporteBeneficiariaData, ReporteBeneficiariaVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ReporteBeneficiariaData, ReporteBeneficiariaVariables> ref() {
    ReporteBeneficiariaVariables vars= ReporteBeneficiariaVariables(desde: desde,hasta: hasta,);
    return _dataConnect.query("ReporteBeneficiaria", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ReporteBeneficiariaData {
  final List<AnyValue>? filas;
  ReporteBeneficiariaData.fromJson(dynamic json):
  
  filas = json['filas'] == null ? null : (json['filas'] as List<dynamic>)
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

    final ReporteBeneficiariaData otherTyped = other as ReporteBeneficiariaData;
    return filas == otherTyped.filas;
    
  }
  @override
  int get hashCode => filas.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (filas != null) {
      json['filas'] = filas?.map((e) => e!.toJson()).toList();
    }
    return json;
  }

  ReporteBeneficiariaData({
    this.filas,
  });
}

@immutable
class ReporteBeneficiariaVariables {
  final Timestamp desde;
  final Timestamp hasta;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ReporteBeneficiariaVariables.fromJson(Map<String, dynamic> json):
  
  desde = Timestamp.fromJson(json['desde']),
  hasta = Timestamp.fromJson(json['hasta']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ReporteBeneficiariaVariables otherTyped = other as ReporteBeneficiariaVariables;
    return desde == otherTyped.desde && 
    hasta == otherTyped.hasta;
    
  }
  @override
  int get hashCode => Object.hashAll([desde.hashCode, hasta.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['desde'] = desde.toJson();
    json['hasta'] = hasta.toJson();
    return json;
  }

  ReporteBeneficiariaVariables({
    required this.desde,
    required this.hasta,
  });
}

