import 'package:geolocator/geolocator.dart';

class LocationService {
  // --------------------------------------------------
  // 📍 Ensure location permission
  // --------------------------------------------------
  static Future<void> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled';
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied';
    }
  }

  // --------------------------------------------------
  // 📍 One-time location (User request)
  // --------------------------------------------------
  static Future<Position> getCurrentLocation() async {
    await ensurePermission();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // --------------------------------------------------
  // 🚗 Live location stream (Volunteer tracking)
  // --------------------------------------------------
  static Stream<Position> getLiveLocation({
    int distanceFilter = 10, // meters
  }) async* {
    await ensurePermission();

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
