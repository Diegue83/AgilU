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

  ...
}
AgiluConnector.instance.crearMiProducto(
  nombre: nombre,
  precio: precio,
  puestoId: puestoId,
  disponible: disponible,
)
.descripcion(descripcion)
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

