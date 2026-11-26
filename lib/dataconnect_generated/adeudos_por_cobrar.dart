part of 'agilu.dart';

class AdeudosPorCobrarVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  AdeudosPorCobrarVariablesBuilder(this._dataConnect, );
  Deserializer<AdeudosPorCobrarData> dataDeserializer = (dynamic json)  => AdeudosPorCobrarData.fromJson(jsonDecode(json));
  
  Future<QueryResult<AdeudosPorCobrarData, void>> execute() {
    return ref().execute();
  }

  QueryRef<AdeudosPorCobrarData, void> ref() {
    
    return _dataConnect.query("AdeudosPorCobrar", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class AdeudosPorCobrarPedidos {
  final String id;
  final int folio;
  final double montoTotal;
  final Timestamp recogerA;
  final AdeudosPorCobrarPedidosUsuario usuario;
  AdeudosPorCobrarPedidos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  folio = nativeFromJson<int>(json['folio']),
  montoTotal = nativeFromJson<double>(json['montoTotal']),
  recogerA = Timestamp.fromJson(json['recogerA']),
  usuario = AdeudosPorCobrarPedidosUsuario.fromJson(json['usuario']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AdeudosPorCobrarPedidos otherTyped = other as AdeudosPorCobrarPedidos;
    return id == otherTyped.id && 
    folio == otherTyped.folio && 
    montoTotal == otherTyped.montoTotal && 
    recogerA == otherTyped.recogerA && 
    usuario == otherTyped.usuario;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, folio.hashCode, montoTotal.hashCode, recogerA.hashCode, usuario.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['folio'] = nativeToJson<int>(folio);
    json['montoTotal'] = nativeToJson<double>(montoTotal);
    json['recogerA'] = recogerA.toJson();
    json['usuario'] = usuario.toJson();
    return json;
  }

  AdeudosPorCobrarPedidos({
    required this.id,
    required this.folio,
    required this.montoTotal,
    required this.recogerA,
    required this.usuario,
  });
}

@immutable
class AdeudosPorCobrarPedidosUsuario {
  final String nombre;
  AdeudosPorCobrarPedidosUsuario.fromJson(dynamic json):
  
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AdeudosPorCobrarPedidosUsuario otherTyped = other as AdeudosPorCobrarPedidosUsuario;
    return nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => nombre.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  AdeudosPorCobrarPedidosUsuario({
    required this.nombre,
  });
}

@immutable
class AdeudosPorCobrarData {
  final List<AdeudosPorCobrarPedidos> pedidos;
  AdeudosPorCobrarData.fromJson(dynamic json):
  
  pedidos = (json['pedidos'] as List<dynamic>)
        .map((e) => AdeudosPorCobrarPedidos.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AdeudosPorCobrarData otherTyped = other as AdeudosPorCobrarData;
    return pedidos == otherTyped.pedidos;
    
  }
  @override
  int get hashCode => pedidos.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pedidos'] = pedidos.map((e) => e.toJson()).toList();
    return json;
  }

  AdeudosPorCobrarData({
    required this.pedidos,
  });
}

