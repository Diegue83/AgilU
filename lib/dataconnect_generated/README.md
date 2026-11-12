# agilu_connector SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
AgiluConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### CafeteriasAdmin
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.cafeteriasAdmin().execute();
```



#### Return Type
`execute()` returns a `QueryResult<CafeteriasAdminData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.cafeteriasAdmin();
CafeteriasAdminData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.cafeteriasAdmin().ref();
ref.execute();

ref.subscribe(...);
```


### PersonalAdmin
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.personalAdmin().execute();
```



#### Return Type
`execute()` returns a `QueryResult<PersonalAdminData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.personalAdmin();
PersonalAdminData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.personalAdmin().ref();
ref.execute();

ref.subscribe(...);
```


### MiPersonal
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.miPersonal().execute();
```



#### Return Type
`execute()` returns a `QueryResult<MiPersonalData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.miPersonal();
MiPersonalData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.miPersonal().ref();
ref.execute();

ref.subscribe(...);
```


### ListarMenu
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.listarMenu().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListarMenuData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.listarMenu();
ListarMenuData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.listarMenu().ref();
ref.execute();

ref.subscribe(...);
```


### MiPerfil
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.miPerfil().execute();
```



#### Return Type
`execute()` returns a `QueryResult<MiPerfilData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.miPerfil();
MiPerfilData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.miPerfil().ref();
ref.execute();

