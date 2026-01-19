import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../common/status_tracker_widget.dart';
import '../common/map_tracking_screen.dart';


class UserRequestsScreen extends StatelessWidget {
  const UserRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthService>(context, listen: false).uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: uid) 
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No requests yet",
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'requested';
              final statusStep = _getStatusStep(status);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Title
                      Text(
                        data['title'] ?? 'Help Request',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 🔹 Description
                      Text(
                        data['description'] ?? '',
                        style: const TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 Status Tracker
                      StatusTracker(step: statusStep),

                      const SizedBox(height: 12),

                      // 🔹 Live Map Tracking
                      if (data['volunteerLat'] != null &&
                          data['volunteerLng'] != null &&
                          data['latitude'] != null &&
                          data['longitude'] != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text("Track Volunteer"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C831F),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapTrackingScreen(
                                    userLat: data['latitude'],
                                    userLng: data['longitude'],
                                    volLat: data['volunteerLat'],
                                    volLng: data['volunteerLng'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔹 Converts request status → step index
  int _getStatusStep(String status) {
    switch (status) {
      case 'requested':
        return 0;
      case 'volunteer_assigned':
        return 1;
      case 'on_the_way':
        return 2;
      case 'arrived':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }
}
