part of 'agilu.dart';

class MiConfianzaVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  MiConfianzaVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<MiConfianzaData> dataDeserializer =
      (dynamic json) => MiConfianzaData.fromJson(jsonDecode(json));

  Future<QueryResult<MiConfianzaData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MiConfianzaData, void> ref() {
    return _dataConnect.query(
        "MiConfianza", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MiConfianzaData {
  final AnyValue? confianza;
  MiConfianzaData.fromJson(dynamic json)
      : confianza = json['confianza'] == null
            ? null
            : AnyValue.fromJson(json['confianza']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MiConfianzaData otherTyped = other as MiConfianzaData;
    return confianza == otherTyped.confianza;
  }

  @override
  int get hashCode => confianza.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (confianza != null) {
      json['confianza'] = confianza!.toJson();
    }
    return json;
  }

  MiConfianzaData({
    this.confianza,
  });
}
