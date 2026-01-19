import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'need_help' or 'volunteer'
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isAvailable;
  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
    this.createdAt,
    this.isAvailable = false,
  });

  /// ✅ Factory to create from Firestore Map
  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] ?? '',
        email: m['email'] ?? '',
        displayName: m['displayName'] ?? '',
        role: m['role'] ?? 'need_help',
        photoUrl: m['photoUrl'],
        createdAt: m['createdAt'] != null
            ? (m['createdAt'] as Timestamp).toDate()
            : null,
        isAvailable: m['isAvailable'] ?? false,
      );

  /// ✅ Convert to Map for saving in Firestore
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': role,
        'photoUrl': photoUrl,
        'createdAt': createdAt ?? DateTime.now(),
        'isAvailable': isAvailable,
      };
}
