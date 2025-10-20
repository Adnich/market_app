import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_app/src/injection.dart';

class RegisterScreen extends HookWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final phoneController = useTextEditingController();
    final dobController = useTextEditingController();
    final selectedGender = useState<String>('muško');
    final isLoading = useState(false);

    Future<void> register() async {
      final name = nameController.text.trim();
      final lastName = lastNameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final phone = phoneController.text.trim();
      final dateOfBirth = dobController.text.trim();
      final gender = selectedGender.value;

      if (name.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Popunite sva obavezna polja.')),
        );
        return;
      }

      try {
        isLoading.value = true;
        final auth = getIt<FirebaseAuth>();

        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = credential.user!.uid;
        final firestore = getIt<FirebaseFirestore>();
        await firestore.collection('users').doc(uid).set({
          'name': '$name $lastName',
          'email': email,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'photoUrl': '',
          'createdAt': Timestamp.now(),
        });


        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registracija uspješna!')),
      );

      if (context.mounted) context.go('/home'); 


      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'Ova email adresa je već registrovana.';
            break;
          case 'invalid-email':
            message = 'Unesena email adresa nije ispravna.';
            break;
          case 'weak-password':
            message = 'Lozinka je preslaba. Molimo unesite jaču lozinku.';
            break;
          default:
            message = 'Došlo je do greške prilikom registracije. Pokušajte ponovo.';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (e, stackTrace) {
        debugPrint('Neuhvaćena greška u registraciji: $e');
        debugPrintStack(stackTrace: stackTrace);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Došlo je do neočekivane greške.')),
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Ime'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Prezime'),
              ),
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
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: dobController,
                decoration:
                    const InputDecoration(labelText: 'Datum rođenja (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              DropdownButtonFormField<String>(
                value: selectedGender.value,
                items: const [
                  DropdownMenuItem(value: 'muško', child: Text('Muško')),
                  DropdownMenuItem(value: 'žensko', child: Text('Žensko')),
                ],
                onChanged: (value) => selectedGender.value = value ?? 'muško',
                decoration: const InputDecoration(labelText: 'Spol'),
              ),
              const SizedBox(height: 32),
              isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: register,
                      child: const Text('Registruj se'),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Imaš račun? Prijavi se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
