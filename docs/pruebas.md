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
- Registro en dos pasos (datos personales y después credenciales): nombre y
  apellidos con letras, teléfono de 10 dígitos opcional, correo válido, contraseña
  de 6 o más caracteres y confirmación igual. El servidor vuelve a validar nombre y
  teléfono en `CrearPerfil` y toda cuenta nueva queda con rol alumno.
- Mensajes de error de Firebase traducidos sin detalles internos.
- Cancelar pedido: el alumno cancela el suyo por pagar, en revisión o pagado en espera
  (con aviso de reembolso); en preparación ya no, y nadie cancela pedidos ajenos.
- Bandeja de avisos: cada usuario ve y marca como leídos solo sus avisos.
- Mi cuenta: cambiar la contraseña y eliminar la cuenta piden la contraseña actual
  (reautenticación). Al eliminarla se borran nombre, teléfono, avisos, dispositivos y
  el acceso; los pedidos quedan anónimos para los reportes. El servidor rechaza la
  baja con pedidos en curso o si la cuenta es del personal.

**Autorización por objeto**
- Un alumno no puede leer ni crear pedidos de otro, ni subir comprobantes de pedidos ajenos.
- Un alumno no puede crear, editar, eliminar ni cambiar la disponibilidad de productos,
  administrar estaciones, validar pagos, avanzar o entregar pedidos, ni ver el reporte.
- Un encargado no puede tocar productos, estaciones o pedidos de otra cafetería.
- Las operaciones de consola (`NO_ACCESS`) se rechazan a cualquier cliente.
- Solo el administrador lista cafeterías y personal, crea o desactiva cafeterías y
  asigna roles; no puede cambiar su propio rol. Encargado y empleado exigen una
  cafetería activa y no se aceptan roles inventados.
- El encargado da de alta y quita empleados solo en su cafetería y solo a cuentas de
  alumno; no puede nombrar encargados ni quitarse a sí mismo.
- El empleado ve y avanza los pedidos de su cafetería, pero no ve pagos ni personal y
  no puede crear estaciones ni cambiar los ajustes.

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
| `flutter test` (2026-11-12, gestión de personal) | 135 pruebas aprobadas, 0 fallidas |
| `test_dataconnect` (2026-11-12, gestión de personal) | 110 pruebas aprobadas, 0 fallidas |
| `integration_test` en Windows (2026-11-11) | 2 pruebas aprobadas tras corregir App Check en escritorio (ver abajo) |

Limitación conocida: el emulador de Functions aún no ejecuta disparadores de SQL
Connect (`onMutationExecuted`), por eso esos manejadores se prueban llamándolos
con el mismo evento que enviaría el servicio.

Hallazgo de la prueba de integración (2026-11-11): en Windows el SDK de SQL Connect
creaba Firebase App Check, que no existe en escritorio, y la app no podía consultar
la base (`MissingPluginException`). Se corrigió con `lib/core/conector.dart`, que en
Windows y Linux arma la conexión sin App Check.
