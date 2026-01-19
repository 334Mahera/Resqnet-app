import 'dart:math';

class DistanceUtils {
  static double _deg2rad(double deg) => deg * (pi / 180);

  // 📏 Distance in KM
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // km

    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // ⏱ ETA in minutes (avg speed 40km/h)
  static int calculateETA(double distanceKm) {
    const avgSpeed = 40; // km/h
    final hours = distanceKm / avgSpeed;
    return (hours * 60).round();
  }
}
