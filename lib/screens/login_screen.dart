import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        context.go('/home');
      }

    } on FirebaseAuthException catch (e) {
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
          message = 'Došlo je do greške prilikom prijave. Pokušajte ponovo.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      rethrow; 

    } catch (e, stackTrace) {
      debugPrint('Neuhvaćena greška kod login-a: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Došlo je do neočekivane greške. Pokušajte ponovo.'),
          ),
        );
      }

      rethrow;
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        context.go('/home');
      }
    } catch (e, stackTrace) {
      debugPrint('Greška pri Google prijavi: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prijava')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Lozinka'),
              obscureText: true,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _login,
              child: const Text('Prijavi se'),
            ),

            const SizedBox(height: 16),
            const Divider(height: 32),
            const Text(
              "ILI",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _loginWithGoogle,
              label: const Text('Nastavi s Google nalogom'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 3,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 32),

            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('Nemaš račun? Registruj se'),
            ),

            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('Posjeti bez prijave'),
            ),
          ],
        ),
      ),
    );
  }
}
