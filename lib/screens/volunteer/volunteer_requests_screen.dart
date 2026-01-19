import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../common/map_tracking_screen.dart';
import 'volunteer_tracking_service.dart';

class VolunteerRequestsScreen extends StatelessWidget {
  const VolunteerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Volunteer Requests"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs.where((doc) {
            final s = (doc.data() as Map)['status'];
            return s == 'requested' ||
                s == 'volunteer_assigned' ||
                s == 'on_the_way' ||
                s == 'arrived';
          }).toList();

          if (requests.isEmpty) {
            return const Center(child: Text("No active requests"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (_, i) {
              final doc = requests[i];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data['description'],
                        style: const TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 10),
                      _statusChip(status),
                      const SizedBox(height: 14),

                      // 🔘 ACTIONS
                      Row(
                        children: [

                          // ACCEPT
                          if (status == 'requested')
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0C831F),
                                ),
                                onPressed: () async {
                                  await FirestoreService().assignVolunteer(
                                    requestId: doc.id,
                                    volunteerId: auth.uid!,
                                    volunteerName:
                                        auth.currentUser!.displayName ?? 'Volunteer',
                                        volunteerEmail: auth.currentUser!.email!,
                                  );
                                },
                                child: const Text("Accept"),
                              ),
                            ),

                          // START (🔥 LIVE GPS STARTS)
                          if (status == 'volunteer_assigned')
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                onPressed: () async {
                                  await FirestoreService()
                                      .updateRequestStatus(
                                    requestId: doc.id,
                                    status: 'on_the_way',
                                  );

                                  await VolunteerTrackingService.start(doc.id);
                                },
                                child: const Text("Start"),
                              ),
                            ),

                          // ARRIVED
                          if (status == 'on_the_way')
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () async {
                                  await FirestoreService()
                                      .updateRequestStatus(
                                    requestId: doc.id,
                                    status: 'arrived',
                                  );
                                },
                                child: const Text("Arrived"),
                              ),
                            ),

                          // COMPLETE (🛑 GPS STOP)
                          if (status == 'arrived')
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                onPressed: () async {
                                  VolunteerTrackingService.stop();

                                  await FirestoreService()
                                      .updateRequestStatus(
                                    requestId: doc.id,
                                    status: 'completed',
                                  );
                                },
                                child: const Text("Complete"),
                              ),
                            ),
                        ],
                      ),

                      // 🗺 LIVE MAP BUTTON
                      if ((status == 'on_the_way' || status == 'arrived') &&
                          data['latitude'] != null &&
                          data['longitude'] != null &&
                          data['volunteerLat'] != null &&
                          data['volunteerLng'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.map),
                              label: const Text("Live Map"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 71, 63, 181),
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

  Widget _statusChip(String status) {
    final colors = {
      'requested': Colors.grey,
      'volunteer_assigned': Colors.orange,
      'on_the_way': Colors.blue,
      'arrived': Colors.green,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors[status] ?? Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
