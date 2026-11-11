part of 'agilu.dart';

class PanelPedidosVariablesBuilder {
  Timestamp desde;
  Timestamp hasta;

  final FirebaseDataConnect _dataConnect;
  PanelPedidosVariablesBuilder(
    this._dataConnect, {
    required this.desde,
    required this.hasta,
  });
  Deserializer<PanelPedidosData> dataDeserializer =
      (dynamic json) => PanelPedidosData.fromJson(jsonDecode(json));
  Serializer<PanelPedidosVariables> varsSerializer =
      (PanelPedidosVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<PanelPedidosData, PanelPedidosVariables>> execute() {
    return ref().execute();
  }

  QueryRef<PanelPedidosData, PanelPedidosVariables> ref() {
    PanelPedidosVariables vars = PanelPedidosVariables(
      desde: desde,
      hasta: hasta,
    );
    return _dataConnect.query(
        "PanelPedidos", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class PanelPedidosPedidos {
  final String id;
  final int folio;
  final String estado;
  final Timestamp recogerA;
  final String? notas;
  final double montoTotal;
  final int intentosEntrega;
  final PanelPedidosPedidosUsuario usuario;
  final List<PanelPedidosPedidosDetallePedidosOnPedido>
      detallePedidos_on_pedido;
  PanelPedidosPedidos.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        folio = nativeFromJson<int>(json['folio']),
        estado = nativeFromJson<String>(json['estado']),
        recogerA = Timestamp.fromJson(json['recogerA']),
        notas = json['notas'] == null
            ? null
            : nativeFromJson<String>(json['notas']),
        montoTotal = nativeFromJson<double>(json['montoTotal']),
        intentosEntrega = nativeFromJson<int>(json['intentosEntrega']),
        usuario = PanelPedidosPedidosUsuario.fromJson(json['usuario']),
        detallePedidos_on_pedido = (json['detallePedidos_on_pedido']
                as List<dynamic>)
            .map((e) => PanelPedidosPedidosDetallePedidosOnPedido.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PanelPedidosPedidos otherTyped = other as PanelPedidosPedidos;
    return id == otherTyped.id &&
        folio == otherTyped.folio &&
        estado == otherTyped.estado &&
        recogerA == otherTyped.recogerA &&
        notas == otherTyped.notas &&
        montoTotal == otherTyped.montoTotal &&
        intentosEntrega == otherTyped.intentosEntrega &&
        usuario == otherTyped.usuario &&
        detallePedidos_on_pedido == otherTyped.detallePedidos_on_pedido;
  }

  @override
  int get hashCode => Object.hashAll([
        id.hashCode,
        folio.hashCode,
        estado.hashCode,
        recogerA.hashCode,
        notas.hashCode,
        montoTotal.hashCode,
        intentosEntrega.hashCode,
        usuario.hashCode,
        detallePedidos_on_pedido.hashCode
      ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['folio'] = nativeToJson<int>(folio);
    json['estado'] = nativeToJson<String>(estado);
    json['recogerA'] = recogerA.toJson();
    if (notas != null) {
      json['notas'] = nativeToJson<String?>(notas);
    }
    json['montoTotal'] = nativeToJson<double>(montoTotal);
    json['intentosEntrega'] = nativeToJson<int>(intentosEntrega);
    json['usuario'] = usuario.toJson();
    json['detallePedidos_on_pedido'] =
        detallePedidos_on_pedido.map((e) => e.toJson()).toList();
    return json;
  }

  PanelPedidosPedidos({
    required this.id,
    required this.folio,
    required this.estado,
    required this.recogerA,
    this.notas,
    required this.montoTotal,
    required this.intentosEntrega,
    required this.usuario,
    required this.detallePedidos_on_pedido,
  });
}

@immutable
class PanelPedidosPedidosUsuario {
  final String nombre;
  PanelPedidosPedidosUsuario.fromJson(dynamic json)
      : nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PanelPedidosPedidosUsuario otherTyped =
        other as PanelPedidosPedidosUsuario;
    return nombre == otherTyped.nombre;
  }

  @override
  int get hashCode => nombre.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  PanelPedidosPedidosUsuario({
    required this.nombre,
  });
}

@immutable
class PanelPedidosPedidosDetallePedidosOnPedido {
  final int cantidad;
  final PanelPedidosPedidosDetallePedidosOnPedidoProducto producto;
  PanelPedidosPedidosDetallePedidosOnPedido.fromJson(dynamic json)
      : cantidad = nativeFromJson<int>(json['cantidad']),
        producto = PanelPedidosPedidosDetallePedidosOnPedidoProducto.fromJson(
            json['producto']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PanelPedidosPedidosDetallePedidosOnPedido otherTyped =
        other as PanelPedidosPedidosDetallePedidosOnPedido;
    return cantidad == otherTyped.cantidad && producto == otherTyped.producto;
  }

  @override
  int get hashCode => Object.hashAll([cantidad.hashCode, producto.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cantidad'] = nativeToJson<int>(cantidad);
    json['producto'] = producto.toJson();
    return json;
  }

  PanelPedidosPedidosDetallePedidosOnPedido({
    required this.cantidad,
    required this.producto,
  });
}

@immutable
class PanelPedidosPedidosDetallePedidosOnPedidoProducto {
  final String nombre;
  PanelPedidosPedidosDetallePedidosOnPedidoProducto.fromJson(dynamic json)
      : nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PanelPedidosPedidosDetallePedidosOnPedidoProducto otherTyped =
        other as PanelPedidosPedidosDetallePedidosOnPedidoProducto;
    return nombre == otherTyped.nombre;
  }

  @override
  int get hashCode => nombre.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  PanelPedidosPedidosDetallePedidosOnPedidoProducto({
    required this.nombre,
  });
}

@immutable
class PanelPedidosData {
  final List<PanelPedidosPedidos> pedidos;
  PanelPedidosData.fromJson(dynamic json)
      : pedidos = (json['pedidos'] as List<dynamic>)
            .map((e) => PanelPedidosPedidos.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PanelPedidosData otherTyped = other as PanelPedidosData;
    return pedidos == otherTyped.pedidos;
  }

  @override
  int get hashCode => pedidos.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pedidos'] = pedidos.map((e) => e.toJson()).toList();
    return json;
  }

  PanelPedidosData({
    required this.pedidos,
  });
}

@immutable
class PanelPedidosVariables {
  final Timestamp desde;
  final Timestamp hasta;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  PanelPedidosVariables.fromJson(Map<String, dynamic> json)
      : desde = Timestamp.fromJson(json['desde']),
        hasta = Timestamp.fromJson(json['hasta']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final PanelPedidosVariables otherTyped = other as PanelPedidosVariables;
    return desde == otherTyped.desde && hasta == otherTyped.hasta;
  }

  @override
  int get hashCode => Object.hashAll([desde.hashCode, hasta.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['desde'] = desde.toJson();
    json['hasta'] = hasta.toJson();
    return json;
  }

  PanelPedidosVariables({
    required this.desde,
    required this.hasta,
  });
}
