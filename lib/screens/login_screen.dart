import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted) {
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prijava")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value == null || !value.contains('@') ? "Unesite validan email" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Šifra"),
                obscureText: true,
                validator: (value) =>
                    value == null || value.length < 6 ? "Šifra mora imati bar 6 karaktera" : null,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                      child: const Text("Prijavi se"),
                    ),
              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: const Text("Nemate nalog? Registrujte se"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
