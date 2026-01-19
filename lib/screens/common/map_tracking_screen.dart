import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../utils/distance_utils.dart';

class MapTrackingScreen extends StatefulWidget {
  final double userLat;
  final double userLng;
  final double volLat;
  final double volLng;

  const MapTrackingScreen({
    super.key,
    required this.userLat,
    required this.userLng,
    required this.volLat,
    required this.volLng,
  });

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
  late GoogleMapController _mapController;

  late LatLng userLatLng;
  late LatLng volunteerLatLng;

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  // 🔑 Google Maps API Key
  final String googleApiKey = "your api key";

  double distanceKm = 0;
  int etaMinutes = 0;

  @override
  void initState() {
    super.initState();

    userLatLng = LatLng(widget.userLat, widget.userLng);
    volunteerLatLng = LatLng(widget.volLat, widget.volLng);

    _calculateDistanceAndETA();
    _addMarkers();
    _drawPolyline();
  }

  void _calculateDistanceAndETA() {
    distanceKm = DistanceUtils.calculateDistance(
      userLatLng.latitude,
      userLatLng.longitude,
      volunteerLatLng.latitude,
      volunteerLatLng.longitude,
    );

    etaMinutes = DistanceUtils.calculateETA(distanceKm);
  }

  void _addMarkers() {
    markers.clear();

    markers.add(
      Marker(
        markerId: const MarkerId("volunteer"),
        position: volunteerLatLng,
        infoWindow: const InfoWindow(title: "Volunteer"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: userLatLng,
        infoWindow: const InfoWindow(title: "User"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  Future<void> _drawPolyline() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(
          volunteerLatLng.latitude,
          volunteerLatLng.longitude,
        ),
        destination: PointLatLng(
          userLatLng.latitude,
          userLatLng.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isEmpty) return;

    final polylineCoordinates =
        result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    setState(() {
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: volunteerLatLng,
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

        
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bike,
                      color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${distanceKm.toStringAsFixed(1)} km • ETA $etaMinutes mins",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
