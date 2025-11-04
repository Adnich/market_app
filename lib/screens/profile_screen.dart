import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/injection.dart';
import 'package:market_app/src/features/user/domain/models/app_user.dart';
import 'package:market_app/src/features/user/data/repositories/user_repository.dart'; // ✅ Dodano

class ProfileScreen extends HookWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<FirebaseAuth>();
    final firestore = getIt<FirebaseFirestore>();
    final storage = getIt<FirebaseStorage>();
    final picker = getIt<ImagePicker>();
    final userRepo = getIt<UserRepository>(); // ✅ Dodano

    final appUser = useValueListenable(userRepo.currentUser); // ✅ Reactive korisnik

    if (appUser == null) {
      return const Scaffold(
        body: Center(child: Text("Korisnik nije prijavljen.")),
      );
    }

    final uid = auth.currentUser?.uid;

    Future<void> pickAndUploadImage() async {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null || uid == null) return;

      final file = File(picked.path);
      try {
        await storage.ref('profile_pictures/$uid.jpg').putFile(file);
        final downloadUrl =
            await storage.ref('profile_pictures/$uid.jpg').getDownloadURL();

        await firestore.collection('users').doc(uid).update({
          'photoUrl': downloadUrl,
        });

        // ✅ Ažuriraj korisnika u memoriji
        await userRepo.loadUser();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Slika profila je uspješno ažurirana')),
          );
        }
      } catch (e, stack) {
        debugPrint('Greška [pickAndUploadImage]: $e');
        debugPrintStack(stackTrace: stack);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Greška pri slanju slike.')),
          );
        }
      }
    }

    Future<void> logout() async {
      await userRepo.signOut(); // ✅ koristi UserRepository
      if (context.mounted) context.go('/login');
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickAndUploadImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: appUser.photoUrl != null &&
                        appUser.photoUrl!.isNotEmpty
                    ? NetworkImage(appUser.photoUrl!)
                    : null,
                child: appUser.photoUrl == null || appUser.photoUrl!.isEmpty
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            _buildProfileRow("Ime",
                '${appUser.firstName ?? '-'} ${appUser.lastName ?? ''}'),
            _buildProfileRow("Email", appUser.email ?? '-'),
            _buildProfileRow("Telefon", appUser.phone ?? '-'),
            _buildProfileRow("Datum rođenja", appUser.dateOfBirth ?? '-'),
            _buildProfileRow("Spol", appUser.gender ?? '-'),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit),
              label: const Text("Uredi profil"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout),
              label: const Text("Odjavi se"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? "-", softWrap: true),
          ),
        ],
      ),
    );
  }
}
