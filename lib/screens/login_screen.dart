import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/dependencies.dart';
import '../../services/auth_service.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final authService = useMemoized(() => AuthService());
    final isLoading = useState(false);

    Future<void> login() async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unesite email i lozinku.')),
        );
        return;
      }

      try {
        isLoading.value = true;
        final auth = getIt<FirebaseAuth>();
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (context.mounted) context.go('/home');
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

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (e, stackTrace) {
        debugPrint('Neuhvaćena greška kod login-a: $e');
        debugPrintStack(stackTrace: stackTrace);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Došlo je do neočekivane greške.')),
        );
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> loginWithGoogle() async {
      try {
        isLoading.value = true;
        final result = await authService.signInWithGoogle();
        if (result != null && context.mounted) {
          context.go('/home');
        }
      } catch (e, stackTrace) {
        debugPrint('Greška pri Google prijavi: $e');
        debugPrintStack(stackTrace: stackTrace);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Prijava')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Lozinka'),
              obscureText: true,
            ),

            const SizedBox(height: 32),

            isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
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
              onPressed: loginWithGoogle,
              label: const Text('Nastavi s Google nalogom'),
              icon: const Icon(Icons.login),
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
              onPressed: () => context.go('/home'),
              child: const Text('Posjeti bez prijave'),
            ),
          ],
        ),
      ),
    );
  }
}
