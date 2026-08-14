import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'navigation_models.dart';

class SearchHistoryStore {
  static const _storageKey = 'recent_mapbox_destinations_v1';
  static const maxItems = 3;

  Future<List<NaviDestination>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_storageKey) ?? const [];
    return raw.map((value) {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return NaviDestination(
        name: json['name'] as String,
        address: json['address'] as String,
        coordinate: NavigationCoordinate(
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
        ),
      );
    }).toList();
  }

  Future<List<NaviDestination>> add(NaviDestination destination) async {
    final current = await load();
    final updated = [
      destination,
      ...current.where(
        (item) =>
            item.name != destination.name || item.address != destination.address,
      ),
    ].take(maxItems).toList();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      updated
          .map(
            (item) => jsonEncode({
              'name': item.name,
              'address': item.address,
              'latitude': item.coordinate.latitude,
              'longitude': item.coordinate.longitude,
            }),
          )
          .toList(),
    );
    return updated;
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}

