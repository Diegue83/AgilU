# Capturas del 2026-11-12: registro, alumno, administrador y encargado

**Dónde:** teléfono Android (Vivo) conectado por USB, con la app de debug apuntando a los
servicios locales de Firebase (Auth y SQL Connect) en la computadora. Ver "Cómo ejecutar"
en el README principal.

**Versión:** rama `feature/historial-encargado` (incluye los PR #36 a #41) más el arreglo
del PR #42 para probar desde un teléfono.

**Datos:** todos son de prueba. Las cuentas, el teléfono 4181234567 y la CLABE en ceros
existen solo en el entorno local. El correo de la cuenta de administrador está tapado en
las capturas 21 a 24.

| # | Flujo | Qué muestra |
| --- | --- | --- |
| 01 | Inicio | Pantalla de inicio de sesión |
| 02 | Registro | Paso 1: datos personales |
| 03 | Registro | Validación: "Escribe tu nombre." |
| 04 | Registro | Paso 1 lleno (nombre, apellidos, teléfono) |
| 05 | Registro | Paso 2: credenciales |
| 06 | Registro | Validación: "Las contraseñas no coinciden." |
| 07 | Registro | Cuenta creada como alumno; entra al menú (aviso de permiso de notificaciones del sistema) |
| 08 | Alumno | Menú de la Cafetería central; producto agotado en gris |
| 09 | Alumno | Mi cuenta: datos del registro, rol Alumno y nivel de confianza |
| 10–11 | Alumno | Productos en el carrito y pantalla del carrito |
| 12 | Alumno | Confirmación del pedido con hora de recogida |
| 13 | Alumno | Ticket AGU-00001 por pagar con instrucciones de transferencia |
| 14–15 | Alumno | Cancelar pedido: confirmación y ticket cancelado |
| 16 | Alumno | Mis pedidos |
| 17 | Alumno | Bandeja de avisos (vacía) |
| 18 | Administrador | Lista de cafeterías |
| 19–20 | Administrador | Alta de la cafetería "Kiosco Gimnasio" |
| 21 | Administrador | Personal antes de asignar |
| 22–23 | Administrador | Asignar rol: roles disponibles y cafetería |
| 24 | Administrador | La cuenta de prueba queda como encargado de Kiosco Gimnasio |
| 25 | Encargado | La misma cuenta ahora entra al panel de pedidos |
| 26 | Encargado | Historial de pedidos terminados |
| 27 | Encargado | Pestaña Personal del encargado |

**Corregido después de estas capturas:** en la 02 el formulario aparecía centrado con un
espacio vacío arriba, y en la 15 el ticket cancelado conservaba el reloj de arena y la
línea "Recoge hoy a las…". Ambos detalles se corrigieron en los PR #37 y #40.

**No se probó aquí:** subir el comprobante de pago y la foto de producto, ni los avisos
push, porque dependen de Cloud Functions.
