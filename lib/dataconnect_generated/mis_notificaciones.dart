part of 'agilu.dart';

class MisNotificacionesVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  MisNotificacionesVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<MisNotificacionesData> dataDeserializer =
      (dynamic json) => MisNotificacionesData.fromJson(jsonDecode(json));

  Future<QueryResult<MisNotificacionesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MisNotificacionesData, void> ref() {
    return _dataConnect.query(
        "MisNotificaciones", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MisNotificacionesNotificacions {
  final String id;
  final String titulo;
  final String mensaje;
  final Timestamp fechaEnvio;
  final bool leido;
  MisNotificacionesNotificacions.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        titulo = nativeFromJson<String>(json['titulo']),
        mensaje = nativeFromJson<String>(json['mensaje']),
        fechaEnvio = Timestamp.fromJson(json['fechaEnvio']),
        leido = nativeFromJson<bool>(json['leido']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MisNotificacionesNotificacions otherTyped =
        other as MisNotificacionesNotificacions;
    return id == otherTyped.id &&
        titulo == otherTyped.titulo &&
        mensaje == otherTyped.mensaje &&
        fechaEnvio == otherTyped.fechaEnvio &&
        leido == otherTyped.leido;
  }

  @override
  int get hashCode => Object.hashAll([
        id.hashCode,
        titulo.hashCode,
        mensaje.hashCode,
        fechaEnvio.hashCode,
        leido.hashCode
      ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['titulo'] = nativeToJson<String>(titulo);
    json['mensaje'] = nativeToJson<String>(mensaje);
    json['fechaEnvio'] = fechaEnvio.toJson();
    json['leido'] = nativeToJson<bool>(leido);
    return json;
  }

  MisNotificacionesNotificacions({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fechaEnvio,
    required this.leido,
  });
}

@immutable
class MisNotificacionesData {
  final List<MisNotificacionesNotificacions> notificacions;
  MisNotificacionesData.fromJson(dynamic json)
      : notificacions = (json['notificacions'] as List<dynamic>)
            .map((e) => MisNotificacionesNotificacions.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MisNotificacionesData otherTyped = other as MisNotificacionesData;
    return notificacions == otherTyped.notificacions;
  }

  @override
  int get hashCode => notificacions.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['notificacions'] = notificacions.map((e) => e.toJson()).toList();
    return json;
  }

  MisNotificacionesData({
    required this.notificacions,
  });
}
