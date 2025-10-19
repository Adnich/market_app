import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/injection.dart';

class ProfileScreen extends HookWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<FirebaseAuth>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Korisnik nije prijavljen.")),
      );
    }

    final uid = user.uid;

    final name = useState<String?>(null);
    final email = useState<String?>(null);
    final phone = useState<String?>(null);
    final dateOfBirth = useState<String?>(null);
    final gender = useState<String?>(null);
    final imageUrl = useState<String?>(null);
    final isLoading = useState(true);

    useEffect(() {
      Future<void> loadUserData() async {
        try {
          debugPrint('Pokušavam učitati korisnika UID: $uid');
          final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

          if (!doc.exists) {
            debugPrint(' Dokument za UID $uid ne postoji.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nema podataka o korisniku.')),
            );
            return;
          }

          final data = doc.data();
          debugPrint('Dokument pronađen: $data');

          name.value = data?['firstName'] ?? data?['name'] ?? '-';
          email.value = data?['email'] ?? '-';
          phone.value = data?['phone'] ?? '-';
          dateOfBirth.value = data?['dateOfBirth'] ?? '-';
          gender.value = data?['gender'] ?? '-';
          imageUrl.value = data?['photoUrl'] ?? '';
        } catch (e, stack) {
          debugPrint('Greška [loadUserData]: $e');
          debugPrintStack(stackTrace: stack);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Greška: $e')),
          );
        } finally {
          isLoading.value = false;
        }
      }

      loadUserData();
      return null;
    }, []);

    Future<void> pickAndUploadImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);
      try {
        await FirebaseStorage.instance.ref('profile_pictures/$uid.jpg').putFile(file);
        final downloadUrl = await FirebaseStorage.instance
            .ref('profile_pictures/$uid.jpg')
            .getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'photoUrl': downloadUrl,
        });

        imageUrl.value = downloadUrl;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slika profila je uspješno ažurirana')),
        );
      } catch (e, stack) {
        debugPrint('Greška [pickAndUploadImage]: $e');
        debugPrintStack(stackTrace: stack);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greška pri slanju slike.')),
        );
      }
    }

    Future<void> logout() async {
      final auth = getIt<FirebaseAuth>();
      await auth.signOut();
      if (context.mounted) context.go('/login');
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: imageUrl.value != null && imageUrl.value!.isNotEmpty
                          ? NetworkImage(imageUrl.value!)
                          : null,
                      child: imageUrl.value == null || imageUrl.value!.isEmpty
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildProfileRow("Ime", name.value),
                  _buildProfileRow("Email", email.value),
                  _buildProfileRow("Telefon", phone.value),
                  _buildProfileRow("Datum rođenja", dateOfBirth.value),
                  _buildProfileRow("Spol", gender.value),

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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "-", softWrap: true)),
        ],
      ),
    );
  }
}
