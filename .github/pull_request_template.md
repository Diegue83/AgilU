## Qué cambia

<!-- Historia o tarea y lo que resuelve, en dos o tres líneas. -->

## Cómo se probó

- [ ] `flutter analyze` sin errores y `flutter test` en verde
- [ ] Pruebas de permisos del servidor (`cd test_dataconnect && npm test`) si cambia `dataconnect/`
- [ ] Probado a mano en el teléfono (describe el flujo)

## Revisión (la hace otro integrante)

- [ ] El código hace lo que pide la historia y sus criterios de aceptación
- [ ] La lógica nueva tiene pruebas del ViewModel o del servidor
- [ ] Ninguna operación confía en la app para permisos: el servidor lo revisa
- [ ] No hay secretos, llaves ni datos personales en el cambio
- [ ] Textos en español y sin errores; la pantalla se entiende sin explicación

Destino: `develop` (o `main` solo para el cierre del sprint o una corrección urgente).
