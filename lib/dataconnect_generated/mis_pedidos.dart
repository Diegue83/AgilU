part of 'agilu.dart';

class MisPedidosVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  MisPedidosVariablesBuilder(this._dataConnect, );
  Deserializer<MisPedidosData> dataDeserializer = (dynamic json)  => MisPedidosData.fromJson(jsonDecode(json));
  
  Future<QueryResult<MisPedidosData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MisPedidosData, void> ref() {
    
    return _dataConnect.query("MisPedidos", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MisPedidosPedidos {
  final String id;
  final int folio;
  final double montoTotal;
  final String estado;
  final Timestamp recogerA;
  final String? notas;
  final MisPedidosPedidosPuesto puesto;
  final List<MisPedidosPedidosDetallePedidosOnPedido> detallePedidos_on_pedido;
  MisPedidosPedidos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  folio = nativeFromJson<int>(json['folio']),
  montoTotal = nativeFromJson<double>(json['montoTotal']),
  estado = nativeFromJson<String>(json['estado']),
  recogerA = Timestamp.fromJson(json['recogerA']),
  notas = json['notas'] == null ? null : nativeFromJson<String>(json['notas']),
  puesto = MisPedidosPedidosPuesto.fromJson(json['puesto']),
  detallePedidos_on_pedido = (json['detallePedidos_on_pedido'] as List<dynamic>)
        .map((e) => MisPedidosPedidosDetallePedidosOnPedido.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisPedidosPedidos otherTyped = other as MisPedidosPedidos;
    return id == otherTyped.id && 
    folio == otherTyped.folio && 
    montoTotal == otherTyped.montoTotal && 
    estado == otherTyped.estado && 
    recogerA == otherTyped.recogerA && 
    notas == otherTyped.notas && 
    puesto == otherTyped.puesto && 
    detallePedidos_on_pedido == otherTyped.detallePedidos_on_pedido;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, folio.hashCode, montoTotal.hashCode, estado.hashCode, recogerA.hashCode, notas.hashCode, puesto.hashCode, detallePedidos_on_pedido.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['folio'] = nativeToJson<int>(folio);
    json['montoTotal'] = nativeToJson<double>(montoTotal);
    json['estado'] = nativeToJson<String>(estado);
    json['recogerA'] = recogerA.toJson();
    if (notas != null) {
      json['notas'] = nativeToJson<String?>(notas);
    }
    json['puesto'] = puesto.toJson();
    json['detallePedidos_on_pedido'] = detallePedidos_on_pedido.map((e) => e.toJson()).toList();
    return json;
  }

  MisPedidosPedidos({
    required this.id,
    required this.folio,
    required this.montoTotal,
    required this.estado,
    required this.recogerA,
    this.notas,
    required this.puesto,
    required this.detallePedidos_on_pedido,
  });
}

@immutable
class MisPedidosPedidosPuesto {
  final String nombre;
  MisPedidosPedidosPuesto.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisPedidosPedidosPuesto otherTyped = other as MisPedidosPedidosPuesto;
    return nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => nombre.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  MisPedidosPedidosPuesto({
    required this.nombre,
  });
}

@immutable
class MisPedidosPedidosDetallePedidosOnPedido {
  final int cantidad;
  final double precioEnElMomento;
  final MisPedidosPedidosDetallePedidosOnPedidoProducto producto;
  MisPedidosPedidosDetallePedidosOnPedido.fromJson(dynamic json):
  
  cantidad = nativeFromJson<int>(json['cantidad']),
  precioEnElMomento = nativeFromJson<double>(json['precioEnElMomento']),
  producto = MisPedidosPedidosDetallePedidosOnPedidoProducto.fromJson(json['producto']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisPedidosPedidosDetallePedidosOnPedido otherTyped = other as MisPedidosPedidosDetallePedidosOnPedido;
    return cantidad == otherTyped.cantidad && 
    precioEnElMomento == otherTyped.precioEnElMomento && 
    producto == otherTyped.producto;
    
  }
  @override
  int get hashCode => Object.hashAll([cantidad.hashCode, precioEnElMomento.hashCode, producto.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cantidad'] = nativeToJson<int>(cantidad);
    json['precioEnElMomento'] = nativeToJson<double>(precioEnElMomento);
    json['producto'] = producto.toJson();
    return json;
  }

  MisPedidosPedidosDetallePedidosOnPedido({
    required this.cantidad,
    required this.precioEnElMomento,
    required this.producto,
  });
}

@immutable
class MisPedidosPedidosDetallePedidosOnPedidoProducto {
  final String nombre;
  MisPedidosPedidosDetallePedidosOnPedidoProducto.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisPedidosPedidosDetallePedidosOnPedidoProducto otherTyped = other as MisPedidosPedidosDetallePedidosOnPedidoProducto;
    return nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => nombre.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  MisPedidosPedidosDetallePedidosOnPedidoProducto({
    required this.nombre,
  });
}

@immutable
class MisPedidosData {
  final List<MisPedidosPedidos> pedidos;
  MisPedidosData.fromJson(dynamic json):
  
  pedidos = (json['pedidos'] as List<dynamic>)
        .map((e) => MisPedidosPedidos.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisPedidosData otherTyped = other as MisPedidosData;
    return pedidos == otherTyped.pedidos;
    
  }
  @override
  int get hashCode => pedidos.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pedidos'] = pedidos.map((e) => e.toJson()).toList();
    return json;
  }

  MisPedidosData({
    required this.pedidos,
  });
}

