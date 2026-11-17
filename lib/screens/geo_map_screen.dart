import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GeoMapScreen extends StatefulWidget {
  const GeoMapScreen({super.key});

  @override
  State<GeoMapScreen> createState() => _GeoMapScreenState();
}

class _GeoMapScreenState extends State<GeoMapScreen> {
  static const inicio = LatLng(20.2756, -97.9611);
  final MapController _controller = MapController();
  StreamSubscription<Position>? _gps;
  Position? _usuario;
  LatLng? _destino;
  String _estado = 'Buscando GPS...';
  String _direccion = 'Toca el mapa para consultar una dirección.';
  bool _cargando = true;
  bool _mapaListo = false;
  bool _seguir = true;
  int _consulta = 0;

  @override
  void initState() {
    super.initState();
    _iniciarGPS();
  }

  void _estadoGPS(String texto) {
    if (!mounted) return;
    setState(() {
      _estado = texto;
      _cargando = false;
    });
  }

  Future<bool> _permisos() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _estadoGPS('GPS apagado. Actívalo en Ajustes.');
      return false;
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.deniedForever) {
      _estadoGPS('Permiso bloqueado: habilítalo en Ajustes de la app.');
      return false;
    }
    if (permiso == LocationPermission.denied) {
      _estadoGPS('Permiso denegado. Pulsa reintentar.');
      return false;
    }
    return true;
  }

  Future<void> _iniciarGPS() async {
    await _gps?.cancel();
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _estado = 'Comprobando permisos GPS...';
    });
    try {
      if (!await _permisos() || !mounted) return;
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _actualizar(posicion, centrar: true);
      if (!mounted) return;
      _gps = Geolocator.getPositionStream(
  locationSettings: AndroidSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
    intervalDuration: const Duration(milliseconds: 100),
  ),
).listen(
  (Position posicion) {
    if (!mounted) return;

    _actualizar(posicion, centrar: _seguir);

    debugPrint(
      'GPS actualizado: '
      '${posicion.latitude}, ${posicion.longitude} '
      'Precisión: ${posicion.accuracy} m',
    );
  },
  onError: (Object error) {
    _estadoGPS('Error GPS: $error');
  },
);
    } catch (error) {
      _estadoGPS('No se pudo obtener GPS: $error');
    }
  }

  void _actualizar(Position posicion, {required bool centrar}) {
    if (!mounted) return;
    setState(() {
      _usuario = posicion;
      _cargando = false;
      _estado = 'GPS activo · precisión ±${posicion.accuracy.toStringAsFixed(0)} m';
    });
    if (centrar && _mapaListo) {
      _controller.move(LatLng(posicion.latitude, posicion.longitude), 16);
    }
  }

  Future<void> _marcar(LatLng punto) async {
    final numero = ++_consulta;
    setState(() {
      _destino = punto;
      _seguir = false;
      _direccion = 'Buscando calle y colonia...';
    });
    try {
      final geocoding = Geocoding(
  locale: const Locale('es', 'MX'),
);

final lugares = await geocoding.placemarkFromCoordinates(
  punto.latitude,
  punto.longitude,
);
      if (!mounted || numero != _consulta) return;
      if (lugares.isEmpty) {
        setState(() => _direccion = 'Dirección no disponible.');
        return;
      }
      final lugar = lugares.first;
      final partes = <String>{
        ...[
          lugar.street,
          lugar.subLocality,
          lugar.locality,
          lugar.administrativeArea,
          lugar.postalCode,
        ].whereType<String>().where((valor) => valor.trim().isNotEmpty),
      };
      setState(() => _direccion = partes.isEmpty
          ? 'Dirección no disponible.'
          : partes.join(', '));
    } catch (error) {
      if (!mounted || numero != _consulta) return;
      setState(() => _direccion = 'Error de geocodificación: $error');
    }
  }

  double? get _metros {
    if (_usuario == null || _destino == null) return null;
    return Geolocator.distanceBetween(
      _usuario!.latitude,
      _usuario!.longitude,
      _destino!.latitude,
      _destino!.longitude,
    );
  }

  String get _distancia {
    final metros = _metros;
    if (metros == null) return 'Selecciona un destino';
    return metros < 1000
        ? '${metros.toStringAsFixed(0)} metros'
        : '${(metros / 1000).toStringAsFixed(2)} km';
  }

  List<Marker> get _marcadores => [
        if (_usuario != null)
          Marker(
            point: LatLng(_usuario!.latitude, _usuario!.longitude),
            width: 54,
            height: 54,
            child: const Tooltip(
              message: 'Ubicación actual',
              child: Icon(Icons.location_on, color: Colors.blue, size: 45),
            ),
          ),
        if (_destino != null)
          Marker(
            point: _destino!,
            width: 54,
            height: 54,
            child: const Tooltip(
              message: 'Punto de interés',
              child: Icon(Icons.location_on, color: Colors.red, size: 45),
            ),
          ),
      ];

  void _centrar() {
    final actual = _usuario;
    if (actual == null) {
      _iniciarGPS();
      return;
    }
    setState(() => _seguir = true);
    if (_mapaListo) _controller.move(LatLng(actual.latitude, actual.longitude), 16);
  }

  @override
  void dispose() {
    _gps?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actual = _usuario;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GeoExplora · OpenStreetMap'),
            Text('Semana 10 · Puntos de interés', style: TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF0C806F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _iniciarGPS,
            tooltip: 'Reintentar GPS',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: inicio,
                    initialZoom: 15,
                    minZoom: 3,
                    maxZoom: 19,
                    onMapReady: () {
                      _mapaListo = true;
                      if (_usuario != null) _centrar();
                    },
                    onTap: (_, punto) => _marcar(punto),
                    onPositionChanged: (_, hasGesture) {
                      if (hasGesture) _seguir = false;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.semana10_osm',
                      maxNativeZoom: 19,
                    ),
                    if (actual != null && _destino != null)
                      PolylineLayer(polylines: [
                        Polyline(
                          points: [
                            LatLng(actual.latitude, actual.longitude),
                            _destino!,
                          ],
                          strokeWidth: 3,
                          color: const Color(0xFF0C806F),
                        ),
                      ]),
                    MarkerLayer(markers: _marcadores),
                    const RichAttributionWidget(attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ]),
                  ],
                ),
                if (_cargando)
                  const Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Buscando ubicación GPS...'),
                        ]),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 20,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'centrar',
                    onPressed: _centrar,
                    tooltip: 'Centrar en mi ubicación',
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Icon(
                      actual == null ? Icons.gps_off : Icons.gps_fixed,
                      color: const Color(0xFF0C806F),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_estado, style: const TextStyle(fontSize: 12))),
                  ]),
                  const SizedBox(height: 7),
                  Text(
                    actual == null
                        ? 'Coordenadas pendientes'
                        : 'Lat: ${actual.latitude.toStringAsFixed(6)}  ·  Long: ${actual.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Divider(height: 18),
                  const Text('DESTINO', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_destino == null
                      ? 'Toca el mapa para agregar un marcador.'
                      : '${_destino!.latitude.toStringAsFixed(6)}, ${_destino!.longitude.toStringAsFixed(6)}'),
                  const SizedBox(height: 7),
                  Text('Distancia: $_distancia',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 7),
                  Text('Dirección: $_direccion',
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  if (_destino != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          ++_consulta;
                          _destino = null;
                          _direccion = 'Toca el mapa para consultar una dirección.';
                        }),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Quitar marcador'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
