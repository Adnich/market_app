import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));


  Future<void> _loginEmail() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      _toast('Unesi email i lozinku.'); return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
      _toast('Prijava uspješna.');
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Greška pri prijavi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registerEmail() async {
    if (_email.text.trim().isEmpty || _pass.text.length < 6) {
      _toast('Lozinka mora imati barem 6 znakova.'); return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
      _toast('Registracija uspješna.');
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Greška pri registraciji.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _skip() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      _toast('Gost pristup omogućen.');
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Greška pri gost prijavi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _pass, obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading) ...[
              ElevatedButton(onPressed: _loginEmail, child: const Text('Login (Email/Pass)')),
              OutlinedButton(onPressed: _registerEmail, child: const Text('Register (Email/Pass)')),
              const SizedBox(height: 8),
              TextButton(onPressed: _skip, child: const Text('Skip for now')),
            ],
          ],
        ),
      ),
    );
  }
}