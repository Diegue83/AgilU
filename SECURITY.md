# Seguridad de ÁgilU

## Reportar un problema

Si encuentras una vulnerabilidad o una credencial publicada, **no abras un issue
público** ni copies el valor. Avisa en privado al equipo (Juan Diego Juárez Cruz,
responsable de Firebase/backend) y al docente, indicando solo el archivo, la línea
o el commit donde está.

## Secretos y configuración

| Archivo / valor | ¿Es secreto? | Cómo se maneja |
| --- | --- | --- |
| `lib/firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` | No son secretos (identifican el proyecto de Firebase y la API key pública del cliente), pero son configuración local | Están en `.gitignore`. Cada integrante los genera con `flutterfire configure`. Para CI se usa `tool/firebase_options.ejemplo.dart` con valores ficticios. |
| Cuentas de servicio / llaves privadas (`*-adminsdk-*.json`, `*.pem`, `*.jks`) | **Sí** | Nunca se versionan (`.gitignore`). Las Cloud Functions usan las credenciales por defecto del proyecto, no archivos de llave. |
| Datos bancarios de la cafetería (banco, CLABE, titular) | No; son datos de cobro que se muestran al alumno | Viven en la base, no en el código. En `dataconnect/seed_data.gql` son ficticios. |
| URLs de fotos y comprobantes (`firebasestorage…?token=`) | El token de descarga **sí es sensible** para comprobantes | Solo los genera la Cloud Function y solo se guardan en la base. Un comprobante solo lo leen el alumno dueño y el encargado de esa cafetería. |

Revisión del historial: el 2026-11-10 se revisaron todos los commits buscando
llaves de API, llaves privadas, tokens de GitHub/Stripe/Slack y archivos de
configuración de Firebase. No se encontraron credenciales.

## Controles implementados

- **Autenticación**: Firebase Authentication (correo y contraseña). Toda
  operación de SQL Connect exige sesión (`@auth(level: USER)` o una expresión
  más estricta). Las de consola (`AsignarRol`, `CrearCafeteria`…) son
  `NO_ACCESS` (solo Admin SDK); sirven para nombrar al primer administrador.
- **Autorización por objeto**: cada consulta y mutación filtra con `auth.uid`;
  nunca se recibe el id del usuario como variable. Un alumno solo ve su perfil,
  sus pedidos, sus avisos y su ticket; un encargado solo administra su
  cafetería; la beneficiaria solo ve totales.
- **Datos personales**: el usuario ve y corrige su nombre y teléfono en *Mi cuenta*
  (validados también en el servidor) y puede eliminar su cuenta; la baja borra sus
  datos personales y deja sus pedidos anónimos.
- **Roles y personal** (`dataconnect/agilu/personal.gql`): el rol se lee de la
  base en cada operación, nunca de la app. El administrador crea cafeterías y
  asigna roles, pero no puede cambiar el suyo. El encargado solo da de alta
  como empleado a cuentas de alumno de su propia cafetería y solo quita
  empleados. El empleado atiende y entrega pedidos, sin acceso a pagos, menú,
  personal ni ajustes. Encargado y empleado exigen una cafetería activa.
- **Validación en el servidor**: precios, total, folio, horario, anticipación,
  capacidad por franja, disponibilidad y bloqueo por pedidos no recogidos se
  calculan o validan en `CrearPedido` (SQL dentro de la base), no en la app.
  Las fotos y comprobantes se validan por tipo (firma de bytes) y tamaño en las
  Cloud Functions.
- **Mínimo privilegio en recursos**: las reglas de Storage niegan todo acceso
  directo; Firestore ya no se usa y sus reglas niegan todo.
- **Comunicación segura**: HTTPS/TLS 1.3 con Firebase; en Android no se permite
  tráfico en claro y se fijan las raíces de Google Trust Services
  (`android/app/src/main/res/xml/network_security_config.xml`, expira 2027-11-01).
  En debug solo se permite HTTP hacia el emulador local.
- **Errores sin datos sensibles**: la app muestra mensajes en español para el
  usuario (`lib/core/errores.dart` solo deja pasar los mensajes de `@check`);
  las funciones registran el detalle en sus logs y responden un error genérico.
- **Entrega**: el PIN de 4 dígitos solo lo ve el alumno; tras 5 intentos fallidos
  el pedido se bloquea para entrega por código.

## Pendientes conocidos

- Activar App Check para que solo la app oficial llame a SQL Connect y a las funciones.
- Restringir la API key del cliente por paquete/huella en Google Cloud Console.
- Ejecutar `npm audit` y `flutter pub outdated` con red (ver `docs/dependencias.md`).
