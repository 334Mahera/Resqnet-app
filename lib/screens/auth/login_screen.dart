import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Welcome back 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Login to continue",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            _input(_emailController, "Email", Icons.email),
            _password(_passwordController),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),

      // 🔘 Bottom CTA + Signup link
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C831F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });

                        final err = await auth.signIn(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        setState(() => _loading = false);

                        if (err != null) {
                          setState(() => _error = err);
                          return;
                        }

                        // 🔑 wait for Firestore user document to load
                        await Future.delayed(
                          const Duration(milliseconds: 300),
                        );

                        final user = auth.currentUser;
                        if (user == null) return;

                        // ✅ ROLE-BASED ROUTING (FINAL)
                        String nextRoute;

                        if (user.role == 'admin') {
                          nextRoute = Routes.adminRoot; // ✅ IMPORTANT
                        } else if (user.role == 'volunteer') {
                          nextRoute = Routes.volunteerHome;
                        } else {
                          nextRoute = Routes.userHome;
                        }

                        Navigator.pushReplacementNamed(
                          context,
                          nextRoute,
                        );
                      },
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ SIGNUP OPTION
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.signup,
                );
              },
              child: const Text(
                "Don’t have an account? Sign up",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0C831F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // UI helpers
  // ------------------------------
  Widget _input(
    TextEditingController c,
    String hint,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _password(TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Password",
          prefixIcon: const Icon(Icons.lock),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
