# ÁgilU

App móvil para pre-ordenar alimentos en cafeterías universitarias: el alumno ve el
menú del día, arma su pedido para una hora de recogida, paga por transferencia y
recoge con un código o QR; el encargado administra el menú, valida pagos y prepara
pedidos en un panel; la beneficiaria consulta el reporte del negocio.

**Stack:** Flutter + Firebase (Auth, SQL Connect, Cloud Functions, Storage, Cloud Messaging)
· **Arquitectura:** MVVM · **Metodología:** Scrum

**Versión a revisar:** rama `main`. Cada historia de usuario se desarrolla en su
propia rama `feature/hu-XX-…` y se une a `main` por pull request.

## Equipo
- Banda López Mildred Mariana — Flutter / UI
- Juarez Cruz Juan Diego — Firebase / Backend
- Vargas Vargas Zayda Fernanda — Diseño de interfaces

Tablero: https://trello.com/b/Hbim6YjX

## Requisitos

| Herramienta | Versión probada |
| --- | --- |
| Flutter / Dart | 3.41.6 / 3.11 |
| Node.js | 22 (funciones) — 24 funciona para las pruebas |
| Java | 21 (emuladores de Firebase) |
| Firebase CLI | 15.x (`npm install -g firebase-tools`) |
| FlutterFire CLI | `dart pub global activate flutterfire_cli` |
| Windows (opcional) | Visual Studio 2022 17.10 o superior con "Desarrollo para el escritorio con C++" |

## Configuración

1. Instalar dependencias:
   ```bash
   flutter pub get
   ```
2. Generar la configuración local de Firebase (no se versiona y no contiene secretos):
   ```bash
   flutterfire configure --project=agilu-a232a
   ```
   Crea `lib/firebase_options.dart` y `android/app/google-services.json`. Para solo
   compilar o correr pruebas sin acceso al proyecto, copia el ejemplo con valores
   ficticios: `cp tool/firebase_options.ejemplo.dart lib/firebase_options.dart`.
3. Variables de compilación (`--dart-define`):

   | Variable | Valores | Efecto |
   | --- | --- | --- |
   | `EMULADORES` | `true` / sin definir | Conecta Auth, SQL Connect y Functions a los emuladores locales |

   No hay llaves ni contraseñas que configurar en la app. Las funciones usan las
   credenciales por defecto del proyecto en Google Cloud.

## Cómo ejecutar

**Contra los emuladores (recomendado para revisar, con datos ficticios):**
```bash
firebase emulators:start --only auth,dataconnect,functions --project demo-agilu
```
En otra terminal:
```bash
node test_dataconnect/sembrar.js
flutter run --dart-define=EMULADORES=true
```
**Roles:** alumno (al registrarse), empleado, encargado, beneficiaria y administrador.
El primer administrador se nombra una sola vez desde la consola de SQL Connect con
la mutación `AsignarRol` (`rol: "admin"`). Después, desde la app, el administrador
crea cafeterías y asigna roles, y cada encargado da de alta a sus empleados con el
correo con el que se registraron (ver `docs/integracion-nube.md`).

**Contra el proyecto real:** `flutter run`. Antes hay que publicar el backend:
```bash
firebase deploy --only dataconnect,functions,storage,firestore:rules
```

**Sin Firebase:** cambia `AppConfig.usarFirebase` a `false` en
`lib/core/app_config.dart`; la app usa datos de ejemplo.

## Estructura

```
lib/
├── core/                 Configuración, rutas, tema, reglas de horario, QR, errores
├── data/
│   ├── models/           Producto, Pedido, Ticket, Cafeteria, Estacion, Perfil, Reporte…
│   └── repositories/     Interfaz + implementación SQL Connect/Functions + Mock por cada área
├── dataconnect_generated/ SDK generado de SQL Connect (no se edita a mano)
├── ui/                   Una carpeta por pantalla: *_view.dart + *_view_model.dart
│   ├── auth/ menu/ cart/ pedido/ reporte/
│   └── encargado/        panel/ pagos/ productos/ estaciones/ cafeteria/
├── app.dart              MaterialApp y rutas
└── main.dart             Inyección de dependencias (Provider)
dataconnect/              Esquema, conector `agilu` (queries.gql, mutations.gql) y datos de prueba
functions/                Cloud Functions: fotos, comprobantes, cancelaciones, avisos, cierre del día
test/                     Pruebas unitarias y de interfaz
test_dataconnect/         Pruebas de permisos contra los emuladores
integration_test/         Prueba de integración con plugins reales
docs/                     Integración con la nube, pruebas, dependencias, evidencias
```

## Servicios en la nube

Qué servicio se usa, para qué, qué datos recibe, cómo se configura y quién puede
acceder: [`docs/integracion-nube.md`](docs/integracion-nube.md).

## Seguridad

Controles de autenticación, autorización, validación en servidor, permisos de
recursos, comunicación segura y manejo de secretos: [`SECURITY.md`](SECURITY.md).

## Pruebas

```bash
flutter test
cd test_dataconnect && npm install && npm test
```
Detalle de lo que cubren y últimos resultados: [`docs/pruebas.md`](docs/pruebas.md).
Dependencias y revisión de alertas: [`docs/dependencias.md`](docs/dependencias.md).

## Flujo de trabajo
Ramas `feature/<nombre>` por historia o tarea, pull request y revisión de otro
integrante antes de unir a `main`. GitHub Actions corre análisis y pruebas en
cada push y pull request.
