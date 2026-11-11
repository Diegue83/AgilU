# ÁgilU

App móvil para pre-ordenar alimentos en cafeterías universitarias.
**Stack:** Flutter + Firebase · **Arquitectura:** MVVM · **Metodología:** Scrum

## Equipo
- Banda López Mildred Mariana — Flutter / UI
- Juarez Cruz Juan Diego — Firebase / Backend
- Vargas Vargas Zayda Fernanda — Diseño de interfaces

## Estructura (MVVM)
```
lib/
├── core/          Tema, rutas y configuración (app_config.dart)
├── data/
│   ├── models/        Producto, ItemCarrito, Pedido
│   └── repositories/  Interfaces + implementación Mock + implementación Firebase
├── ui/            Una carpeta por pantalla: *_view.dart + *_view_model.dart
│   ├── auth/  menu/  cart/  pedido/
├── app.dart       MaterialApp y rutas
└── main.dart      Inyección de dependencias (Provider)
```
Flujo implementado: Login/Registro → Menú → Carrito → Confirmación con folio.

## Cómo correrlo
Este repositorio contiene solo el código (`lib/`, `test/`, `pubspec.yaml`).
Las carpetas de plataforma (android/ios) se generan una sola vez:

```bash
flutter create . --project-name agilu --org mx.edu.utng
flutter pub get
flutter run
```
La app usa **Firebase** (`AppConfig.usarFirebase = true`). Para correr sin Firebase,
con datos de ejemplo, cámbialo a `false`: cualquier correo válido y contraseña de 6+ caracteres entra.

## Configurar Firebase en tu máquina
El proyecto de Firebase es `agilu-a232a`. Los archivos `google-services.json`,
`GoogleService-Info.plist` y `firebase_options.dart` están en `.gitignore`, así que cada
integrante los genera una vez:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=agilu-a232a
```

Sin `lib/firebase_options.dart` la app no compila.

En la consola de Firebase debe estar activo Authentication (correo/contraseña).

## Base de datos: SQL Connect (Data Connect)
Los datos viven en PostgreSQL a través de SQL Connect (`agilu-a232a-service`, `us-east4`):

```
dataconnect/
├── schema/schema.gql   Tablas (Usuario, Autenticacion, Puesto, Producto, Pedido, DetallePedido…)
├── agilu/              Conector de la app: queries.gql, mutations.gql, connector.yaml
└── seed_data.gql       Catálogo de prueba (solo emulador)
```

El SDK de Dart se genera en `lib/dataconnect_generated/` (no se edita a mano). Después de cambiar
el esquema o las operaciones:
```bash
firebase dataconnect:sdk:generate
```

Publicar esquema y conector (migra la base de Cloud SQL; revisar el plan antes de aceptar):
```bash
firebase deploy --only dataconnect
```

El catálogo de producción se da de alta con las mutaciones `CrearPuesto` y `CrearProducto`, que solo
se pueden ejecutar con privilegios de administrador (`firebase dataconnect:execute`).

### Correr la app contra los emuladores
```bash
firebase emulators:start --only auth,dataconnect --project demo-agilu
```
En otra terminal, sembrar el catálogo de prueba y abrir la app:
```bash
node test_dataconnect/sembrar.js
flutter run --dart-define=EMULADORES=true
```

## Seguridad
- **Permisos en SQL Connect** (`dataconnect/agilu/*.gql`): todas las operaciones piden sesión
  (`@auth(level: USER)`) y filtran por `auth.uid`, así que un alumno solo ve su perfil y sus pedidos.
  `CrearPedido` toma los precios de la tabla `producto`, calcula el total y asigna el folio en el
  servidor; rechaza productos no disponibles, de otro puesto, cantidades inválidas y horas pasadas.
  Las altas del catálogo son `NO_ACCESS` (solo administrador).
- **Firestore** ya no se usa: `firestore.rules` niega todo el acceso. Publicarlas:
  ```bash
  firebase deploy --only firestore:rules
  ```
- **Transporte (Android)**: `android/app/src/main/res/xml/network_security_config.xml` bloquea HTTP
  en claro, ignora certificados instalados por el usuario (salvo en debug) y fija las raíces de
  Google Trust Services para `googleapis.com` y `firebaseio.com`. Los servidores de Firebase
  negocian TLS 1.3 (Android 10+). Los pines expiran el **2027-11-01**: antes de esa fecha hay que revisarlos y renovar la expiración.

## Pruebas
```bash
flutter test
```

Pruebas de permisos de SQL Connect (requieren Node.js y Firebase CLI; usan los emuladores):
```bash
cd test_dataconnect
npm install
npm test
```

Prueba de integración en Windows contra los emuladores (registro, menú y pedido con los plugins reales):
```bash
firebase emulators:exec --only auth,dataconnect --project demo-agilu "flutter test integration_test -d windows"
```

## Flujo de trabajo
Ramas `feature/<nombre>` desde `main`, Pull Request y revisión de otro integrante antes de hacer merge.
Tablero: https://trello.com/b/Hbim6YjX
