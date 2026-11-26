part of 'agilu.dart';

class ReporteCafeteriaVariablesBuilder {
  Timestamp desde;
  Timestamp hasta;

  final FirebaseDataConnect _dataConnect;
  ReporteCafeteriaVariablesBuilder(this._dataConnect, {required  this.desde,required  this.hasta,});
  Deserializer<ReporteCafeteriaData> dataDeserializer = (dynamic json)  => ReporteCafeteriaData.fromJson(jsonDecode(json));
  Serializer<ReporteCafeteriaVariables> varsSerializer = (ReporteCafeteriaVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ReporteCafeteriaData, ReporteCafeteriaVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ReporteCafeteriaData, ReporteCafeteriaVariables> ref() {
    ReporteCafeteriaVariables vars= ReporteCafeteriaVariables(desde: desde,hasta: hasta,);
    return _dataConnect.query("ReporteCafeteria", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ReporteCafeteriaData {
  final List<AnyValue>? filas;
  ReporteCafeteriaData.fromJson(dynamic json):
  
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

    final ReporteCafeteriaData otherTyped = other as ReporteCafeteriaData;
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

  ReporteCafeteriaData({
    this.filas,
  });
}

@immutable
class ReporteCafeteriaVariables {
  final Timestamp desde;
  final Timestamp hasta;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ReporteCafeteriaVariables.fromJson(Map<String, dynamic> json):
  
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

    final ReporteCafeteriaVariables otherTyped = other as ReporteCafeteriaVariables;
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

  ReporteCafeteriaVariables({
    required this.desde,
    required this.hasta,
  });
}

