part of 'agilu.dart';

class PagosPorValidarVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  PagosPorValidarVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<PagosPorValidarData> dataDeserializer =
      (dynamic json) => PagosPorValidarData.fromJson(jsonDecode(json));

  Future<QueryResult<PagosPorValidarData, void>> execute() {
    return ref().execute();
  }

  QueryRef<PagosPorValidarData, void> ref() {
    return _dataConnect.query(
        "PagosPorValidar", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class PagosPorValidarPedidos {
  final String id;
  final int folio;
  final String? referenciaPago;
  final double montoTotal;
  final Timestamp recogerA;
  final String? comprobanteUrl;
  final PagosPorValidarPedidosUsuario usuario;
  PagosPorValidarPedidos.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        folio = nativeFromJson<int>(json['folio']),
        referenciaPago = json['referenciaPago'] == null
            ? null
            : nativeFromJson<String>(json['referenciaPago']),
        montoTotal = nativeFromJson<double>(json['montoTotal']),
        recogerA = Timestamp.fromJson(json['recogerA']),
        comprobanteUrl = json['comprobanteUrl'] == null
            ? null
            : nativeFromJson<String>(json['comprobanteUrl']),
        usuario = PagosPorValidarPedidosUsuario.fromJson(json['usuario']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PagosPorValidarPedidos otherTyped = other as PagosPorValidarPedidos;
    return id == otherTyped.id &&
        folio == otherTyped.folio &&
        referenciaPago == otherTyped.referenciaPago &&
        montoTotal == otherTyped.montoTotal &&
        recogerA == otherTyped.recogerA &&
        comprobanteUrl == otherTyped.comprobanteUrl &&
        usuario == otherTyped.usuario;
  }

  @override
  int get hashCode => Object.hashAll([
        id.hashCode,
        folio.hashCode,
        referenciaPago.hashCode,
        montoTotal.hashCode,
        recogerA.hashCode,
        comprobanteUrl.hashCode,
        usuario.hashCode
      ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['folio'] = nativeToJson<int>(folio);
    if (referenciaPago != null) {
      json['referenciaPago'] = nativeToJson<String?>(referenciaPago);
    }
    json['montoTotal'] = nativeToJson<double>(montoTotal);
    json['recogerA'] = recogerA.toJson();
    if (comprobanteUrl != null) {
      json['comprobanteUrl'] = nativeToJson<String?>(comprobanteUrl);
    }
    json['usuario'] = usuario.toJson();
    return json;
  }

  PagosPorValidarPedidos({
    required this.id,
    required this.folio,
    this.referenciaPago,
    required this.montoTotal,
    required this.recogerA,
    this.comprobanteUrl,
    required this.usuario,
  });
}

@immutable
class PagosPorValidarPedidosUsuario {
  final String nombre;
  PagosPorValidarPedidosUsuario.fromJson(dynamic json)
      : nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PagosPorValidarPedidosUsuario otherTyped =
        other as PagosPorValidarPedidosUsuario;
    return nombre == otherTyped.nombre;
  }

  @override
  int get hashCode => nombre.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  PagosPorValidarPedidosUsuario({
    required this.nombre,
  });
}

@immutable
class PagosPorValidarData {
  final List<PagosPorValidarPedidos> pedidos;
  PagosPorValidarData.fromJson(dynamic json)
      : pedidos = (json['pedidos'] as List<dynamic>)
            .map((e) => PagosPorValidarPedidos.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PagosPorValidarData otherTyped = other as PagosPorValidarData;
    return pedidos == otherTyped.pedidos;
  }

  @override
  int get hashCode => pedidos.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pedidos'] = pedidos.map((e) => e.toJson()).toList();
    return json;
  }

  PagosPorValidarData({
    required this.pedidos,
  });
}
