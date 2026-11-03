part of 'agilu.dart';

class MisProductosVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  MisProductosVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<MisProductosData> dataDeserializer =
      (dynamic json) => MisProductosData.fromJson(jsonDecode(json));

  Future<QueryResult<MisProductosData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MisProductosData, void> ref() {
    return _dataConnect.query(
        "MisProductos", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MisProductosProductos {
  final String id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String categoria;
  final bool disponible;
  final int cantidadEnStock;
  final String? urlDeImagen;
  final MisProductosProductosPuesto puesto;
  MisProductosProductos.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        nombre = nativeFromJson<String>(json['nombre']),
        descripcion = json['descripcion'] == null
            ? null
            : nativeFromJson<String>(json['descripcion']),
        precio = nativeFromJson<double>(json['precio']),
        categoria = nativeFromJson<String>(json['categoria']),
        disponible = nativeFromJson<bool>(json['disponible']),
        cantidadEnStock = nativeFromJson<int>(json['cantidadEnStock']),
        urlDeImagen = json['urlDeImagen'] == null
            ? null
            : nativeFromJson<String>(json['urlDeImagen']),
        puesto = MisProductosProductosPuesto.fromJson(json['puesto']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MisProductosProductos otherTyped = other as MisProductosProductos;
    return id == otherTyped.id &&
        nombre == otherTyped.nombre &&
        descripcion == otherTyped.descripcion &&
        precio == otherTyped.precio &&
        categoria == otherTyped.categoria &&
        disponible == otherTyped.disponible &&
        cantidadEnStock == otherTyped.cantidadEnStock &&
        urlDeImagen == otherTyped.urlDeImagen &&
        puesto == otherTyped.puesto;
  }

  @override
  int get hashCode => Object.hashAll([
        id.hashCode,
        nombre.hashCode,
        descripcion.hashCode,
        precio.hashCode,
        categoria.hashCode,
        disponible.hashCode,
        cantidadEnStock.hashCode,
        urlDeImagen.hashCode,
        puesto.hashCode
      ]);

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
    json['cantidadEnStock'] = nativeToJson<int>(cantidadEnStock);
    if (urlDeImagen != null) {
      json['urlDeImagen'] = nativeToJson<String?>(urlDeImagen);
    }
    json['puesto'] = puesto.toJson();
    return json;
  }

  MisProductosProductos({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.categoria,
    required this.disponible,
    required this.cantidadEnStock,
    this.urlDeImagen,
    required this.puesto,
  });
}

@immutable
class MisProductosProductosPuesto {
  final String id;
  final String nombre;
  final int orden;
  final MisProductosProductosPuestoCafeteria cafeteria;
  MisProductosProductosPuesto.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        nombre = nativeFromJson<String>(json['nombre']),
        orden = nativeFromJson<int>(json['orden']),
        cafeteria =
            MisProductosProductosPuestoCafeteria.fromJson(json['cafeteria']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MisProductosProductosPuesto otherTyped =
        other as MisProductosProductosPuesto;
    return id == otherTyped.id &&
        nombre == otherTyped.nombre &&
        orden == otherTyped.orden &&
        cafeteria == otherTyped.cafeteria;
  }

  @override
  int get hashCode => Object.hashAll(
      [id.hashCode, nombre.hashCode, orden.hashCode, cafeteria.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    json['orden'] = nativeToJson<int>(orden);
    json['cafeteria'] = cafeteria.toJson();
    return json;
  }

  MisProductosProductosPuesto({
    required this.id,
    required this.nombre,
    required this.orden,
    required this.cafeteria,
  });
}

@immutable
class MisProductosProductosPuestoCafeteria {
  final String id;
  MisProductosProductosPuestoCafeteria.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MisProductosProductosPuestoCafeteria otherTyped =
        other as MisProductosProductosPuestoCafeteria;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  MisProductosProductosPuestoCafeteria({
    required this.id,
  });
}

@immutable
class MisProductosData {
  final List<MisProductosProductos> productos;
  MisProductosData.fromJson(dynamic json)
      : productos = (json['productos'] as List<dynamic>)
            .map((e) => MisProductosProductos.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MisProductosData otherTyped = other as MisProductosData;
    return productos == otherTyped.productos;
  }

  @override
  int get hashCode => productos.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['productos'] = productos.map((e) => e.toJson()).toList();
    return json;
  }

  MisProductosData({
    required this.productos,
  });
}
