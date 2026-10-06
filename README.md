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
Por defecto corre con **datos de ejemplo** (`AppConfig.usarFirebase = false`),
sin necesidad de Firebase. Cualquier correo con `@` y contraseña de 6+ caracteres entra.

## Conectar Firebase (Juan Diego)
1. Crear el proyecto en Firebase y activar Authentication (correo/contraseña) y Cloud Firestore.
2. Configurar la app: `flutterfire configure` (o agregar `google-services.json`).
3. Crear la colección `productos` con campos: `nombre`, `descripcion`, `precio` (number), `categoria`, `disponible` (bool).
4. Cambiar `usarFirebase` a `true` en `lib/core/app_config.dart`.

Los archivos `google-services.json`, `GoogleService-Info.plist` y `firebase_options.dart` están en `.gitignore`.

## Pruebas
```bash
flutter test
```

## Flujo de trabajo
Ramas `feature/<nombre>` desde `main`, Pull Request y revisión de otro integrante antes de hacer merge.
Tablero: https://trello.com/b/Hbim6YjX
