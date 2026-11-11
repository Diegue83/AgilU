part of 'agilu.dart';

class CrearMiProductoVariablesBuilder {
  String nombre;
  Optional<String> _descripcion = Optional.optional(nativeFromJson, nativeToJson);
  double precio;
  String puestoId;
  bool disponible;
  Optional<bool> _preparacionInmediata = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CrearMiProductoVariablesBuilder descripcion(String? t) {
   _descripcion.value = t;
   return this;
  }
  CrearMiProductoVariablesBuilder preparacionInmediata(bool? t) {
   _preparacionInmediata.value = t;
   return this;
  }

  CrearMiProductoVariablesBuilder(this._dataConnect, {required  this.nombre,required  this.precio,required  this.puestoId,required  this.disponible,});
  Deserializer<CrearMiProductoData> dataDeserializer = (dynamic json)  => CrearMiProductoData.fromJson(jsonDecode(json));
  Serializer<CrearMiProductoVariables> varsSerializer = (CrearMiProductoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearMiProductoData, CrearMiProductoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearMiProductoData, CrearMiProductoVariables> ref() {
    CrearMiProductoVariables vars= CrearMiProductoVariables(nombre: nombre,descripcion: _descripcion,precio: precio,puestoId: puestoId,disponible: disponible,preparacionInmediata: _preparacionInmediata,);
    return _dataConnect.mutation("CrearMiProducto", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearMiProductoProductoInsert {
  final String id;
  CrearMiProductoProductoInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearMiProductoProductoInsert otherTyped = other as CrearMiProductoProductoInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CrearMiProductoProductoInsert({
    required this.id,
  });
}

@immutable
class CrearMiProductoData {
  final CrearMiProductoProductoInsert producto_insert;
  CrearMiProductoData.fromJson(dynamic json):
  
  producto_insert = CrearMiProductoProductoInsert.fromJson(json['producto_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearMiProductoData otherTyped = other as CrearMiProductoData;
    return producto_insert == otherTyped.producto_insert;
    
  }
  @override
  int get hashCode => producto_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['producto_insert'] = producto_insert.toJson();
    return json;
  }

  CrearMiProductoData({
    required this.producto_insert,
  });
}

@immutable
class CrearMiProductoVariables {
  final String nombre;
  late final Optional<String>descripcion;
  final double precio;
  final String puestoId;
  final bool disponible;
  late final Optional<bool>preparacionInmediata;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearMiProductoVariables.fromJson(Map<String, dynamic> json):
  
  nombre = nativeFromJson<String>(json['nombre']),
  precio = nativeFromJson<double>(json['precio']),
  puestoId = nativeFromJson<String>(json['puestoId']),
  disponible = nativeFromJson<bool>(json['disponible']) {
  
  
  
    descripcion = Optional.optional(nativeFromJson, nativeToJson);
    descripcion.value = json['descripcion'] == null ? null : nativeFromJson<String>(json['descripcion']);
  
  
  
  
  
    preparacionInmediata = Optional.optional(nativeFromJson, nativeToJson);
    preparacionInmediata.value = json['preparacionInmediata'] == null ? null : nativeFromJson<bool>(json['preparacionInmediata']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CrearMiProductoVariables otherTyped = other as CrearMiProductoVariables;
    return nombre == otherTyped.nombre && 
    descripcion == otherTyped.descripcion && 
    precio == otherTyped.precio && 
    puestoId == otherTyped.puestoId && 
    disponible == otherTyped.disponible && 
    preparacionInmediata == otherTyped.preparacionInmediata;
    
  }
  @override
  int get hashCode => Object.hashAll([nombre.hashCode, descripcion.hashCode, precio.hashCode, puestoId.hashCode, disponible.hashCode, preparacionInmediata.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    if(descripcion.state == OptionalState.set) {
      json['descripcion'] = descripcion.toJson();
    }
    json['precio'] = nativeToJson<double>(precio);
    json['puestoId'] = nativeToJson<String>(puestoId);
    json['disponible'] = nativeToJson<bool>(disponible);
    if(preparacionInmediata.state == OptionalState.set) {
      json['preparacionInmediata'] = preparacionInmediata.toJson();
    }
    return json;
  }

  CrearMiProductoVariables({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.puestoId,
    required this.disponible,
    required this.preparacionInmediata,
  });
}

