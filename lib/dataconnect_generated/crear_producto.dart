part of 'agilu.dart';

class CrearProductoVariablesBuilder {
  String nombre;
  double precio;
  int cantidadEnStock;
  String categoria;
  Optional<String> _descripcion =
      Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _urlDeImagen =
      Optional.optional(nativeFromJson, nativeToJson);
  String puestoId;

  final FirebaseDataConnect _dataConnect;
  CrearProductoVariablesBuilder descripcion(String? t) {
    _descripcion.value = t;
    return this;
  }

  CrearProductoVariablesBuilder urlDeImagen(String? t) {
    _urlDeImagen.value = t;
    return this;
  }

  CrearProductoVariablesBuilder(
    this._dataConnect, {
    required this.nombre,
    required this.precio,
    required this.cantidadEnStock,
    required this.categoria,
    required this.puestoId,
  });
  Deserializer<CrearProductoData> dataDeserializer =
      (dynamic json) => CrearProductoData.fromJson(jsonDecode(json));
  Serializer<CrearProductoVariables> varsSerializer =
      (CrearProductoVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CrearProductoData, CrearProductoVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CrearProductoData, CrearProductoVariables> ref() {
    CrearProductoVariables vars = CrearProductoVariables(
      nombre: nombre,
      precio: precio,
      cantidadEnStock: cantidadEnStock,
      categoria: categoria,
      descripcion: _descripcion,
      urlDeImagen: _urlDeImagen,
      puestoId: puestoId,
    );
    return _dataConnect.mutation(
        "CrearProducto", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CrearProductoProductoInsert {
  final String id;
  CrearProductoProductoInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearProductoProductoInsert otherTyped =
        other as CrearProductoProductoInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CrearProductoProductoInsert({
    required this.id,
  });
}

@immutable
class CrearProductoData {
  final CrearProductoProductoInsert producto_insert;
  CrearProductoData.fromJson(dynamic json)
      : producto_insert =
            CrearProductoProductoInsert.fromJson(json['producto_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearProductoData otherTyped = other as CrearProductoData;
    return producto_insert == otherTyped.producto_insert;
  }

  @override
  int get hashCode => producto_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['producto_insert'] = producto_insert.toJson();
    return json;
  }

  CrearProductoData({
    required this.producto_insert,
  });
}

@immutable
class CrearProductoVariables {
  final String nombre;
  final double precio;
  final int cantidadEnStock;
  final String categoria;
  late final Optional<String> descripcion;
  late final Optional<String> urlDeImagen;
  final String puestoId;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CrearProductoVariables.fromJson(Map<String, dynamic> json)
      : nombre = nativeFromJson<String>(json['nombre']),
        precio = nativeFromJson<double>(json['precio']),
        cantidadEnStock = nativeFromJson<int>(json['cantidadEnStock']),
        categoria = nativeFromJson<String>(json['categoria']),
        puestoId = nativeFromJson<String>(json['puestoId']) {
    descripcion = Optional.optional(nativeFromJson, nativeToJson);
    descripcion.value = json['descripcion'] == null
        ? null
        : nativeFromJson<String>(json['descripcion']);

    urlDeImagen = Optional.optional(nativeFromJson, nativeToJson);
    urlDeImagen.value = json['urlDeImagen'] == null
        ? null
        : nativeFromJson<String>(json['urlDeImagen']);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CrearProductoVariables otherTyped = other as CrearProductoVariables;
    return nombre == otherTyped.nombre &&
        precio == otherTyped.precio &&
        cantidadEnStock == otherTyped.cantidadEnStock &&
        categoria == otherTyped.categoria &&
        descripcion == otherTyped.descripcion &&
        urlDeImagen == otherTyped.urlDeImagen &&
        puestoId == otherTyped.puestoId;
  }

  @override
  int get hashCode => Object.hashAll([
        nombre.hashCode,
        precio.hashCode,
        cantidadEnStock.hashCode,
        categoria.hashCode,
        descripcion.hashCode,
        urlDeImagen.hashCode,
        puestoId.hashCode
      ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['nombre'] = nativeToJson<String>(nombre);
    json['precio'] = nativeToJson<double>(precio);
    json['cantidadEnStock'] = nativeToJson<int>(cantidadEnStock);
    json['categoria'] = nativeToJson<String>(categoria);
    if (descripcion.state == OptionalState.set) {
      json['descripcion'] = descripcion.toJson();
    }
    if (urlDeImagen.state == OptionalState.set) {
      json['urlDeImagen'] = urlDeImagen.toJson();
    }
    json['puestoId'] = nativeToJson<String>(puestoId);
    return json;
  }

  CrearProductoVariables({
    required this.nombre,
    required this.precio,
    required this.cantidadEnStock,
    required this.categoria,
    required this.descripcion,
    required this.urlDeImagen,
    required this.puestoId,
  });
}
