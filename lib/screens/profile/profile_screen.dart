import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';
import '../../../routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _editing = false;
  bool _loading = false;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    _nameController.text = user.displayName;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

     
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
         
          _profileHeader(user),

          const SizedBox(height: 16),

          
          _infoCard(
            title: "Personal Information",
            children: [
              _inputField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline,
                enabled: _editing,
              ),
              const SizedBox(height: 12),
              _inputField(
                label: "Email",
                icon: Icons.email_outlined,
                enabled: false,
                hint: user.email,
              ),
            ],
          ),

          const SizedBox(height: 16),

         
          _infoCard(
            title: "Role",
            children: [
              Chip(
                label: Text(
                  user.role == 'need_help' ? 'Need Help' : 'Volunteer',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: user.role == 'need_help'
                    ? Colors.redAccent
                    : const Color(0xFF0C831F),
              ),
            ],
          ),

          const SizedBox(height: 24),

          
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C831F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loading
                  ? null
                  : () async {
                      if (!_editing) {
                        setState(() => _editing = true);
                        return;
                      }

                      setState(() => _loading = true);

                      await FirestoreService().updateUserField(user.uid, {
                        'displayName': _nameController.text.trim(),
                      });

                      final updatedDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();

                      if (updatedDoc.exists) {
                        auth.currentUser =
                            AppUser.fromMap(updatedDoc.data()!);
                      }

                      setState(() {
                        _editing = false;
                        _loading = false;
                      });
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _editing ? "Save Changes" : "Edit Profile",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(AppUser user) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user.photoUrl != null &&
                                user.photoUrl!.isNotEmpty)
                            ? NetworkImage(user.photoUrl!)
                                as ImageProvider
                            : const AssetImage(
                                'assets/default_avatar.png'),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF0C831F),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    required bool enabled,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final image = File(picked.path);
    setState(() => _imageFile = image);

    await _uploadProfileImage(image);
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser!.uid;

    final ref =
        FirebaseStorage.instance.ref('profile_images/$uid.jpg');
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    await FirestoreService().updateUserField(uid, {'photoUrl': url});

    auth.currentUser = AppUser(
      uid: auth.currentUser!.uid,
      email: auth.currentUser!.email,
      displayName: auth.currentUser!.displayName,
      role: auth.currentUser!.role,
      photoUrl: url,
    );

    setState(() {});
  }
}
