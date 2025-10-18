import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_app/src/dependencies.dart';

class LoginView extends HookWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passController = useTextEditingController();
    final isLoading = useState(false);

    void toast(String msg) =>
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    Future<void> loginEmail() async {
      final email = emailController.text.trim();
      final password = passController.text;

      if (email.isEmpty || password.isEmpty) {
        toast('Unesite email i lozinku.');
        return;
      }

      isLoading.value = true;
      try {
        final auth = getIt<FirebaseAuth>();
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        toast('Prijava uspješna.');
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException [loginEmail]: ${e.code} - ${e.message}');
        switch (e.code) {
          case 'invalid-email':
            toast('Email adresa nije ispravna.');
            break;
          case 'user-not-found':
            toast('Nalog s ovom email adresom ne postoji.');
            break;
          case 'wrong-password':
            toast('Pogrešna lozinka. Pokušajte ponovo.');
            break;
          case 'user-disabled':
            toast('Ovaj korisnički nalog je onemogućen.');
            break;
          default:
            toast('Greška pri prijavi. Pokušajte ponovo.');
        }
      } catch (e, stack) {
        debugPrint('Greška [loginEmail]: $e');
        debugPrintStack(stackTrace: stack);
        toast('Došlo je do neočekivane greške.');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> registerEmail() async {
      final email = emailController.text.trim();
      final password = passController.text;

      if (email.isEmpty || password.length < 6) {
        toast('Unesite ispravan email i lozinku (min. 6 znakova).');
        return;
      }

      isLoading.value = true;
      try {
        final auth = getIt<FirebaseAuth>();
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        toast('Registracija uspješna.');
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException [registerEmail]: ${e.code} - ${e.message}');
        switch (e.code) {
          case 'email-already-in-use':
            toast('Ova email adresa je već registrovana.');
            break;
          case 'invalid-email':
            toast('Email adresa nije ispravna.');
            break;
          case 'weak-password':
            toast('Lozinka je preslaba. Unesite jaču lozinku.');
            break;
          default:
            toast('Greška pri registraciji. Pokušajte ponovo.');
        }
      } catch (e, stack) {
        debugPrint('Greška [registerEmail]: $e');
        debugPrintStack(stackTrace: stack);
        toast('Došlo je do neočekivane greške.');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> skip() async {
      try {
        final auth = getIt<FirebaseAuth>();
        await auth.signInAnonymously();
        toast('Gost pristup omogućen.');
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException [skip]: ${e.code} - ${e.message}');
        if (e.code == 'operation-not-allowed') {
          toast('Gost prijava trenutno nije dozvoljena.');
        } else {
          toast('Greška pri gost prijavi. Pokušajte ponovo.');
        }
      } catch (e, stack) {
        debugPrint('Greška [skip]: $e');
        debugPrintStack(stackTrace: stack);
        toast('Došlo je do neočekivane greške.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (isLoading.value)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: loginEmail,
                child: const Text('Login (Email/Pass)'),
              ),
              OutlinedButton(
                onPressed: registerEmail,
                child: const Text('Register (Email/Pass)'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: skip,
                child: const Text('Skip for now'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
