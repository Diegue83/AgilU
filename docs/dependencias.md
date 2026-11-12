# Dependencias y vulnerabilidades

## Dónde se declaran

| Parte | Archivo | Instalación |
| --- | --- | --- |
| App Flutter | `pubspec.yaml` (versiones fijadas en `pubspec.lock`) | `flutter pub get` |
| Cloud Functions | `functions/package.json` y `package-lock.json` | `cd functions && npm ci` |
| Pruebas de permisos | `test_dataconnect/package.json` y `package-lock.json` | `cd test_dataconnect && npm ci` |

Dependencias principales de la app: `firebase_core 3.15`, `firebase_auth 5.7`,
`firebase_data_connect 0.1.5`, `cloud_functions 5.6`, `firebase_messaging 15.2`,
`provider`, `image_picker`, `qr_flutter`, `mobile_scanner`, `storage_client 2.8`
(cliente de Supabase Storage, sin el resto de Supabase).
De las funciones: `firebase-admin 14`, `firebase-functions 7`.

## Revisión de alertas

- **Dependabot** (`.github/dependabot.yml`) abre pull requests semanales para pub y
  npm, y mensuales para las acciones de GitHub.
- **CI** (`.github/workflows/ci.yml`, trabajo *dependencias*) corre
  `npm audit --omit=dev --audit-level=high` en `functions/` (falla si hay alertas
  altas o críticas) y `flutter pub outdated` como informe.

## Estado y decisiones

| Fecha | Revisión | Resultado / acción |
| --- | --- | --- |
| 2026-11-10 | `npm audit` y `flutter pub outdated` locales | No se pudieron ejecutar: el equipo no tenía conexión a `registry.npmjs.org` ni a `pub.dev`. Queda a cargo del trabajo *dependencias* de CI y de Dependabot. |
| 2026-11-10 | Versiones de Firebase para Flutter | Se mantienen en `firebase_core 3.x`: subir a 4.x obliga a cambiar todas las librerías de Firebase a la vez. Se hará en una rama propia cuando Dependabot lo proponga y pasen las pruebas. |
| 2026-11-10 | `cloud_firestore` | Se quitó: la app ya no usa Firestore. |

Las alertas que aparezcan en la pestaña *Security* de GitHub se atienden en una
rama `fix/dependencia-<nombre>` o se justifican en esta tabla.
