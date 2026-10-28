part of 'agilu.dart';

class ListarMenuVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListarMenuVariablesBuilder(this._dataConnect, );
  Deserializer<ListarMenuData> dataDeserializer = (dynamic json)  => ListarMenuData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListarMenuData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListarMenuData, void> ref() {
    
    return _dataConnect.query("ListarMenu", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListarMenuProductos {
  final String id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String categoria;
  final bool disponible;
  final ListarMenuProductosPuesto puesto;
  ListarMenuProductos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  descripcion = json['descripcion'] == null ? null : nativeFromJson<String>(json['descripcion']),
  precio = nativeFromJson<double>(json['precio']),
  categoria = nativeFromJson<String>(json['categoria']),
  disponible = nativeFromJson<bool>(json['disponible']),
  puesto = ListarMenuProductosPuesto.fromJson(json['puesto']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListarMenuProductos otherTyped = other as ListarMenuProductos;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    descripcion == otherTyped.descripcion && 
    precio == otherTyped.precio && 
    categoria == otherTyped.categoria && 
    disponible == otherTyped.disponible && 
    puesto == otherTyped.puesto;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, descripcion.hashCode, precio.hashCode, categoria.hashCode, disponible.hashCode, puesto.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    if (descripcion != null) {
      json['descripcion'] = nativeToJson<String?>(descripcion);
    }
    json['precio'] = nativeToJson<double>(precio);
    json['categoria'] = nativeToJson<String>(categoria);
    json['disponible'] = nativeToJson<bool>(disponible);
    json['puesto'] = puesto.toJson();
    return json;
  }

  ListarMenuProductos({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.categoria,
    required this.disponible,
    required this.puesto,
  });
}

@immutable
class ListarMenuProductosPuesto {
  final String id;
  final String nombre;
  ListarMenuProductosPuesto.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListarMenuProductosPuesto otherTyped = other as ListarMenuProductosPuesto;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    return json;
  }

  ListarMenuProductosPuesto({
    required this.id,
    required this.nombre,
  });
}

@immutable
class ListarMenuData {
  final List<ListarMenuProductos> productos;
  ListarMenuData.fromJson(dynamic json):
  
  productos = (json['productos'] as List<dynamic>)
        .map((e) => ListarMenuProductos.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListarMenuData otherTyped = other as ListarMenuData;
    return productos == otherTyped.productos;
    
  }
  @override
  int get hashCode => productos.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['productos'] = productos.map((e) => e.toJson()).toList();
    return json;
  }

  ListarMenuData({
    required this.productos,
  });
}

