import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ✅ kIsWeb
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? currentUser;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // --------------------------------------------------
  // 🔹 AUTH STATE LISTENER
  // --------------------------------------------------
  Future<void> _onAuthStateChanged(User? fbUser) async {
    if (fbUser == null) {
      currentUser = null;
      notifyListeners();
      return;
    }

    final doc = await _db.collection('users').doc(fbUser.uid).get();

    if (doc.exists) {
      currentUser = AppUser.fromMap(doc.data()!);
    } else {
      currentUser = AppUser(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? '',
        role: 'need_help',
        photoUrl: fbUser.photoURL,
      );

      await _db
          .collection('users')
          .doc(fbUser.uid)
          .set(currentUser!.toMap());
    }

    await _saveFCMTokenIfNeeded(); // ✅ safe now
    notifyListeners();
  }

  // --------------------------------------------------
  // 🔹 GETTERS
  // --------------------------------------------------
  User? get firebaseUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;

  // --------------------------------------------------
  // 🔹 SIGN IN
  // --------------------------------------------------
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // --------------------------------------------------
  // 🔹 SIGN UP
  // --------------------------------------------------
  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user!;
      await user.updateDisplayName(displayName);

      final appUser = AppUser(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: role,
        photoUrl: user.photoURL,
      );

      await _db
          .collection('users')
          .doc(user.uid)
          .set(appUser.toMap());

      currentUser = appUser;

      await _saveFCMTokenIfNeeded(); // ✅ safe
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // --------------------------------------------------
  // 🔹 SIGN OUT
  // --------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  // --------------------------------------------------
  // 🔹 SAVE FCM TOKEN (ANDROID ONLY)
  // --------------------------------------------------
  Future<void> _saveFCMTokenIfNeeded() async {
    if (kIsWeb) return; // 🚫 disable FCM on web
    if (currentUser == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await _db.collection('users').doc(currentUser!.uid).update({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
