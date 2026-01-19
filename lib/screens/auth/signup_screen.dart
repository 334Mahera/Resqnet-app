import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _role = 'need_help';
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
        title: const Text("Create account"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  "Get help near you in minutes",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Sign up to continue",
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 24),

                _input(_nameController, "Full name", Icons.person),
                _input(_emailController, "Email", Icons.email),
                _password(_passwordController, "Password"),
                _password(_confirmPasswordController, "Confirm password"),

                const SizedBox(height: 20),

                const Text(
                  "You are signing up as",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _roleChip("Need Help", 'need_help'),
                    const SizedBox(width: 12),
                    _roleChip("Volunteer", 'volunteer'),
                  ],
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),

      // 🔘 Bottom CTA
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
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
                    if (!_formKey.currentState!.validate()) return;

                    if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      setState(() => _error = "Passwords do not match");
                      return;
                    }

                    setState(() {
                      _loading = true;
                      _error = null;
                    });

                    final err = await auth.signUp(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      displayName: _nameController.text.trim(),
                      role: _role,
                    );

                    setState(() => _loading = false);

                    if (err != null) {
                      setState(() => _error = err);
                      return;
                    }

                    Navigator.pushReplacementNamed(
                      context,
                      _role == 'volunteer'
                          ? Routes.volunteerHome
                          : Routes.userHome, // ✅ FIXED
                    );
                  },
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Create account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
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
      child: TextFormField(
        controller: c,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
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

  Widget _password(TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        obscureText: true,
        validator: (v) =>
            v != null && v.length < 6 ? "Minimum 6 characters" : null,
        decoration: InputDecoration(
          hintText: hint,
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

  Widget _roleChip(String label, String value) {
    final selected = _role == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _role = value),
      selectedColor: const Color(0xFF0C831F),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
    );
  }
}
