import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _loginEmail() async {
    final email = _email.text.trim();
    final password = _pass.text;

    if (email.isEmpty || password.isEmpty) {
      _toast('Unesite email i lozinku.');
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _toast('Prijava uspješna.');

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [loginEmail]: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Email adresa nije ispravna.';
          break;
        case 'user-not-found':
          message = 'Nalog s ovom email adresom ne postoji.';
          break;
        case 'wrong-password':
          message = 'Pogrešna lozinka. Pokušajte ponovo.';
          break;
        case 'user-disabled':
          message = 'Ovaj korisnički nalog je onemogućen.';
          break;
        default:
          message = 'Greška pri prijavi. Pokušajte ponovo.';
      }
      _toast(message);
      rethrow;

    } catch (e, stackTrace) {
      debugPrint('Neuhvaćena greška [loginEmail]: $e');
      debugPrintStack(stackTrace: stackTrace);
      _toast('Došlo je do neočekivane greške. Pokušajte ponovo.');
      rethrow;

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registerEmail() async {
    final email = _email.text.trim();
    final password = _pass.text;

    if (email.isEmpty || password.length < 6) {
      _toast('Unesite ispravan email i lozinku (min. 6 znakova).');
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _toast('Registracija uspješna.');

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [registerEmail]: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Ova email adresa je već registrovana.';
          break;
        case 'invalid-email':
          message = 'Email adresa nije ispravna.';
          break;
        case 'weak-password':
          message = 'Lozinka je preslaba. Unesite jaču lozinku.';
          break;
        default:
          message = 'Greška pri registraciji. Pokušajte ponovo.';
      }
      _toast(message);
      rethrow;

    } catch (e, stackTrace) {
      debugPrint('Neuhvaćena greška [registerEmail]: $e');
      debugPrintStack(stackTrace: stackTrace);
      _toast('Došlo je do neočekivane greške. Pokušajte ponovo.');
      rethrow;

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _skip() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      _toast('Gost pristup omogućen.');

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [skip]: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'operation-not-allowed':
          message = 'Gost prijava trenutno nije dozvoljena.';
          break;
        default:
          message = 'Greška pri gost prijavi. Pokušajte ponovo.';
      }
      _toast(message);
      rethrow;

    } catch (e, stackTrace) {
      debugPrint('Neuhvaćena greška [skip]: $e');
      debugPrintStack(stackTrace: stackTrace);
      _toast('Došlo je do neočekivane greške.');
      rethrow;
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
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading) ...[
              ElevatedButton(
                onPressed: _loginEmail,
                child: const Text('Login (Email/Pass)'),
              ),
              OutlinedButton(
                onPressed: _registerEmail,
                child: const Text('Register (Email/Pass)'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _skip,
                child: const Text('Skip for now'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
