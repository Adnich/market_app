import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || !value.contains('@') ? 'Unesite validan email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Lozinka'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Lozinka mora imati bar 6 karaktera' : null,
              ),
              const SizedBox(height: 24),

              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('Registruj se'),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Imaš nalog? Prijavi se.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
