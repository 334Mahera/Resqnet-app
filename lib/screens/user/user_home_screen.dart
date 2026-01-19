import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../common/map_tracking_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    final categories = [
      {"title": "Fire", "image": "assets/images/fire.png"},
      {"title": "Medical", "image": "assets/images/medical.png"},
      {"title": "Accident", "image": "assets/images/accident.png"},
      {"title": "Flood", "image": "assets/images/flood.png"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sos, size: 28),
                label: const Text(
                  "SOS EMERGENCY",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  _createRequest(context, category: "SOS", isSOS: true);
                },
              ),
            ),

            const SizedBox(height: 24),

            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where('userId', isEqualTo: auth.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                
                final activeRequests = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'];
                  return status == 'volunteer_assigned' ||
                      status == 'on_the_way' ||
                      status == 'arrived';
                }).toList();

                if (activeRequests.isEmpty) {
                  return const SizedBox();
                }

               
                final data =
                    activeRequests.last.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🚑 Volunteer On The Way",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Status: ${data['status']
                              .toString()
                              .replaceAll('_', ' ')
                              .toUpperCase()}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text("View Live Map"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                            ),
                            onPressed: () {
                              if (data['latitude'] == null ||
                                  data['longitude'] == null ||
                                  data['volunteerLat'] == null ||
                                  data['volunteerLng'] == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Live location not available yet",
                                    ),
                                  ),
                                );
                                return;
                              }

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
            ),

          
            const Text(
              "Emergency Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {
                    _createRequest(
                      context,
                      category: cat['title'] as String,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          cat['image'] as String,
                          height: 42,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['title'] as String,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

           
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "🛡 Stay calm and move to a safe place.\n"
                "Avoid panic and wait for volunteer assistance.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  void _createRequest(
    BuildContext context, {
    required String category,
    bool isSOS = false,
  }) async {
    final auth = context.read<AuthService>();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isSOS ? "SOS Emergency" : "Request Help – $category"),
        content: TextField(
          controller: descController,
          decoration:
              const InputDecoration(hintText: "Describe the situation"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final position =
                  await LocationService.getCurrentLocation(); 

              await FirestoreService().createRequest(
                userId: auth.uid!,
                title: category,
                description:
                    isSOS ? "SOS Emergency" : descController.text.trim(),
                category: category,
                userName: auth.currentUser!.displayName,
                userEmail: auth.currentUser!.email,
                latitude: position.latitude,
                longitude: position.longitude,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Request sent successfully"),
                ),
              );
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}
