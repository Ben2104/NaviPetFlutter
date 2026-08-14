import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/mapbox_config.dart';
import '../data/mapbox_navigation_service.dart';
import '../data/navigation_models.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/search_bar_field.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapboxNavigationService _navigationService;
  final FlutterTts _tts = FlutterTts();

  MapboxMap? _map;
  PolylineAnnotationManager? _routeManager;
  PointAnnotationManager? _destinationManager;
  StreamSubscription<geo.Position>? _positionSubscription;
  geo.Position? _position;
  NaviDestination? _destination;
  NavigationRoute? _route;
  int _stepIndex = 0;
  bool _loadingRoute = false;
  bool _navigating = false;
  String? _locationMessage;
  DateTime? _lastReroute;

  @override
  void initState() {
    super.initState();
    _navigationService = MapboxNavigationService(
      accessToken: mapboxPublicToken,
    );
    _tts
      ..setLanguage('en-US')
      ..setSpeechRate(0.48);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _tts.stop();
    _navigationService.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _map = mapboxMap;
    _routeManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();
    _destinationManager = await mapboxMap.annotations
        .createPointAnnotationManager();
    await _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }
    if (permission == geo.LocationPermission.denied ||
        permission == geo.LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _locationMessage = permission == geo.LocationPermission.deniedForever
              ? 'Location is disabled for NaviPet. Enable it in Settings.'
              : 'Location permission is required for navigation.';
        });
      }
      return;
    }
    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      if (mounted) {
        setState(() => _locationMessage = 'Turn on Location Services.');
      }
      return;
    }

    await _map?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: AppColors.amber.toARGB32(),
        showAccuracyRing: true,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
      ),
    );

    const settings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );
    try {
      _position = await geo.Geolocator.getCurrentPosition(
        locationSettings: settings,
      );
      if (mounted) {
        setState(() => _locationMessage = null);
        await _centerOnUser();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _locationMessage = 'Waiting for a GPS location…');
      }
    }

    _positionSubscription =
        geo.Geolocator.getPositionStream(locationSettings: settings).listen(
          (position) {
            _position = position;
            if (mounted) setState(() => _locationMessage = null);
            if (_navigating) _handleNavigationUpdate(position);
          },
          onError: (Object error) {
            if (mounted) setState(() => _locationMessage = error.toString());
          },
        );
  }

  Future<void> _openSearch() async {
    final destination = await context.push<NaviDestination>('/search');
    if (!mounted || destination == null) return;
    await _previewRoute(destination);
  }

  Future<void> _previewRoute(NaviDestination destination) async {
    final origin = _position == null
        ? const NavigationCoordinate(latitude: csulbLat, longitude: csulbLng)
        : NavigationCoordinate(
            latitude: _position!.latitude,
            longitude: _position!.longitude,
          );
    setState(() {
      _destination = destination;
      _loadingRoute = true;
      _navigating = false;
      _route = null;
      _stepIndex = 0;
    });

    try {
      final route = await _navigationService.getRoute(
        origin: origin,
        destination: destination.coordinate,
      );
      await _drawRoute(route, destination);
      if (!mounted) return;
      setState(() => _route = route);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _loadingRoute = false);
    }
  }

  Future<void> _drawRoute(
    NavigationRoute route,
    NaviDestination destination,
  ) async {
    await _routeManager?.deleteAll();
    await _destinationManager?.deleteAll();
    if (route.coordinates.isNotEmpty) {
      await _routeManager?.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: route.coordinates
                .map((point) => Position(point.longitude, point.latitude))
                .toList(),
          ),
          lineColor: AppColors.navy.toARGB32(),
          lineBorderColor: Colors.white.toARGB32(),
          lineBorderWidth: 2,
          lineWidth: 7,
          lineJoin: LineJoin.ROUND,
        ),
      );
    }
    await _destinationManager?.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            destination.coordinate.longitude,
            destination.coordinate.latitude,
          ),
        ),
        textField: destination.name,
        textOffset: [0, -1.8],
        textColor: AppColors.navy.toARGB32(),
        textHaloColor: Colors.white.toARGB32(),
        textHaloWidth: 2,
        textSize: 13,
      ),
    );
    await _fitRoute(route);
  }

  Future<void> _fitRoute(NavigationRoute route) async {
    final map = _map;
    if (map == null || route.coordinates.isEmpty) return;
    final camera = await map.cameraForCoordinatesPadding(
      route.coordinates
          .map(
            (point) =>
                Point(coordinates: Position(point.longitude, point.latitude)),
          )
          .toList(),
      CameraOptions(bearing: 0, pitch: 0),
      MbxEdgeInsets(top: 150, left: 50, bottom: 300, right: 50),
      17,
      null,
    );
    await map.easeTo(camera, MapAnimationOptions(duration: 700));
  }

  Future<void> _startNavigation() async {
    final route = _route;
    if (route == null || route.steps.isEmpty) return;
    if (_position == null) {
      _showMessage('Waiting for your GPS location before navigation starts.');
      return;
    }
    setState(() {
      _navigating = true;
      _stepIndex = 0;
    });
    await _speak(route.steps.first.instruction);
    await _centerOnUser(following: true);
  }

  Future<void> _handleNavigationUpdate(geo.Position position) async {
    final route = _route;
    final destination = _destination;
    if (!_navigating || route == null || destination == null) return;

    if (_stepIndex < route.steps.length) {
      final step = route.steps[_stepIndex];
      final distance = geo.Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        step.maneuver.latitude,
        step.maneuver.longitude,
      );
      if (distance < 18 && _stepIndex < route.steps.length - 1) {
        setState(() => _stepIndex += 1);
        await _speak(route.steps[_stepIndex].instruction);
      }
    }

    final arrivalDistance = geo.Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destination.coordinate.latitude,
      destination.coordinate.longitude,
    );
    if (arrivalDistance < 15) {
      setState(() => _navigating = false);
      await _speak('You have arrived at ${destination.name}.');
      if (mounted) _showMessage('You have arrived at ${destination.name}.');
      return;
    }

    await _maybeReroute(position, route, destination);
    await _centerOnUser(following: true);
  }

  Future<void> _maybeReroute(
    geo.Position position,
    NavigationRoute route,
    NaviDestination destination,
  ) async {
    if (route.coordinates.isEmpty) return;
    var nearestDistance = double.infinity;
    for (var index = 0; index < route.coordinates.length; index += 4) {
      final point = route.coordinates[index];
      final distance = geo.Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < nearestDistance) nearestDistance = distance;
    }
    if (nearestDistance < 45) return;
    if (_lastReroute != null &&
        DateTime.now().difference(_lastReroute!) <
            const Duration(seconds: 15)) {
      return;
    }

    _lastReroute = DateTime.now();
    try {
      final newRoute = await _navigationService.getRoute(
        origin: NavigationCoordinate(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        destination: destination.coordinate,
      );
      await _drawRoute(newRoute, destination);
      if (!mounted) return;
      setState(() {
        _route = newRoute;
        _stepIndex = 0;
      });
      if (newRoute.steps.isNotEmpty) {
        await _speak('Route updated. ${newRoute.steps.first.instruction}');
      }
    } catch (_) {
      // Keep the last valid route if a background reroute cannot be fetched.
    }
  }

  Future<void> _centerOnUser({bool following = false}) async {
    final map = _map;
    final position = _position;
    if (map == null || position == null) return;
    await map.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: following ? 17.5 : 16,
        pitch: 0,
        bearing: following && position.heading >= 0 ? position.heading : 0,
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _stopNavigation() async {
    await _tts.stop();
    if (mounted) setState(() => _navigating = false);
    final route = _route;
    if (route != null) await _fitRoute(route);
  }

  Future<void> _clearRoute() async {
    await _tts.stop();
    await _routeManager?.deleteAll();
    await _destinationManager?.deleteAll();
    if (mounted) {
      setState(() {
        _destination = null;
        _route = null;
        _navigating = false;
        _stepIndex = 0;
      });
    }
  }

  Future<void> _speak(String instruction) async {
    await _tts.stop();
    await _tts.speak(instruction);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = context.watch<AppState>().activeUser;
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: AppColors.map,
      bottomNavigationBar: _navigating
          ? null
          : const NaviBottomNav(active: NaviTab.location),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey('navipet-map'),
            styleUri: mapboxStyle,
            viewport: CameraViewportState(
              center: Point(coordinates: Position(csulbLng, csulbLat)),
              zoom: csulbZoom,
            ),
            onMapCreated: _onMapCreated,
          ),
          if (!_navigating)
            Positioned(
              top: padding.top + AppSpacing.sm,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: SearchBarField(
                placeholder: _destination?.name ?? 'Where to?',
                onPressed: _openSearch,
                right: GestureDetector(
                  onTap: () => context.push('/account'),
                  child: _avatar(
                    activeUser?.name ?? '?',
                    activeUser?.avatarColor ?? AppColors.amber,
                  ),
                ),
              ),
            ),
          if (_navigating && _route != null)
            Positioned(
              top: padding.top + 8,
              left: 12,
              right: 12,
              child: _instructionCard(_route!),
            ),
          Positioned(
            right: 16,
            bottom:
                (_route == null ? 24 : 210) +
                (_navigating ? padding.bottom : 0),
            child: FloatingActionButton.small(
              heroTag: 'recenter',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.navy,
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_locationMessage != null)
            Positioned(
              left: 16,
              right: 16,
              top: padding.top + (_navigating ? 112 : 80),
              child: Material(
                color: const Color(0xFFFFF4D6),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_locationMessage!),
                ),
              ),
            ),
          if (_loadingRoute)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_route != null && _destination != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: _navigating ? padding.bottom + 12 : 12,
              child: _routeCard(_route!, _destination!),
            ),
        ],
      ),
    );
  }

  Widget _instructionCard(NavigationRoute route) {
    final step = route.steps.isEmpty
        ? null
        : route.steps[_stepIndex.clamp(0, route.steps.length - 1)];
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(16),
      color: AppColors.navy,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.navigation, color: AppColors.amber, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                step?.instruction ?? 'Follow the highlighted route',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(NavigationRoute route, NaviDestination destination) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFF1C2),
                  child: Icon(Icons.directions_walk, color: AppColors.amberInk),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${route.durationLabel} • ${route.distanceLabel}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _clearRoute,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigating ? _stopNavigation : _startNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navigating
                      ? AppColors.danger
                      : AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: const StadiumBorder(),
                ),
                icon: Icon(_navigating ? Icons.stop : Icons.navigation),
                label: Text(_navigating ? 'End Navigation' : 'Start Walking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String name, Color color) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
