part of 'agilu.dart';

class EditarMiCafeteriaVariablesBuilder {
  int aperturaMinutos;
  int cierreMinutos;
  int anticipacionMinutos;
  int intervaloMinutos;
  int capacidadPorFranja;
  bool permitirInmediatos;

  final FirebaseDataConnect _dataConnect;
  EditarMiCafeteriaVariablesBuilder(this._dataConnect, {required  this.aperturaMinutos,required  this.cierreMinutos,required  this.anticipacionMinutos,required  this.intervaloMinutos,required  this.capacidadPorFranja,required  this.permitirInmediatos,});
  Deserializer<EditarMiCafeteriaData> dataDeserializer = (dynamic json)  => EditarMiCafeteriaData.fromJson(jsonDecode(json));
  Serializer<EditarMiCafeteriaVariables> varsSerializer = (EditarMiCafeteriaVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EditarMiCafeteriaData, EditarMiCafeteriaVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EditarMiCafeteriaData, EditarMiCafeteriaVariables> ref() {
    EditarMiCafeteriaVariables vars= EditarMiCafeteriaVariables(aperturaMinutos: aperturaMinutos,cierreMinutos: cierreMinutos,anticipacionMinutos: anticipacionMinutos,intervaloMinutos: intervaloMinutos,capacidadPorFranja: capacidadPorFranja,permitirInmediatos: permitirInmediatos,);
    return _dataConnect.mutation("EditarMiCafeteria", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EditarMiCafeteriaCafeteriaUpdate {
  final String id;
  EditarMiCafeteriaCafeteriaUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiCafeteriaCafeteriaUpdate otherTyped = other as EditarMiCafeteriaCafeteriaUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  EditarMiCafeteriaCafeteriaUpdate({
    required this.id,
  });
}

@immutable
class EditarMiCafeteriaData {
  final EditarMiCafeteriaCafeteriaUpdate? cafeteria_update;
  EditarMiCafeteriaData.fromJson(dynamic json):
  
  cafeteria_update = json['cafeteria_update'] == null ? null : EditarMiCafeteriaCafeteriaUpdate.fromJson(json['cafeteria_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiCafeteriaData otherTyped = other as EditarMiCafeteriaData;
    return cafeteria_update == otherTyped.cafeteria_update;
    
  }
  @override
  int get hashCode => cafeteria_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (cafeteria_update != null) {
      json['cafeteria_update'] = cafeteria_update!.toJson();
    }
    return json;
  }

  EditarMiCafeteriaData({
    this.cafeteria_update,
  });
}

@immutable
class EditarMiCafeteriaVariables {
  final int aperturaMinutos;
  final int cierreMinutos;
  final int anticipacionMinutos;
  final int intervaloMinutos;
  final int capacidadPorFranja;
  final bool permitirInmediatos;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EditarMiCafeteriaVariables.fromJson(Map<String, dynamic> json):
  
  aperturaMinutos = nativeFromJson<int>(json['aperturaMinutos']),
  cierreMinutos = nativeFromJson<int>(json['cierreMinutos']),
  anticipacionMinutos = nativeFromJson<int>(json['anticipacionMinutos']),
  intervaloMinutos = nativeFromJson<int>(json['intervaloMinutos']),
  capacidadPorFranja = nativeFromJson<int>(json['capacidadPorFranja']),
  permitirInmediatos = nativeFromJson<bool>(json['permitirInmediatos']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EditarMiCafeteriaVariables otherTyped = other as EditarMiCafeteriaVariables;
    return aperturaMinutos == otherTyped.aperturaMinutos && 
    cierreMinutos == otherTyped.cierreMinutos && 
    anticipacionMinutos == otherTyped.anticipacionMinutos && 
    intervaloMinutos == otherTyped.intervaloMinutos && 
    capacidadPorFranja == otherTyped.capacidadPorFranja && 
    permitirInmediatos == otherTyped.permitirInmediatos;
    
  }
  @override
  int get hashCode => Object.hashAll([aperturaMinutos.hashCode, cierreMinutos.hashCode, anticipacionMinutos.hashCode, intervaloMinutos.hashCode, capacidadPorFranja.hashCode, permitirInmediatos.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['aperturaMinutos'] = nativeToJson<int>(aperturaMinutos);
    json['cierreMinutos'] = nativeToJson<int>(cierreMinutos);
    json['anticipacionMinutos'] = nativeToJson<int>(anticipacionMinutos);
    json['intervaloMinutos'] = nativeToJson<int>(intervaloMinutos);
    json['capacidadPorFranja'] = nativeToJson<int>(capacidadPorFranja);
    json['permitirInmediatos'] = nativeToJson<bool>(permitirInmediatos);
    return json;
  }

  EditarMiCafeteriaVariables({
    required this.aperturaMinutos,
    required this.cierreMinutos,
    required this.anticipacionMinutos,
    required this.intervaloMinutos,
    required this.capacidadPorFranja,
    required this.permitirInmediatos,
  });
}

