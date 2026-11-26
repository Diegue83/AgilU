part of 'agilu.dart';

class MisEstacionesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  MisEstacionesVariablesBuilder(this._dataConnect, );
  Deserializer<MisEstacionesData> dataDeserializer = (dynamic json)  => MisEstacionesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<MisEstacionesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<MisEstacionesData, void> ref() {
    
    return _dataConnect.query("MisEstaciones", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class MisEstacionesPuestos {
  final String id;
  final String nombre;
  final int orden;
  final bool activo;
  final String? banco;
  final String? clabe;
  final String? titular;
  final List<MisEstacionesPuestosProductosOnPuesto> productos_on_puesto;
  MisEstacionesPuestos.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  orden = nativeFromJson<int>(json['orden']),
  activo = nativeFromJson<bool>(json['activo']),
  banco = json['banco'] == null ? null : nativeFromJson<String>(json['banco']),
  clabe = json['clabe'] == null ? null : nativeFromJson<String>(json['clabe']),
  titular = json['titular'] == null ? null : nativeFromJson<String>(json['titular']),
  productos_on_puesto = (json['productos_on_puesto'] as List<dynamic>)
        .map((e) => MisEstacionesPuestosProductosOnPuesto.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisEstacionesPuestos otherTyped = other as MisEstacionesPuestos;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    orden == otherTyped.orden && 
    activo == otherTyped.activo && 
    banco == otherTyped.banco && 
    clabe == otherTyped.clabe && 
    titular == otherTyped.titular && 
    productos_on_puesto == otherTyped.productos_on_puesto;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, orden.hashCode, activo.hashCode, banco.hashCode, clabe.hashCode, titular.hashCode, productos_on_puesto.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    json['orden'] = nativeToJson<int>(orden);
    json['activo'] = nativeToJson<bool>(activo);
    if (banco != null) {
      json['banco'] = nativeToJson<String?>(banco);
    }
    if (clabe != null) {
      json['clabe'] = nativeToJson<String?>(clabe);
    }
    if (titular != null) {
      json['titular'] = nativeToJson<String?>(titular);
    }
    json['productos_on_puesto'] = productos_on_puesto.map((e) => e.toJson()).toList();
    return json;
  }

  MisEstacionesPuestos({
    required this.id,
    required this.nombre,
    required this.orden,
    required this.activo,
    this.banco,
    this.clabe,
    this.titular,
    required this.productos_on_puesto,
  });
}

@immutable
class MisEstacionesPuestosProductosOnPuesto {
  final String id;
  MisEstacionesPuestosProductosOnPuesto.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisEstacionesPuestosProductosOnPuesto otherTyped = other as MisEstacionesPuestosProductosOnPuesto;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  MisEstacionesPuestosProductosOnPuesto({
    required this.id,
  });
}

@immutable
class MisEstacionesData {
  final List<MisEstacionesPuestos> puestos;
  MisEstacionesData.fromJson(dynamic json):
  
  puestos = (json['puestos'] as List<dynamic>)
        .map((e) => MisEstacionesPuestos.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MisEstacionesData otherTyped = other as MisEstacionesData;
    return puestos == otherTyped.puestos;
    
  }
  @override
  int get hashCode => puestos.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['puestos'] = puestos.map((e) => e.toJson()).toList();
    return json;
  }

  MisEstacionesData({
    required this.puestos,
  });
}

