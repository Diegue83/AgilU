part of 'agilu.dart';

class ListarCafeteriasVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListarCafeteriasVariablesBuilder(this._dataConnect, );
  Deserializer<ListarCafeteriasData> dataDeserializer = (dynamic json)  => ListarCafeteriasData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListarCafeteriasData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListarCafeteriasData, void> ref() {
    
    return _dataConnect.query("ListarCafeterias", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListarCafeteriasCafeterias {
  final String id;
  final String nombre;
  final int aperturaMinutos;
  final int cierreMinutos;
  final int anticipacionMinutos;
  final int intervaloMinutos;
  final int capacidadPorFranja;
  final bool permitirInmediatos;
  final String zonaHoraria;
  final bool activa;
  ListarCafeteriasCafeterias.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  nombre = nativeFromJson<String>(json['nombre']),
  aperturaMinutos = nativeFromJson<int>(json['aperturaMinutos']),
  cierreMinutos = nativeFromJson<int>(json['cierreMinutos']),
  anticipacionMinutos = nativeFromJson<int>(json['anticipacionMinutos']),
  intervaloMinutos = nativeFromJson<int>(json['intervaloMinutos']),
  capacidadPorFranja = nativeFromJson<int>(json['capacidadPorFranja']),
  permitirInmediatos = nativeFromJson<bool>(json['permitirInmediatos']),
  zonaHoraria = nativeFromJson<String>(json['zonaHoraria']),
  activa = nativeFromJson<bool>(json['activa']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListarCafeteriasCafeterias otherTyped = other as ListarCafeteriasCafeterias;
    return id == otherTyped.id && 
    nombre == otherTyped.nombre && 
    aperturaMinutos == otherTyped.aperturaMinutos && 
    cierreMinutos == otherTyped.cierreMinutos && 
    anticipacionMinutos == otherTyped.anticipacionMinutos && 
    intervaloMinutos == otherTyped.intervaloMinutos && 
    capacidadPorFranja == otherTyped.capacidadPorFranja && 
    permitirInmediatos == otherTyped.permitirInmediatos && 
    zonaHoraria == otherTyped.zonaHoraria && 
    activa == otherTyped.activa;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, nombre.hashCode, aperturaMinutos.hashCode, cierreMinutos.hashCode, anticipacionMinutos.hashCode, intervaloMinutos.hashCode, capacidadPorFranja.hashCode, permitirInmediatos.hashCode, zonaHoraria.hashCode, activa.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['nombre'] = nativeToJson<String>(nombre);
    json['aperturaMinutos'] = nativeToJson<int>(aperturaMinutos);
    json['cierreMinutos'] = nativeToJson<int>(cierreMinutos);
    json['anticipacionMinutos'] = nativeToJson<int>(anticipacionMinutos);
    json['intervaloMinutos'] = nativeToJson<int>(intervaloMinutos);
    json['capacidadPorFranja'] = nativeToJson<int>(capacidadPorFranja);
    json['permitirInmediatos'] = nativeToJson<bool>(permitirInmediatos);
    json['zonaHoraria'] = nativeToJson<String>(zonaHoraria);
    json['activa'] = nativeToJson<bool>(activa);
    return json;
  }

  ListarCafeteriasCafeterias({
    required this.id,
    required this.nombre,
    required this.aperturaMinutos,
    required this.cierreMinutos,
    required this.anticipacionMinutos,
    required this.intervaloMinutos,
    required this.capacidadPorFranja,
    required this.permitirInmediatos,
    required this.zonaHoraria,
    required this.activa,
  });
}

@immutable
class ListarCafeteriasData {
  final List<ListarCafeteriasCafeterias> cafeterias;
  ListarCafeteriasData.fromJson(dynamic json):
  
  cafeterias = (json['cafeterias'] as List<dynamic>)
        .map((e) => ListarCafeteriasCafeterias.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListarCafeteriasData otherTyped = other as ListarCafeteriasData;
    return cafeterias == otherTyped.cafeterias;
    
  }
  @override
  int get hashCode => cafeterias.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['cafeterias'] = cafeterias.map((e) => e.toJson()).toList();
    return json;
  }

  ListarCafeteriasData({
    required this.cafeterias,
  });
}

