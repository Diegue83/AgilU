part of 'agilu.dart';

class EditarMiProductoVariablesBuilder {
  String id;
  String nombre;
  Optional<String> _descripcion = Optional.optional(nativeFromJson, nativeToJson);
  double precio;
  String puestoId;
  bool disponible;
  Optional<bool> _preparacionInmediata = Optional.optional(nativeFromJson, nativeToJson);
  Optional<bool> _controlarStock = Optional.optional(nativeFromJson, nativeToJson);
  Optional<int> _cantidadEnStock = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  EditarMiProductoVariablesBuilder descripcion(String? t) {
   _descripcion.value = t;
   return this;
  }
  EditarMiProductoVariablesBuilder preparacionInmediata(bool? t) {
   _preparacionInmediata.value = t;
   return this;
  }
  EditarMiProductoVariablesBuilder controlarStock(bool? t) {
   _controlarStock.value = t;
   return this;
  }
  EditarMiProductoVariablesBuilder cantidadEnStock(int? t) {
   _cantidadEnStock.value = t;
   return this;
  }

  EditarMiProductoVariablesBuilder(this._dataConnect, {required  this.id,required  this.nombre,required  this.precio,required  this.puestoId,required  this.disponible,});
  Deserializer<EditarMiProductoData> dataDeserializer = (dynamic json)  => EditarMiProductoData.fromJson(jsonDecode(json));
  Serializer<EditarMiProductoVariables> varsSerializer = (EditarMiProductoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditarMiProductoData, EditarMiProductoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditarMiProductoData, EditarMiProductoVariables> ref() {
    EditarMiProductoVariables vars= EditarMiProductoVariables(id: id,nombre: nombre,descripcion: _descripcion,precio: precio,puestoId: puestoId,disponible: disponible,preparacionInmediata: _preparacionInmediata,controlarStock: _controlarStock,cantidadEnStock: _cantidadEnStock,);
    return _dataConnect.mutation("EditarMiProducto", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditarMiProductoProductoUpdate {
  final String id;
  EditarMiProductoProductoUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiProductoProductoUpdate otherTyped = other as EditarMiProductoProductoUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EditarMiProductoProductoUpdate({
    required this.id,
  });
}

@immutable
class EditarMiProductoData {
  final EditarMiProductoProductoUpdate? producto_update;
  EditarMiProductoData.fromJson(dynamic json):
  
  producto_update = json['producto_update'] == null ? null : EditarMiProductoProductoUpdate.fromJson(json['producto_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiProductoData otherTyped = other as EditarMiProductoData;
    return producto_update == otherTyped.producto_update;
    
  }
  @override
  int get hashCode => producto_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (producto_update != null) {
      json['producto_update'] = producto_update!.toJson();
    }
    return json;
  }

  EditarMiProductoData({
    this.producto_update,
  });
}

@immutable
class EditarMiProductoVariables {
  final String id;
  final String nombre;
  late final Optional<String>descripcion;
  final double precio;
  final String puestoId;
  final bool disponible;
  late final Optional<bool>preparacionInmediata;
  late final Optional<bool>controlarStock;
  late final Optional<int>cantidadEnStock;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditarMiProductoVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  precio = nativeFromJson<double>(json['precio']),
  puestoId = nativeFromJson<String>(json['puestoId']),
  disponible = nativeFromJson<bool>(json['disponible']) {
  
  
  
  
    descripcion = Optional.optional(nativeFromJson, nativeToJson);
    descripcion.value = json['descripcion'] == null ? null : nativeFromJson<String>(json['descripcion']);
  
  
  
  
  
    preparacionInmediata = Optional.optional(nativeFromJson, nativeToJson);
    preparacionInmediata.value = json['preparacionInmediata'] == null ? null : nativeFromJson<bool>(json['preparacionInmediata']);
  
  
    controlarStock = Optional.optional(nativeFromJson, nativeToJson);
    controlarStock.value = json['controlarStock'] == null ? null : nativeFromJson<bool>(json['controlarStock']);
  
  
    cantidadEnStock = Optional.optional(nativeFromJson, nativeToJson);
    cantidadEnStock.value = json['cantidadEnStock'] == null ? null : nativeFromJson<int>(json['cantidadEnStock']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiProductoVariables otherTyped = other as EditarMiProductoVariables;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    descripcion == otherTyped.descripcion && 
    precio == otherTyped.precio && 
    puestoId == otherTyped.puestoId && 
    disponible == otherTyped.disponible && 
    preparacionInmediata == otherTyped.preparacionInmediata && 
    controlarStock == otherTyped.controlarStock && 
    cantidadEnStock == otherTyped.cantidadEnStock;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, descripcion.hashCode, precio.hashCode, puestoId.hashCode, disponible.hashCode, preparacionInmediata.hashCode, controlarStock.hashCode, cantidadEnStock.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
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
    if(controlarStock.state == OptionalState.set) {
      json['controlarStock'] = controlarStock.toJson();
    }
    if(cantidadEnStock.state == OptionalState.set) {
      json['cantidadEnStock'] = cantidadEnStock.toJson();
    }
    return json;
  }

  EditarMiProductoVariables({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.puestoId,
    required this.disponible,
    required this.preparacionInmediata,
    required this.controlarStock,
    required this.cantidadEnStock,
  });
}

