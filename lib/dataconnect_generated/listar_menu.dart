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
  final String? urlDeImagen;
  final double? precioOferta;
  final Timestamp? ofertaHasta;
  final bool esEspecialidad;
  final ListarMenuProductosPuesto puesto;
  ListarMenuProductos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  descripcion = json['descripcion'] == null ? null : nativeFromJson<String>(json['descripcion']),
  precio = nativeFromJson<double>(json['precio']),
  categoria = nativeFromJson<String>(json['categoria']),
  disponible = nativeFromJson<bool>(json['disponible']),
  urlDeImagen = json['urlDeImagen'] == null ? null : nativeFromJson<String>(json['urlDeImagen']),
  precioOferta = json['precioOferta'] == null ? null : nativeFromJson<double>(json['precioOferta']),
  ofertaHasta = json['ofertaHasta'] == null ? null : Timestamp.fromJson(json['ofertaHasta']),
  esEspecialidad = nativeFromJson<bool>(json['esEspecialidad']),
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
    urlDeImagen == otherTyped.urlDeImagen && 
    precioOferta == otherTyped.precioOferta && 
    ofertaHasta == otherTyped.ofertaHasta && 
    esEspecialidad == otherTyped.esEspecialidad && 
    puesto == otherTyped.puesto;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, descripcion.hashCode, precio.hashCode, categoria.hashCode, disponible.hashCode, urlDeImagen.hashCode, precioOferta.hashCode, ofertaHasta.hashCode, esEspecialidad.hashCode, puesto.hashCode]);
  

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
    if (urlDeImagen != null) {
      json['urlDeImagen'] = nativeToJson<String?>(urlDeImagen);
    }
    if (precioOferta != null) {
      json['precioOferta'] = nativeToJson<double?>(precioOferta);
    }
    if (ofertaHasta != null) {
      json['ofertaHasta'] = ofertaHasta!.toJson();
    }
    json['esEspecialidad'] = nativeToJson<bool>(esEspecialidad);
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
    this.urlDeImagen,
    this.precioOferta,
    this.ofertaHasta,
    required this.esEspecialidad,
    required this.puesto,
  });
}

@immutable
class ListarMenuProductosPuesto {
  final String id;
  final String nombre;
  final int orden;
  final ListarMenuProductosPuestoCafeteria cafeteria;
  ListarMenuProductosPuesto.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  orden = nativeFromJson<int>(json['orden']),
  cafeteria = ListarMenuProductosPuestoCafeteria.fromJson(json['cafeteria']);
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
    nombre == otherTyped.nombre && 
    orden == otherTyped.orden && 
    cafeteria == otherTyped.cafeteria;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, orden.hashCode, cafeteria.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    json['orden'] = nativeToJson<int>(orden);
    json['cafeteria'] = cafeteria.toJson();
    return json;
  }

  ListarMenuProductosPuesto({
    required this.id,
    required this.nombre,
    required this.orden,
    required this.cafeteria,
  });
}

@immutable
class ListarMenuProductosPuestoCafeteria {
  final String id;
  final String nombre;
  ListarMenuProductosPuestoCafeteria.fromJson(dynamic json):
  
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

    final ListarMenuProductosPuestoCafeteria otherTyped = other as ListarMenuProductosPuestoCafeteria;
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

  ListarMenuProductosPuestoCafeteria({
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

