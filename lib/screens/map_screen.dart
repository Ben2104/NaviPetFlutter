import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/mapbox_config.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/search_bar_field.dart';

/// Map screen, ported from the RN `screens/MapScreen.tsx`.
///
/// Unlike the RN app — which embedded Mapbox GL JS in a WebView — this uses the
/// native `mapbox_maps_flutter` SDK. The map opens on the CSULB campus with a
/// "You" pet marker, a floating search bar, and a 2D/3D toggle.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _mode = '2D';

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    final center = Point(coordinates: Position(csulbLng, csulbLat));

    // Orange pin (matches the RN paw marker's accent color).
    final circleManager =
        await mapboxMap.annotations.createCircleAnnotationManager();
    await circleManager.create(CircleAnnotationOptions(
      geometry: center,
      circleRadius: 12,
      circleColor: 0xFFF5A623,
      circleStrokeColor: 0xFFFFFFFF,
      circleStrokeWidth: 2,
    ));

    // "You" label bubble above the pin.
    final pointManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    await pointManager.create(PointAnnotationOptions(
      geometry: center,
      textField: 'You',
      textOffset: [0.0, -2.2],
      textColor: 0xFF00244E,
      textHaloColor: 0xFFFFFFFF,
      textHaloWidth: 2,
      textSize: 13,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = context.watch<AppState>().activeUser;
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: AppColors.map,
      bottomNavigationBar: const NaviBottomNav(active: NaviTab.location),
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

          // Floating search bar.
          Positioned(
            top: padding.top + AppSpacing.sm,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: SearchBarField(
              placeholder: 'Search campus...',
              onPressed: () => context.push('/search'),
              right: _avatar(activeUser.name, activeUser.avatarColor),
            ),
          ),

          // 2D / 3D toggle (bottom-left).
          Positioned(
            bottom: padding.bottom + AppSpacing.lg,
            left: AppSpacing.lg,
            child: _modeToggle(),
          ),
        ],
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
        name.isNotEmpty ? name.substring(0, 1) : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _modeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['2D', '3D'].map((item) {
          final active = _mode == item;
          return GestureDetector(
            onTap: () {
              // Tapping 3D opens the AR navigation screen (Figma prototype
              // wiring); 2D stays on the map.
              if (item == '3D') {
                context.push('/ar');
              } else {
                setState(() => _mode = item);
              }
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 46),
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
