part of 'agilu.dart';

class CrearPedidoVariablesBuilder {
  String id;
  String cafeteriaId;
  Timestamp recogerA;
  Optional<String> _notas = Optional.optional(nativeFromJson, nativeToJson);
  AnyValue items;
  Optional<bool> _pagoAlRecoger = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _grupo = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CrearPedidoVariablesBuilder notas(String? t) {
   _notas.value = t;
   return this;
  }
  CrearPedidoVariablesBuilder pagoAlRecoger(bool? t) {
   _pagoAlRecoger.value = t;
   return this;
  }
  CrearPedidoVariablesBuilder grupo(String? t) {
   _grupo.value = t;
   return this;
  }

  CrearPedidoVariablesBuilder(this._dataConnect, {required  this.id,required  this.cafeteriaId,required  this.recogerA,required  this.items,});
  Deserializer<CrearPedidoData> dataDeserializer = (dynamic json)  => CrearPedidoData.fromJson(jsonDecode(json));
  Serializer<CrearPedidoVariables> varsSerializer = (CrearPedidoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearPedidoData, CrearPedidoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearPedidoData, CrearPedidoVariables> ref() {
    CrearPedidoVariables vars= CrearPedidoVariables(id: id,cafeteriaId: cafeteriaId,recogerA: recogerA,notas: _notas,items: items,pagoAlRecoger: _pagoAlRecoger,grupo: _grupo,);
    return _dataConnect.mutation("CrearPedido", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearPedidoData {
  final int? execute_;
  CrearPedidoData.fromJson(dynamic json):
  
  execute_ = json['_execute'] == null ? null : nativeFromJson<int>(json['_execute']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPedidoData otherTyped = other as CrearPedidoData;
    return execute_ == otherTyped.execute_;
    
  }
  @override
  int get hashCode => execute_.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (execute_ != null) {
      json['_execute'] = nativeToJson<int?>(execute_);
    }
    return json;
  }

  CrearPedidoData({
    this.execute_,
  });
}

@immutable
class CrearPedidoVariables {
  final String id;
  final String cafeteriaId;
  final Timestamp recogerA;
  late final Optional<String>notas;
  final AnyValue items;
  late final Optional<bool>pagoAlRecoger;
  late final Optional<String>grupo;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearPedidoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  cafeteriaId = nativeFromJson<String>(json['cafeteriaId']),
  recogerA = Timestamp.fromJson(json['recogerA']),
  items = AnyValue.fromJson(json['items']) {
  
  
  
  
  
    notas = Optional.optional(nativeFromJson, nativeToJson);
    notas.value = json['notas'] == null ? null : nativeFromJson<String>(json['notas']);
  
  
  
    pagoAlRecoger = Optional.optional(nativeFromJson, nativeToJson);
    pagoAlRecoger.value = json['pagoAlRecoger'] == null ? null : nativeFromJson<bool>(json['pagoAlRecoger']);
  
  
    grupo = Optional.optional(nativeFromJson, nativeToJson);
    grupo.value = json['grupo'] == null ? null : nativeFromJson<String>(json['grupo']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearPedidoVariables otherTyped = other as CrearPedidoVariables;
    return id == otherTyped.id && 
    cafeteriaId == otherTyped.cafeteriaId && 
    recogerA == otherTyped.recogerA && 
    notas == otherTyped.notas && 
    items == otherTyped.items && 
    pagoAlRecoger == otherTyped.pagoAlRecoger && 
    grupo == otherTyped.grupo;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, cafeteriaId.hashCode, recogerA.hashCode, notas.hashCode, items.hashCode, pagoAlRecoger.hashCode, grupo.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['cafeteriaId'] = nativeToJson<String>(cafeteriaId);
    json['recogerA'] = recogerA.toJson();
    if(notas.state == OptionalState.set) {
      json['notas'] = notas.toJson();
    }
    json['items'] = items.toJson();
    if(pagoAlRecoger.state == OptionalState.set) {
      json['pagoAlRecoger'] = pagoAlRecoger.toJson();
    }
    if(grupo.state == OptionalState.set) {
      json['grupo'] = grupo.toJson();
    }
    return json;
  }

  CrearPedidoVariables({
    required this.id,
    required this.cafeteriaId,
    required this.recogerA,
    required this.notas,
    required this.items,
    required this.pagoAlRecoger,
    required this.grupo,
  });
}

