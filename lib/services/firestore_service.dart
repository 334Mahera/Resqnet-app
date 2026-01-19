import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String usersCol = 'users';
  final String requestsCol = 'requests';

  Future<void> createUser(AppUser user) async {
    await _db
        .collection(usersCol)
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserDoc(String uid) async {
    final doc = await _db.collection(usersCol).doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    await _db.collection(usersCol).doc(uid).update(data);
  }

  Future<void> createRequest({
    required String userId,
    required String title,
    required String description,
    required String category,
    required String userName,
    required String userEmail,
    double? latitude,
    double? longitude,
  }) async {
    final bool isSOS = category.toUpperCase() == 'SOS';

    await _db.collection(requestsCol).add({
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'sos': isSOS,

      // Order-style status
      'status': 'requested',

      // Location
      'latitude': latitude,
      'longitude': longitude,

      // Volunteer tracking
      'volunteerId': null,
      'volunteerName': null,
      'volunteerLat': null,
      'volunteerLng': null,

      // Meta
      'userName': userName,
      'userEmail': userEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'updatedAt': null,
    });
  }

  Future<void> assignVolunteer({
    required String requestId,
    required String volunteerId,
    required String volunteerName,
    required String volunteerEmail,
  }) async {
    await _db.collection(requestsCol).doc(requestId).update({
      'status': 'volunteer_assigned',
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'volunteerEmail': volunteerEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    await _db.collection(requestsCol).doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateVolunteerLocation({
    required String requestId,
    required double lat,
    required double lng,
  }) async {
    await _db.collection(requestsCol).doc(requestId).update({
      'volunteerLat': lat,
      'volunteerLng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage({
    required String requestId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    await _db
        .collection(requestsCol)
        .doc(requestId)
        .collection('chat')
        .add({
      'senderId': senderId,
      'senderName': senderName.isEmpty ? 'User' : senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String requestId) {
    return _db
        .collection(requestsCol)
        .doc(requestId)
        .collection('chat')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
