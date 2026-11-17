# Semana 10 · GeoExplora OpenStreetMap (Flutter)

Segunda versión de la práctica de Desarrollo Móvil Integral. **Sin Google Cloud, tarjeta bancaria, API Key ni prepago.** Esta variante conserva el reto funcional; **no cumple literalmente el requisito del docente de usar google_maps_flutter / Maps SDK ni de restringir una API Key de Google**. Pide autorización para usar la alternativa.

## Funciones

1. Ubicación actual con permiso GPS y cámara centrada.
2. Seguimiento por cambios de posición cada 10 m.
3. Mapa OpenStreetMap interactivo con crédito de atribución.
4. Marcadores azul (usuario) y rojo (destino) al tocar.
5. Línea entre usuario y punto de interés.
6. Distancia geodésica con Geolocator.distanceBetween.
7. Dirección aproximada mediante geocodificación inversa nativa.
8. Manejo de GPS desactivado, permisos denegados y errores.
9. Liberación de la suscripción y del controlador en dispose.

## Cómo ejecutarlo en Windows, CMD o PowerShell

Descomprime el ZIP. En VS Code abre la carpeta **semana10_osm** y ejecuta:

    flutter doctor
    powershell -ExecutionPolicy Bypass -File .\configurar.ps1
    flutter devices
    flutter run

El script genera las carpetas nativas Android/iOS, agrega permisos nativos, configura la descripción de privacidad y ejecuta flutter pub get. **No requiere pegar ninguna API Key.**

Para comprobar errores:

    flutter analyze
    flutter test

Para seleccionar un dispositivo:

    flutter run -d emulator-5554

Cambia emulator-5554 por el ID real mostrado en flutter devices. Para crear un APK:

    flutter build apk --debug

## Comportamiento esperado

- Autoriza GPS y comprueba coordenadas. Si el mapa arranca en la UTXJ, pulsa el botón de centrar.
- Toca el mapa: aparece el pin rojo, una línea y la distancia calculada.
- La dirección aparece cuando el geocodificador de Android/iOS tiene datos disponibles.
- En un emulador, cambia la localización simulada para probar el movimiento.
- Desactiva GPS o deniega permisos: aparece un mensaje claro y un botón de reintento.

## Privacidad y dependencias externas

- Las teselas se descargan por Internet de tile.openstreetmap.org y están sujetas a su política. Se identifica la app mediante userAgentPackageName y se acredita a OpenStreetMap en el mapa.
- El servidor público de teselas **no garantiza disponibilidad**, no debe usarse para descargas masivas ni aplicaciones de alto tráfico. Para despliegue público, utiliza un proveedor de teselas con condiciones adecuadas.
- El servicio de geocodificación del dispositivo puede enviar coordenadas a proveedores de la plataforma y puede fallar según país, emulador o conectividad. No requiere una API Key propia.
- No hay credenciales en el proyecto ni en Git.

## Git opcional para entregar

    git init
    git switch -c feature/maps-geolocation
    git add .
    git commit -m "feat(maps): implement openstreetmap with live geolocation"
    git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
    git push -u origin feature/maps-geolocation

El ZIP no crea automáticamente repositorios externos. Completa el reporte en docs/REPORTE_TECNICO.md con capturas y URL real.

**Nota de verificación:** En el entorno de creación no se dispone de Flutter SDK. Por ello la compilación y ejecución deben comprobarse en tu computadora con los comandos indicados.
