part of 'agilu.dart';

class MiPedidoVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  MiPedidoVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<MiPedidoData> dataDeserializer = (dynamic json)  => MiPedidoData.fromJson(jsonDecode(json));
  Serializer<MiPedidoVariables> varsSerializer = (MiPedidoVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<MiPedidoData, MiPedidoVariables>> execute() {
    return ref().execute();
  }

  QueryRef<MiPedidoData, MiPedidoVariables> ref() {
    MiPedidoVariables vars= MiPedidoVariables(id: id,);
    return _dataConnect.query("MiPedido", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class MiPedidoPedidos {
  final String id;
  final int folio;
  final double montoTotal;
  final String estado;
  final Timestamp recogerA;
  final String? notas;
  final String? referenciaPago;
  final String? comprobanteUrl;
  final String? motivoRechazoPago;
  final Timestamp? pagadoEn;
  final MiPedidoPedidosCafeteria cafeteria;
  final List<MiPedidoPedidosDetallePedidosOnPedido> detallePedidos_on_pedido;
  MiPedidoPedidos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  folio = nativeFromJson<int>(json['folio']),
  montoTotal = nativeFromJson<double>(json['montoTotal']),
  estado = nativeFromJson<String>(json['estado']),
  recogerA = Timestamp.fromJson(json['recogerA']),
  notas = json['notas'] == null ? null : nativeFromJson<String>(json['notas']),
  referenciaPago = json['referenciaPago'] == null ? null : nativeFromJson<String>(json['referenciaPago']),
  comprobanteUrl = json['comprobanteUrl'] == null ? null : nativeFromJson<String>(json['comprobanteUrl']),
  motivoRechazoPago = json['motivoRechazoPago'] == null ? null : nativeFromJson<String>(json['motivoRechazoPago']),
  pagadoEn = json['pagadoEn'] == null ? null : Timestamp.fromJson(json['pagadoEn']),
  cafeteria = MiPedidoPedidosCafeteria.fromJson(json['cafeteria']),
  detallePedidos_on_pedido = (json['detallePedidos_on_pedido'] as List<dynamic>)
        .map((e) => MiPedidoPedidosDetallePedidosOnPedido.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPedidoPedidos otherTyped = other as MiPedidoPedidos;
    return id == otherTyped.id && 
    folio == otherTyped.folio && 
    montoTotal == otherTyped.montoTotal && 
    estado == otherTyped.estado && 
    recogerA == otherTyped.recogerA && 
    notas == otherTyped.notas && 
    referenciaPago == otherTyped.referenciaPago && 
    comprobanteUrl == otherTyped.comprobanteUrl && 
    motivoRechazoPago == otherTyped.motivoRechazoPago && 
    pagadoEn == otherTyped.pagadoEn && 
    cafeteria == otherTyped.cafeteria && 
    detallePedidos_on_pedido == otherTyped.detallePedidos_on_pedido;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, folio.hashCode, montoTotal.hashCode, estado.hashCode, recogerA.hashCode, notas.hashCode, referenciaPago.hashCode, comprobanteUrl.hashCode, motivoRechazoPago.hashCode, pagadoEn.hashCode, cafeteria.hashCode, detallePedidos_on_pedido.hashCode]);
  

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
    if (referenciaPago != null) {
      json['referenciaPago'] = nativeToJson<String?>(referenciaPago);
    }
    if (comprobanteUrl != null) {
      json['comprobanteUrl'] = nativeToJson<String?>(comprobanteUrl);
    }
    if (motivoRechazoPago != null) {
      json['motivoRechazoPago'] = nativeToJson<String?>(motivoRechazoPago);
    }
    if (pagadoEn != null) {
      json['pagadoEn'] = pagadoEn!.toJson();
    }
    json['cafeteria'] = cafeteria.toJson();
    json['detallePedidos_on_pedido'] = detallePedidos_on_pedido.map((e) => e.toJson()).toList();
    return json;
  }

  MiPedidoPedidos({
    required this.id,
    required this.folio,
    required this.montoTotal,
    required this.estado,
    required this.recogerA,
    this.notas,
    this.referenciaPago,
    this.comprobanteUrl,
    this.motivoRechazoPago,
    this.pagadoEn,
    required this.cafeteria,
    required this.detallePedidos_on_pedido,
  });
}

@immutable
class MiPedidoPedidosCafeteria {
  final String nombre;
  final String? ubicacion;
  final String? banco;
  final String? clabe;
  final String? titular;
  MiPedidoPedidosCafeteria.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']),
  ubicacion = json['ubicacion'] == null ? null : nativeFromJson<String>(json['ubicacion']),
  banco = json['banco'] == null ? null : nativeFromJson<String>(json['banco']),
  clabe = json['clabe'] == null ? null : nativeFromJson<String>(json['clabe']),
  titular = json['titular'] == null ? null : nativeFromJson<String>(json['titular']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPedidoPedidosCafeteria otherTyped = other as MiPedidoPedidosCafeteria;
    return nombre == otherTyped.nombre && 
    ubicacion == otherTyped.ubicacion && 
    banco == otherTyped.banco && 
    clabe == otherTyped.clabe && 
    titular == otherTyped.titular;
    
  }
  @override
  int get hashCode => Object.hashAll([nombre.hashCode, ubicacion.hashCode, banco.hashCode, clabe.hashCode, titular.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    if (ubicacion != null) {
      json['ubicacion'] = nativeToJson<String?>(ubicacion);
    }
    if (banco != null) {
      json['banco'] = nativeToJson<String?>(banco);
    }
    if (clabe != null) {
      json['clabe'] = nativeToJson<String?>(clabe);
    }
    if (titular != null) {
      json['titular'] = nativeToJson<String?>(titular);
    }
    return json;
  }

  MiPedidoPedidosCafeteria({
    required this.nombre,
    this.ubicacion,
    this.banco,
    this.clabe,
    this.titular,
  });
}

@immutable
class MiPedidoPedidosDetallePedidosOnPedido {
  final int cantidad;
  final double precioEnElMomento;
  final MiPedidoPedidosDetallePedidosOnPedidoProducto producto;
  MiPedidoPedidosDetallePedidosOnPedido.fromJson(dynamic json):
  
  cantidad = nativeFromJson<int>(json['cantidad']),
  precioEnElMomento = nativeFromJson<double>(json['precioEnElMomento']),
  producto = MiPedidoPedidosDetallePedidosOnPedidoProducto.fromJson(json['producto']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPedidoPedidosDetallePedidosOnPedido otherTyped = other as MiPedidoPedidosDetallePedidosOnPedido;
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

  MiPedidoPedidosDetallePedidosOnPedido({
    required this.cantidad,
    required this.precioEnElMomento,
    required this.producto,
  });
}

@immutable
class MiPedidoPedidosDetallePedidosOnPedidoProducto {
  final String nombre;
  MiPedidoPedidosDetallePedidosOnPedidoProducto.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPedidoPedidosDetallePedidosOnPedidoProducto otherTyped = other as MiPedidoPedidosDetallePedidosOnPedidoProducto;
    return nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => nombre.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  MiPedidoPedidosDetallePedidosOnPedidoProducto({
    required this.nombre,
  });
}

@immutable
class MiPedidoData {
  final List<MiPedidoPedidos> pedidos;
  MiPedidoData.fromJson(dynamic json):
  
  pedidos = (json['pedidos'] as List<dynamic>)
        .map((e) => MiPedidoPedidos.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPedidoData otherTyped = other as MiPedidoData;
    return pedidos == otherTyped.pedidos;
    
  }
  @override
  int get hashCode => pedidos.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pedidos'] = pedidos.map((e) => e.toJson()).toList();
    return json;
  }

  MiPedidoData({
    required this.pedidos,
  });
}

@immutable
class MiPedidoVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  MiPedidoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MiPedidoVariables otherTyped = other as MiPedidoVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  MiPedidoVariables({
    required this.id,
  });
}