ref.subscribe(...);
```


### MiPedido
#### Required Arguments
```dart
String id = ...;
AgiluConnector.instance.miPedido(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<MiPedidoData, MiPedidoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.miPedido(
  id: id,
);
MiPedidoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = AgiluConnector.instance.miPedido(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### MisPedidos
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.misPedidos().execute();
```



#### Return Type
`execute()` returns a `QueryResult<MisPedidosData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.misPedidos();
MisPedidosData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.misPedidos().ref();
ref.execute();

ref.subscribe(...);
```


### MisEstaciones
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.misEstaciones().execute();
```



#### Return Type
`execute()` returns a `QueryResult<MisEstacionesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.misEstaciones();
MisEstacionesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.misEstaciones().ref();
ref.execute();

ref.subscribe(...);
```


### MisProductos
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.misProductos().execute();
```



#### Return Type
`execute()` returns a `QueryResult<MisProductosData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.misProductos();
MisProductosData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.misProductos().ref();
ref.execute();

ref.subscribe(...);
```


### ListarCafeterias
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.listarCafeterias().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListarCafeteriasData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.listarCafeterias();
ListarCafeteriasData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.listarCafeterias().ref();
ref.execute();

ref.subscribe(...);
```


### OcupacionFranjas
#### Required Arguments
```dart
String cafeteriaId = ...;
AgiluConnector.instance.ocupacionFranjas(
  cafeteriaId: cafeteriaId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<OcupacionFranjasData, OcupacionFranjasVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.ocupacionFranjas(
  cafeteriaId: cafeteriaId,
);
OcupacionFranjasData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String cafeteriaId = ...;

final ref = AgiluConnector.instance.ocupacionFranjas(
  cafeteriaId: cafeteriaId,
).ref();
ref.execute();

ref.subscribe(...);
```


### DiagnosticarPedido
#### Required Arguments
```dart
String cafeteriaId = ...;
Timestamp recogerA = ...;
AnyValue items = ...;
AgiluConnector.instance.diagnosticarPedido(
  cafeteriaId: cafeteriaId,
  recogerA: recogerA,
  items: items,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<DiagnosticarPedidoData, DiagnosticarPedidoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.diagnosticarPedido(
  cafeteriaId: cafeteriaId,
  recogerA: recogerA,
  items: items,
);
DiagnosticarPedidoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String cafeteriaId = ...;
Timestamp recogerA = ...;
AnyValue items = ...;

final ref = AgiluConnector.instance.diagnosticarPedido(
  cafeteriaId: cafeteriaId,
  recogerA: recogerA,
  items: items,
).ref();
ref.execute();

ref.subscribe(...);
```


### MiCafeteria
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.miCafeteria().execute();
```



#### Return Type
`execute()` returns a `QueryResult<MiCafeteriaData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.miCafeteria();
MiCafeteriaData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.miCafeteria().ref();
ref.execute();

ref.subscribe(...);
```


### PanelPedidos
#### Required Arguments
```dart
Timestamp desde = ...;
Timestamp hasta = ...;
AgiluConnector.instance.panelPedidos(
  desde: desde,
  hasta: hasta,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<PanelPedidosData, PanelPedidosVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.panelPedidos(
  desde: desde,
  hasta: hasta,
);
PanelPedidosData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
Timestamp desde = ...;
Timestamp hasta = ...;

final ref = AgiluConnector.instance.panelPedidos(
  desde: desde,
  hasta: hasta,
).ref();
ref.execute();

ref.subscribe(...);
```


### PagosPorValidar
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.pagosPorValidar().execute();
```



#### Return Type
`execute()` returns a `QueryResult<PagosPorValidarData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.pagosPorValidar();
PagosPorValidarData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.pagosPorValidar().ref();
ref.execute();

ref.subscribe(...);
```


### MiConfianza
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.miConfianza().execute();
```



#### Return Type
`execute()` returns a `QueryResult<MiConfianzaData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.miConfianza();
MiConfianzaData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.miConfianza().ref();
ref.execute();

ref.subscribe(...);
```


### MisNotificaciones
#### Required Arguments
```dart
// No required arguments
AgiluConnector.instance.misNotificaciones().execute();
```



#### Return Type
`execute()` returns a `QueryResult<MisNotificacionesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.misNotificaciones();
MisNotificacionesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = AgiluConnector.instance.misNotificaciones().ref();
ref.execute();

ref.subscribe(...);
```


### ReporteBeneficiaria
#### Required Arguments
```dart
Timestamp desde = ...;
Timestamp hasta = ...;
AgiluConnector.instance.reporteBeneficiaria(
  desde: desde,
  hasta: hasta,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ReporteBeneficiariaData, ReporteBeneficiariaVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await AgiluConnector.instance.reporteBeneficiaria(
  desde: desde,
  hasta: hasta,
);
ReporteBeneficiariaData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
Timestamp desde = ...;
Timestamp hasta = ...;

final ref = AgiluConnector.instance.reporteBeneficiaria(
  desde: desde,
  hasta: hasta,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### CrearPerfil
#### Required Arguments
```dart
String nombre = ...;
AgiluConnector.instance.crearPerfil(
  nombre: nombre,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CrearPerfilData, CrearPerfilVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.crearPerfil(
  nombre: nombre,
);
CrearPerfilData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String nombre = ...;

final ref = AgiluConnector.instance.crearPerfil(
  nombre: nombre,
).ref();
ref.execute();
```


### CrearPedido
#### Required Arguments
```dart
String id = ...;
String cafeteriaId = ...;
Timestamp recogerA = ...;
AnyValue items = ...;
AgiluConnector.instance.crearPedido(
  id: id,
  cafeteriaId: cafeteriaId,
  recogerA: recogerA,
  items: items,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CrearPedido, we created `CrearPedidoBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CrearPedidoVariablesBuilder {
  ...
   CrearPedidoVariablesBuilder notas(String? t) {
   _notas.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.crearPedido(
  id: id,
  cafeteriaId: cafeteriaId,
  recogerA: recogerA,
  items: items,
)
.notas(notas)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CrearPedidoData, CrearPedidoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.crearPedido(
  id: id,
  cafeteriaId: cafeteriaId,
  recogerA: recogerA,
  items: items,
);
CrearPedidoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String cafeteriaId = ...;
Timestamp recogerA = ...;
AnyValue items = ...;

final ref = AgiluConnector.instance.crearPedido(
  id: id,
  cafeteriaId: cafeteriaId,
  recogerA: recogerA,
  items: items,
).ref();
ref.execute();
```


### CrearCafeteria
#### Required Arguments
```dart
String nombre = ...;
AgiluConnector.instance.crearCafeteria(
  nombre: nombre,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CrearCafeteria, we created `CrearCafeteriaBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CrearCafeteriaVariablesBuilder {
  ...
   CrearCafeteriaVariablesBuilder ubicacion(String? t) {
   _ubicacion.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.crearCafeteria(
  nombre: nombre,
)
.ubicacion(ubicacion)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CrearCafeteriaData, CrearCafeteriaVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.crearCafeteria(
  nombre: nombre,
);
CrearCafeteriaData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String nombre = ...;

final ref = AgiluConnector.instance.crearCafeteria(
  nombre: nombre,
).ref();
ref.execute();
```


### CrearPuesto
#### Required Arguments
```dart
String nombre = ...;
String cafeteriaId = ...;
AgiluConnector.instance.crearPuesto(
  nombre: nombre,
  cafeteriaId: cafeteriaId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CrearPuestoData, CrearPuestoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.crearPuesto(
  nombre: nombre,
  cafeteriaId: cafeteriaId,
);
CrearPuestoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String nombre = ...;
String cafeteriaId = ...;

final ref = AgiluConnector.instance.crearPuesto(
  nombre: nombre,
  cafeteriaId: cafeteriaId,
).ref();
ref.execute();
```


### AsignarRol
#### Required Arguments
```dart
String correo = ...;
String rol = ...;
AgiluConnector.instance.asignarRol(
  correo: correo,
  rol: rol,
).execute();
```

#### Optional Arguments
We return a builder for each query. For AsignarRol, we created `AsignarRolBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class AsignarRolVariablesBuilder {
  ...
   AsignarRolVariablesBuilder cafeteriaId(String? t) {
   _cafeteriaId.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.asignarRol(
  correo: correo,
  rol: rol,
)
.cafeteriaId(cafeteriaId)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<AsignarRolData, AsignarRolVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.asignarRol(
  correo: correo,
  rol: rol,
);
AsignarRolData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String correo = ...;
String rol = ...;

final ref = AgiluConnector.instance.asignarRol(
  correo: correo,
  rol: rol,
).ref();
ref.execute();
```


### CrearProducto
#### Required Arguments
```dart
String nombre = ...;
double precio = ...;
int cantidadEnStock = ...;
String categoria = ...;
String puestoId = ...;
AgiluConnector.instance.crearProducto(
  nombre: nombre,
  precio: precio,
  cantidadEnStock: cantidadEnStock,
  categoria: categoria,
  puestoId: puestoId,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CrearProducto, we created `CrearProductoBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CrearProductoVariablesBuilder {
  ...
   CrearProductoVariablesBuilder descripcion(String? t) {
   _descripcion.value = t;
   return this;
  }
  CrearProductoVariablesBuilder urlDeImagen(String? t) {
   _urlDeImagen.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.crearProducto(
  nombre: nombre,
  precio: precio,
  cantidadEnStock: cantidadEnStock,
  categoria: categoria,
  puestoId: puestoId,
)
.descripcion(descripcion)
.urlDeImagen(urlDeImagen)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CrearProductoData, CrearProductoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.crearProducto(
  nombre: nombre,
  precio: precio,
  cantidadEnStock: cantidadEnStock,
  categoria: categoria,
  puestoId: puestoId,
);
CrearProductoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String nombre = ...;
double precio = ...;
int cantidadEnStock = ...;
String categoria = ...;
String puestoId = ...;

final ref = AgiluConnector.instance.crearProducto(
  nombre: nombre,
  precio: precio,
  cantidadEnStock: cantidadEnStock,
  categoria: categoria,
  puestoId: puestoId,
).ref();
ref.execute();
```


### CrearEstacion
#### Required Arguments
```dart
String nombre = ...;
int orden = ...;
AgiluConnector.instance.crearEstacion(
  nombre: nombre,
  orden: orden,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CrearEstacionData, CrearEstacionVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.crearEstacion(
  nombre: nombre,
  orden: orden,
);
CrearEstacionData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String nombre = ...;
int orden = ...;

final ref = AgiluConnector.instance.crearEstacion(
  nombre: nombre,
  orden: orden,
).ref();
ref.execute();
```


### EditarEstacion
#### Required Arguments
```dart
String id = ...;
String nombre = ...;
int orden = ...;
bool activo = ...;
AgiluConnector.instance.editarEstacion(
  id: id,
  nombre: nombre,
  orden: orden,
  activo: activo,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<EditarEstacionData, EditarEstacionVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.editarEstacion(
  id: id,
  nombre: nombre,
  orden: orden,
  activo: activo,
);
EditarEstacionData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String nombre = ...;
int orden = ...;
bool activo = ...;

final ref = AgiluConnector.instance.editarEstacion(
  id: id,
  nombre: nombre,
  orden: orden,
  activo: activo,
).ref();
ref.execute();
```


### EliminarEstacion
#### Required Arguments
```dart
String id = ...;
AgiluConnector.instance.eliminarEstacion(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<EliminarEstacionData, EliminarEstacionVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.eliminarEstacion(
  id: id,
);
EliminarEstacionData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = AgiluConnector.instance.eliminarEstacion(
  id: id,
).ref();
ref.execute();
```


### CrearMiProducto
#### Required Arguments
```dart
String nombre = ...;
double precio = ...;
String puestoId = ...;
bool disponible = ...;
AgiluConnector.instance.crearMiProducto(
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CrearMiProducto, we created `CrearMiProductoBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CrearMiProductoVariablesBuilder {
  ...
   CrearMiProductoVariablesBuilder descripcion(String? t) {
   _descripcion.value = t;
   return this;
  }
  CrearMiProductoVariablesBuilder preparacionInmediata(bool? t) {
   _preparacionInmediata.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.crearMiProducto(
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
)
.descripcion(descripcion)
.preparacionInmediata(preparacionInmediata)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CrearMiProductoData, CrearMiProductoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.crearMiProducto(
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
);
CrearMiProductoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String nombre = ...;
double precio = ...;
String puestoId = ...;
bool disponible = ...;

final ref = AgiluConnector.instance.crearMiProducto(
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
).ref();
ref.execute();
```


### EditarMiProducto
#### Required Arguments
```dart
String id = ...;
String nombre = ...;
double precio = ...;
String puestoId = ...;
bool disponible = ...;
AgiluConnector.instance.editarMiProducto(
  id: id,
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
).execute();
```

#### Optional Arguments
We return a builder for each query. For EditarMiProducto, we created `EditarMiProductoBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class EditarMiProductoVariablesBuilder {
  ...
   EditarMiProductoVariablesBuilder descripcion(String? t) {
   _descripcion.value = t;
   return this;
  }
  EditarMiProductoVariablesBuilder preparacionInmediata(bool? t) {
   _preparacionInmediata.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.editarMiProducto(
  id: id,
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
)
.descripcion(descripcion)
.preparacionInmediata(preparacionInmediata)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<EditarMiProductoData, EditarMiProductoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.editarMiProducto(
  id: id,
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
);
EditarMiProductoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String nombre = ...;
double precio = ...;
String puestoId = ...;
bool disponible = ...;

final ref = AgiluConnector.instance.editarMiProducto(
  id: id,
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
).ref();
ref.execute();
```


### EstablecerDisponibilidad
#### Required Arguments
```dart
String id = ...;
bool disponible = ...;
AgiluConnector.instance.establecerDisponibilidad(
  id: id,
  disponible: disponible,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<EstablecerDisponibilidadData, EstablecerDisponibilidadVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.establecerDisponibilidad(
  id: id,
  disponible: disponible,
);
EstablecerDisponibilidadData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
bool disponible = ...;

final ref = AgiluConnector.instance.establecerDisponibilidad(
  id: id,
  disponible: disponible,
).ref();
ref.execute();
```


### EliminarMiProducto
#### Required Arguments
```dart
String id = ...;
AgiluConnector.instance.eliminarMiProducto(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<EliminarMiProductoData, EliminarMiProductoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.eliminarMiProducto(
  id: id,
);
EliminarMiProductoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = AgiluConnector.instance.eliminarMiProducto(
  id: id,
).ref();
ref.execute();
```


### PublicarOferta
#### Required Arguments
```dart
String id = ...;
double precioOferta = ...;
Timestamp hasta = ...;
bool esEspecialidad = ...;
AgiluConnector.instance.publicarOferta(
  id: id,
  precioOferta: precioOferta,
  hasta: hasta,
  esEspecialidad: esEspecialidad,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<PublicarOfertaData, PublicarOfertaVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.publicarOferta(
  id: id,
  precioOferta: precioOferta,
  hasta: hasta,
  esEspecialidad: esEspecialidad,
);
PublicarOfertaData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
double precioOferta = ...;
Timestamp hasta = ...;
bool esEspecialidad = ...;

final ref = AgiluConnector.instance.publicarOferta(
  id: id,
  precioOferta: precioOferta,
  hasta: hasta,
  esEspecialidad: esEspecialidad,
).ref();
ref.execute();
```


### QuitarOferta
#### Required Arguments
```dart
String id = ...;
AgiluConnector.instance.quitarOferta(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<QuitarOfertaData, QuitarOfertaVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.quitarOferta(
  id: id,
);
QuitarOfertaData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = AgiluConnector.instance.quitarOferta(
  id: id,
).ref();
ref.execute();
```


### EditarMiCafeteria
#### Required Arguments
```dart
int aperturaMinutos = ...;
int cierreMinutos = ...;
int anticipacionMinutos = ...;
int intervaloMinutos = ...;
int capacidadPorFranja = ...;
bool permitirInmediatos = ...;
AgiluConnector.instance.editarMiCafeteria(
  aperturaMinutos: aperturaMinutos,
  cierreMinutos: cierreMinutos,
  anticipacionMinutos: anticipacionMinutos,
  intervaloMinutos: intervaloMinutos,
  capacidadPorFranja: capacidadPorFranja,
  permitirInmediatos: permitirInmediatos,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<EditarMiCafeteriaData, EditarMiCafeteriaVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.editarMiCafeteria(
  aperturaMinutos: aperturaMinutos,
  cierreMinutos: cierreMinutos,
  anticipacionMinutos: anticipacionMinutos,
  intervaloMinutos: intervaloMinutos,
  capacidadPorFranja: capacidadPorFranja,
  permitirInmediatos: permitirInmediatos,
);
EditarMiCafeteriaData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
int aperturaMinutos = ...;
int cierreMinutos = ...;
int anticipacionMinutos = ...;
int intervaloMinutos = ...;
int capacidadPorFranja = ...;
bool permitirInmediatos = ...;

final ref = AgiluConnector.instance.editarMiCafeteria(
  aperturaMinutos: aperturaMinutos,
  cierreMinutos: cierreMinutos,
  anticipacionMinutos: anticipacionMinutos,
  intervaloMinutos: intervaloMinutos,
  capacidadPorFranja: capacidadPorFranja,
  permitirInmediatos: permitirInmediatos,
).ref();
ref.execute();
```


### AvanzarPedido
#### Required Arguments
```dart
String id = ...;
String estado = ...;
AgiluConnector.instance.avanzarPedido(
  id: id,
  estado: estado,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<AvanzarPedidoData, AvanzarPedidoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.avanzarPedido(
  id: id,
  estado: estado,
);
AvanzarPedidoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String estado = ...;

final ref = AgiluConnector.instance.avanzarPedido(
  id: id,
  estado: estado,
).ref();
ref.execute();
```


### ValidarPago
#### Required Arguments
```dart
String id = ...;
bool aprobado = ...;
AgiluConnector.instance.validarPago(
  id: id,
  aprobado: aprobado,
).execute();
```

#### Optional Arguments
We return a builder for each query. For ValidarPago, we created `ValidarPagoBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class ValidarPagoVariablesBuilder {
  ...
   ValidarPagoVariablesBuilder motivo(String? t) {
   _motivo.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.validarPago(
  id: id,
  aprobado: aprobado,
)
.motivo(motivo)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<ValidarPagoData, ValidarPagoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.validarPago(
  id: id,
  aprobado: aprobado,
);
ValidarPagoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
bool aprobado = ...;

final ref = AgiluConnector.instance.validarPago(
  id: id,
  aprobado: aprobado,
).ref();
ref.execute();
```


### EntregarPedido
#### Required Arguments
```dart
String id = ...;
String codigo = ...;
AgiluConnector.instance.entregarPedido(
  id: id,
  codigo: codigo,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<EntregarPedidoData, EntregarPedidoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.entregarPedido(
  id: id,
  codigo: codigo,
);
EntregarPedidoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String codigo = ...;

final ref = AgiluConnector.instance.entregarPedido(
  id: id,
  codigo: codigo,
).ref();
ref.execute();
```


### MarcarNoRecogido
#### Required Arguments
```dart
String id = ...;
AgiluConnector.instance.marcarNoRecogido(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<MarcarNoRecogidoData, MarcarNoRecogidoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.marcarNoRecogido(
  id: id,
);
MarcarNoRecogidoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = AgiluConnector.instance.marcarNoRecogido(
  id: id,
).ref();
ref.execute();
```


### RegistrarDispositivo
#### Required Arguments
```dart
String token = ...;
String plataforma = ...;
AgiluConnector.instance.registrarDispositivo(
  token: token,
  plataforma: plataforma,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<RegistrarDispositivoData, RegistrarDispositivoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.registrarDispositivo(
  token: token,
  plataforma: plataforma,
);
RegistrarDispositivoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String token = ...;
String plataforma = ...;

final ref = AgiluConnector.instance.registrarDispositivo(
  token: token,
  plataforma: plataforma,
).ref();
ref.execute();
```


### OlvidarDispositivo
#### Required Arguments
```dart
String token = ...;
AgiluConnector.instance.olvidarDispositivo(
  token: token,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<OlvidarDispositivoData, OlvidarDispositivoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.olvidarDispositivo(
  token: token,
);
OlvidarDispositivoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String token = ...;

final ref = AgiluConnector.instance.olvidarDispositivo(
  token: token,
).ref();
ref.execute();
```


### CrearCafeteriaAdmin
#### Required Arguments
```dart
String nombre = ...;
AgiluConnector.instance.crearCafeteriaAdmin(
  nombre: nombre,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CrearCafeteriaAdmin, we created `CrearCafeteriaAdminBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CrearCafeteriaAdminVariablesBuilder {
  ...
   CrearCafeteriaAdminVariablesBuilder ubicacion(String? t) {
   _ubicacion.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.crearCafeteriaAdmin(
  nombre: nombre,
)
.ubicacion(ubicacion)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CrearCafeteriaAdminData, CrearCafeteriaAdminVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.crearCafeteriaAdmin(
  nombre: nombre,
);
CrearCafeteriaAdminData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String nombre = ...;

final ref = AgiluConnector.instance.crearCafeteriaAdmin(
  nombre: nombre,
).ref();
ref.execute();
```


### EditarCafeteriaAdmin
#### Required Arguments
```dart
String id = ...;
String nombre = ...;
bool activa = ...;
AgiluConnector.instance.editarCafeteriaAdmin(
  id: id,
  nombre: nombre,
  activa: activa,
).execute();
```

#### Optional Arguments
We return a builder for each query. For EditarCafeteriaAdmin, we created `EditarCafeteriaAdminBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class EditarCafeteriaAdminVariablesBuilder {
  ...
   EditarCafeteriaAdminVariablesBuilder ubicacion(String? t) {
   _ubicacion.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.editarCafeteriaAdmin(
  id: id,
  nombre: nombre,
  activa: activa,
)
.ubicacion(ubicacion)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<EditarCafeteriaAdminData, EditarCafeteriaAdminVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.editarCafeteriaAdmin(
  id: id,
  nombre: nombre,
  activa: activa,
);
EditarCafeteriaAdminData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String nombre = ...;
bool activa = ...;

final ref = AgiluConnector.instance.editarCafeteriaAdmin(
  id: id,
  nombre: nombre,
  activa: activa,
).ref();
ref.execute();
```


### AsignarRolAdmin
#### Required Arguments
```dart
String correo = ...;
String rol = ...;
AgiluConnector.instance.asignarRolAdmin(
  correo: correo,
  rol: rol,
).execute();
```

#### Optional Arguments
We return a builder for each query. For AsignarRolAdmin, we created `AsignarRolAdminBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class AsignarRolAdminVariablesBuilder {
  ...
   AsignarRolAdminVariablesBuilder cafeteriaId(String? t) {
   _cafeteriaId.value = t;
   return this;
  }

  ...
}
AgiluConnector.instance.asignarRolAdmin(
  correo: correo,
  rol: rol,
)
.cafeteriaId(cafeteriaId)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<AsignarRolAdminData, AsignarRolAdminVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.asignarRolAdmin(
  correo: correo,
  rol: rol,
);
AsignarRolAdminData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String correo = ...;
String rol = ...;

final ref = AgiluConnector.instance.asignarRolAdmin(
  correo: correo,
  rol: rol,
).ref();
ref.execute();
```


### AgregarEmpleado
#### Required Arguments
```dart
String correo = ...;
AgiluConnector.instance.agregarEmpleado(
  correo: correo,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<AgregarEmpleadoData, AgregarEmpleadoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.agregarEmpleado(
  correo: correo,
);
AgregarEmpleadoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String correo = ...;

final ref = AgiluConnector.instance.agregarEmpleado(
  correo: correo,
).ref();
ref.execute();
```


### QuitarEmpleado
#### Required Arguments
```dart
String usuarioId = ...;
AgiluConnector.instance.quitarEmpleado(
  usuarioId: usuarioId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<QuitarEmpleadoData, QuitarEmpleadoVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await AgiluConnector.instance.quitarEmpleado(
  usuarioId: usuarioId,
);
QuitarEmpleadoData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String usuarioId = ...;

final ref = AgiluConnector.instance.quitarEmpleado(
  usuarioId: usuarioId,
).ref();
ref.execute();
```

