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
  MiPedidoPedidos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  folio = nativeFromJson<int>(json['folio']),
  montoTotal = nativeFromJson<double>(json['montoTotal']),
  estado = nativeFromJson<String>(json['estado']),
  recogerA = Timestamp.fromJson(json['recogerA']);
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
    recogerA == otherTyped.recogerA;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, folio.hashCode, montoTotal.hashCode, estado.hashCode, recogerA.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['folio'] = nativeToJson<int>(folio);
    json['montoTotal'] = nativeToJson<double>(montoTotal);
    json['estado'] = nativeToJson<String>(estado);
    json['recogerA'] = recogerA.toJson();
    return json;
  }

  MiPedidoPedidos({
    required this.id,
    required this.folio,
    required this.montoTotal,
    required this.estado,
    required this.recogerA,
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

