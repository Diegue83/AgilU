# Pruebas de seguridad y de integración

Todas las pruebas usan datos ficticios (correos `@utng.edu.mx` inventados,
cafetería y CLABE de prueba) y emuladores locales: no tocan el proyecto real.

## Cómo ejecutarlas

| Suite | Comando | Qué necesita |
| --- | --- | --- |
| Unitarias y de interfaz (Flutter) | `flutter test` | Flutter 3.41 y `lib/firebase_options.dart` (real o el ejemplo de `tool/`) |
| Permisos y reglas del servidor | `cd test_dataconnect && npm install && npm test` | Node 22, Java 21 y Firebase CLI 15 |
| Integración en Windows con plugins reales | `firebase emulators:exec --only auth,dataconnect --project demo-agilu "flutter test integration_test -d windows"` | Visual Studio 2022 17.10 o superior |

En GitHub Actions (`.github/workflows/ci.yml`) corren las dos primeras en cada push
y pull request.

## Qué cubren

**Autenticación**
- Sin sesión no se puede leer el menú, las cafeterías ni ningún pedido.
- Validación de correo, contraseña y nombre en el registro; mensajes de error de
  Firebase traducidos sin detalles internos.

**Autorización por objeto**
- Un alumno no puede leer ni crear pedidos de otro, ni subir comprobantes de pedidos ajenos.
- Un alumno no puede crear, editar, eliminar ni cambiar la disponibilidad de productos,
  administrar estaciones, validar pagos, avanzar o entregar pedidos, ni ver el reporte.
- Un encargado no puede tocar productos, estaciones o pedidos de otra cafetería.
- Las operaciones de administrador se rechazan a cualquier cliente.

**Entradas inválidas y reglas de negocio en el servidor**
- El precio enviado por el cliente se ignora; el total sale del catálogo y la oferta vigente.
- Se rechazan: productos agotados, eliminados o de otra cafetería, pedidos vacíos,
  cantidades fuera de rango, horas en el pasado, fuera de horario, sin anticipación,
  desalineadas o en franjas llenas, y alumnos con 3 pedidos sin recoger.
- Nombre vacío, precio ≤ 0, ofertas mayores al precio normal o con fecha pasada.
- Archivos que no son imagen, tipos distintos de JPG/PNG, archivos mayores a 1 MB e ids malformados.
- PIN equivocado suma intentos y bloquea el pedido al quinto; un QR ya usado o ajeno se rechaza.

**Errores**
- Cuando el servidor rechaza un pedido, `DiagnosticarPedido` explica el motivo
  y la app lo muestra sin datos técnicos.

**Integración**
- Manejadores de Cloud Functions probados contra el emulador real de SQL Connect:
  cancelación por producto agotado, fotos, comprobantes, aviso push (con FCM simulado),
  cierre del día.

## Resultados

Ejecución local del 2026-11-10 en la rama `feature/hu-11-reporte-beneficiaria`:

| Suite | Resultado |
| --- | --- |
| `flutter test` | 112 pruebas aprobadas, 0 fallidas |
| `test_dataconnect` (emuladores Auth y SQL Connect) | 102 pruebas aprobadas, 0 fallidas |
| `integration_test` en Windows | **No ejecutada todavía**: el emulador de SQL Connect no arrancó en el intento anterior (puerto ocupado). Pendiente de correr. |

Limitación conocida: el emulador de Functions aún no ejecuta disparadores de SQL
Connect (`onMutationExecuted`), por eso esos manejadores se prueban llamándolos
con el mismo evento que enviaría el servicio.
