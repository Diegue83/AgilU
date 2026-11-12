part of 'agilu.dart';

class HistorialPedidosVariablesBuilder {
  Timestamp desde;
  Timestamp hasta;

  final FirebaseDataConnect _dataConnect;
  HistorialPedidosVariablesBuilder(this._dataConnect, {required  this.desde,required  this.hasta,});
  Deserializer<HistorialPedidosData> dataDeserializer = (dynamic json)  => HistorialPedidosData.fromJson(jsonDecode(json));
  Serializer<HistorialPedidosVariables> varsSerializer = (HistorialPedidosVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<HistorialPedidosData, HistorialPedidosVariables>> execute() {
    return ref().execute();
  }

  QueryRef<HistorialPedidosData, HistorialPedidosVariables> ref() {
    HistorialPedidosVariables vars= HistorialPedidosVariables(desde: desde,hasta: hasta,);
    return _dataConnect.query("HistorialPedidos", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class HistorialPedidosPedidos {
  final String id;
  final int folio;
  final String estado;
  final Timestamp recogerA;
  final String? notas;
  final double montoTotal;
  final HistorialPedidosPedidosUsuario usuario;
  final List<HistorialPedidosPedidosDetallePedidosOnPedido> detallePedidos_on_pedido;
  HistorialPedidosPedidos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  folio = nativeFromJson<int>(json['folio']),
  estado = nativeFromJson<String>(json['estado']),
  recogerA = Timestamp.fromJson(json['recogerA']),
  notas = json['notas'] == null ? null : nativeFromJson<String>(json['notas']),
  montoTotal = nativeFromJson<double>(json['montoTotal']),
  usuario = HistorialPedidosPedidosUsuario.fromJson(json['usuario']),
  detallePedidos_on_pedido = (json['detallePedidos_on_pedido'] as List<dynamic>)
        .map((e) => HistorialPedidosPedidosDetallePedidosOnPedido.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final HistorialPedidosPedidos otherTyped = other as HistorialPedidosPedidos;
    return id == otherTyped.id && 
    folio == otherTyped.folio && 
    estado == otherTyped.estado && 
    recogerA == otherTyped.recogerA && 
    notas == otherTyped.notas && 
    montoTotal == otherTyped.montoTotal && 
    usuario == otherTyped.usuario && 
    detallePedidos_on_pedido == otherTyped.detallePedidos_on_pedido;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, folio.hashCode, estado.hashCode, recogerA.hashCode, notas.hashCode, montoTotal.hashCode, usuario.hashCode, detallePedidos_on_pedido.hashCode]);
  

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
    json['usuario'] = usuario.toJson();
    json['detallePedidos_on_pedido'] = detallePedidos_on_pedido.map((e) => e.toJson()).toList();
    return json;
  }

  HistorialPedidosPedidos({
    required this.id,
    required this.folio,
    required this.estado,
    required this.recogerA,
    this.notas,
    required this.montoTotal,
    required this.usuario,
    required this.detallePedidos_on_pedido,
  });
}

@immutable
class HistorialPedidosPedidosUsuario {
  final String nombre;
  HistorialPedidosPedidosUsuario.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final HistorialPedidosPedidosUsuario otherTyped = other as HistorialPedidosPedidosUsuario;
    return nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => nombre.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  HistorialPedidosPedidosUsuario({
    required this.nombre,
  });
}

@immutable
class HistorialPedidosPedidosDetallePedidosOnPedido {
  final int cantidad;
  final HistorialPedidosPedidosDetallePedidosOnPedidoProducto producto;
  HistorialPedidosPedidosDetallePedidosOnPedido.fromJson(dynamic json):
  
  cantidad = nativeFromJson<int>(json['cantidad']),
  producto = HistorialPedidosPedidosDetallePedidosOnPedidoProducto.fromJson(json['producto']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final HistorialPedidosPedidosDetallePedidosOnPedido otherTyped = other as HistorialPedidosPedidosDetallePedidosOnPedido;
    return cantidad == otherTyped.cantidad && 
    producto == otherTyped.producto;
    
  }
  @override
  int get hashCode => Object.hashAll([cantidad.hashCode, producto.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cantidad'] = nativeToJson<int>(cantidad);
    json['producto'] = producto.toJson();
    return json;
  }

  HistorialPedidosPedidosDetallePedidosOnPedido({
    required this.cantidad,
    required this.producto,
  });
}

@immutable
class HistorialPedidosPedidosDetallePedidosOnPedidoProducto {
  final String nombre;
  HistorialPedidosPedidosDetallePedidosOnPedidoProducto.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final HistorialPedidosPedidosDetallePedidosOnPedidoProducto otherTyped = other as HistorialPedidosPedidosDetallePedidosOnPedidoProducto;
    return nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => nombre.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  HistorialPedidosPedidosDetallePedidosOnPedidoProducto({
    required this.nombre,
  });
}

@immutable
class HistorialPedidosData {
  final List<HistorialPedidosPedidos> pedidos;
  HistorialPedidosData.fromJson(dynamic json):
  
  pedidos = (json['pedidos'] as List<dynamic>)
        .map((e) => HistorialPedidosPedidos.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final HistorialPedidosData otherTyped = other as HistorialPedidosData;
    return pedidos == otherTyped.pedidos;
    
  }
  @override
  int get hashCode => pedidos.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pedidos'] = pedidos.map((e) => e.toJson()).toList();
    return json;
  }

  HistorialPedidosData({
    required this.pedidos,
  });
}

@immutable
class HistorialPedidosVariables {
  final Timestamp desde;
  final Timestamp hasta;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  HistorialPedidosVariables.fromJson(Map<String, dynamic> json):
  
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

    final HistorialPedidosVariables otherTyped = other as HistorialPedidosVariables;
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

  HistorialPedidosVariables({
    required this.desde,
    required this.hasta,
  });
}

