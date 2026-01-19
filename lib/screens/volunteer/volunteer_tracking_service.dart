import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../services/firestore_service.dart';

class VolunteerTrackingService {
  static StreamSubscription<Position>? _sub;

  static Future<void> start(String requestId) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update every 10 meters
      ),
    ).listen((pos) async {
      await FirestoreService().updateVolunteerLocation(
        requestId: requestId,
        lat: pos.latitude,
        lng: pos.longitude,
      );
    });
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
