# Reporte técnico · Semana 10

**Asignatura:** Desarrollo Móvil Integral  
**Proyecto:** GeoExplora · Variante OpenStreetMap  
**Alumno:** [COMPLETAR]  
**Fecha:** [COMPLETAR]  
**URL del repositorio y rama feature/maps-geolocation:** [PEGAR ENLACE]

## 1. Objetivo

Crear un localizador de puntos de interés con GPS en tiempo real, mapa interactivo, marcadores seleccionables, cálculo de distancia y dirección postal.

## 2. Tecnologías

Flutter, Dart, flutter_map, latlong2, geolocator, geocoding, OpenStreetMap.

## 3. Implementación

Se verifica la disponibilidad del servicio de ubicación y se solicitan permisos. El mapa se centra en el usuario y escucha cambios de ubicación de al menos 10 m. El toque en el mapa agrega un marcador rojo. La distancia se obtiene con Geolocator.distanceBetween. El método placemarkFromCoordinates consulta el geocodificador nativo para describir calle, colonia y localidad cuando existen datos.

## 4. Seguridad y cambio de proveedor

El ejercicio original solicita Maps SDK for Android y protección de API Key en Google Cloud, pero en esta variante se sustituye por OpenStreetMap debido a la obligación de activar facturación en Google Cloud. **No puede demostrarse una restricción de API Key de Google porque esta versión no la utiliza.** No se publican credenciales. Se respetan identificación de cliente y atribución OpenStreetMap.

## 5. Evidencia de pruebas (llenar tras ejecución real)

| Caso | Resultado esperado | Observado | Captura |
|---|---|---|---|
| Autorizar GPS | Coordenadas y cámara centrada | [PENDIENTE] | [CAPTURA 1] |
| Tocar mapa | Marcador rojo | [PENDIENTE] | [CAPTURA 2] |
| Distancia | Metros o kilómetros y línea | [PENDIENTE] | [CAPTURA 3] |
| Geocodificación | Calle y colonia aproximadas | [PENDIENTE] | [CAPTURA 4] |
| Revocar permiso | Mensaje y reintento | [PENDIENTE] | [CAPTURA 5] |

## 6. Conclusión

La variante cubre las funciones geoespaciales solicitadas sin usar Google Cloud. Debe aclararse con el docente la sustitución de proveedor y agregar pruebas reales antes de la entrega.
