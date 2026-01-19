import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
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

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No requests found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (_, i) {
              final doc = requests[i];
              final data = doc.data() as Map<String, dynamic>;

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

                      // 🔴 TITLE
                      Text(
                        data['title'] ?? 'Request',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 👤 USER INFO
                      Text(
                        "User: ${data['userName']} (${data['userEmail']})",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 4),

                      // 🤝 VOLUNTEER INFO
                      if (data['volunteerName'] != null)
                        Text(
                          "Volunteer: ${data['volunteerName']} (${data['volunteerEmail']})",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        )
                      else
                        const Text(
                          "Volunteer: Not assigned",
                          style: TextStyle(color: Colors.red),
                        ),

                      const SizedBox(height: 8),

                      // 📌 STATUS
                      Text(
                        "Status: ${data['status']}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 14),

                      // 🔧 ADMIN ACTIONS
                      Column(
                        children: [

                          // 🔁 REASSIGN VOLUNTEER
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text("Reassign Volunteer"),
                              onPressed: () {
                                _showVolunteerPicker(
                                  context,
                                  requestId: doc.id,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [

                              // ✅ FORCE COMPLETE
                              if (data['status'] != 'completed')
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('requests')
                                          .doc(doc.id)
                                          .update({
                                        'status': 'completed',
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                    },
                                    child: const Text("Force Complete"),
                                  ),
                                ),

                              const SizedBox(width: 10),

                              // ❌ CANCEL
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('requests')
                                        .doc(doc.id)
                                        .update({
                                      'status': 'cancelled_by_admin',
                                      'updatedAt':
                                          FieldValue.serverTimestamp(),
                                    });
                                  },
                                  child: const Text("Cancel"),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  // --------------------------------------------------
  // 👥 VOLUNTEER PICKER
  // --------------------------------------------------
  void _showVolunteerPicker(
    BuildContext context, {
    required String requestId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'volunteer')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final volunteers = snapshot.data!.docs;

            if (volunteers.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text("No volunteers found"),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Assign Volunteer",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...volunteers.map((v) {
                  final data = v.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(data['name'] ?? 'Volunteer'),
                    subtitle: Text(data['email'] ?? ''),
                    trailing: ElevatedButton(
                      child: const Text("Assign"),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('requests')
                            .doc(requestId)
                            .update({
                          'volunteerId': v.id,
                          'volunteerName': data['name'],
                          'volunteerEmail': data['email'],
                          'status': 'volunteer_assigned',
                          'updatedAt':
                              FieldValue.serverTimestamp(),
                        });

                        Navigator.pop(context);
                      },
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}
