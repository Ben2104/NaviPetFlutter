class NavigationCoordinate {
  const NavigationCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.mapboxId,
    required this.name,
    required this.description,
  });

  final String mapboxId;
  final String name;
  final String description;
}

class NaviDestination {
  const NaviDestination({
    required this.name,
    required this.address,
    required this.coordinate,
  });

  final String name;
  final String address;
  final NavigationCoordinate coordinate;
}

class NavigationStep {
  const NavigationStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.maneuver,
  });

  final String instruction;
  final double distanceMeters;
  final double durationSeconds;
  final NavigationCoordinate maneuver;
}

class NavigationRoute {
  const NavigationRoute({
    required this.coordinates,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<NavigationCoordinate> coordinates;
  final List<NavigationStep> steps;
  final double distanceMeters;
  final double durationSeconds;

  String get distanceLabel {
    final miles = distanceMeters / 1609.344;
    if (miles < 0.1) return '${(distanceMeters * 3.28084).round()} ft';
    return '${miles.toStringAsFixed(miles < 10 ? 1 : 0)} mi';
  }

  String get durationLabel {
    final minutes = (durationSeconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '$hours hr' : '$hours hr $remainder min';
  }
}

class NavigationTripSummary {
  const NavigationTripSummary({
    required this.elapsed,
    required this.walkingSteps,
  });

  final Duration elapsed;
  final int? walkingSteps;

  String get walkingStepsLabel => walkingSteps?.toString() ?? 'Unavailable';

  String get elapsedLabel {
    final totalSeconds = elapsed.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}
