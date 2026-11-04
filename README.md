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

En la consola de Firebase deben estar activos Authentication (correo/contraseña) y Cloud Firestore,
con la colección `productos` (`nombre`, `descripcion`, `precio` number, `categoria`, `disponible` bool,
`cafeteriaId`).

## Seguridad
- **Reglas de Firestore** (`firestore.rules`): cada alumno solo puede leer y crear sus propios
  pedidos; nadie puede modificarlos ni borrarlos desde la app; el contador de folios solo avanza
  de uno en uno; el menú es de solo lectura y requiere sesión. Publicarlas:
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

Pruebas de las reglas de Firestore (requieren Node.js, Java y Firebase CLI; usan el emulador):
```bash
cd test_reglas
npm install
npm test
```

## Flujo de trabajo
Ramas `feature/<nombre>` desde `main`, Pull Request y revisión de otro integrante antes de hacer merge.
Tablero: https://trello.com/b/Hbim6YjX
