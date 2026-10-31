# Basic Usage

```dart
AgiluConnector.instance.CrearPerfil(crearPerfilVariables).execute();
AgiluConnector.instance.CrearPedido(crearPedidoVariables).execute();
AgiluConnector.instance.CrearCafeteria(crearCafeteriaVariables).execute();
AgiluConnector.instance.CrearPuesto(crearPuestoVariables).execute();
AgiluConnector.instance.AsignarRol(asignarRolVariables).execute();
AgiluConnector.instance.CrearProducto(crearProductoVariables).execute();
AgiluConnector.instance.CrearEstacion(crearEstacionVariables).execute();
AgiluConnector.instance.EditarEstacion(editarEstacionVariables).execute();
AgiluConnector.instance.EliminarEstacion(eliminarEstacionVariables).execute();
AgiluConnector.instance.ListarMenu().execute();

```

## Optional Fields

Some operations may have optional fields. In these cases, the Flutter SDK exposes a builder method, and will have to be set separately.

Optional fields can be discovered based on classes that have `Optional` object types.

This is an example of a mutation with an optional field:

```dart
await AgiluConnector.instance.CrearProducto({ ... })
.descripcion(...)
.execute();
```

Note: the above example is a mutation, but the same logic applies to query operations as well. Additionally, `createMovie` is an example, and may not be available to the user.

