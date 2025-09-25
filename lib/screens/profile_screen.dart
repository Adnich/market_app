import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? dateOfBirth;
  String? gender;
  String? imageUrl;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          firstName = data['firstName'];
          lastName = data['lastName'];
          email = data['email'];
          phone = data['phone'];
          dateOfBirth = data['dateOfBirth'];
          gender = data['gender'];
          imageUrl = data['photoUrl']; 
        });
      }
    } catch (e) {
      print("Greška pri učitavanju korisničkih podataka: $e");
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final url = await FirebaseStorage.instance
          .ref('profile_pictures/$uid.jpg')
          .getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print('Nema slike u Storage-u ili nije učitana.');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);

      try {
       
        await FirebaseStorage.instance
            .ref('profile_pictures/$uid.jpg')
            .putFile(file);

        final downloadUrl = await FirebaseStorage.instance
            .ref('profile_pictures/$uid.jpg')
            .getDownloadURL();

       
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'photoUrl': downloadUrl,
        });

        setState(() {
          imageUrl = downloadUrl;
        });
      } catch (e) {
        print("Greška prilikom uploada slike: $e");
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            _buildProfileRow("Ime", firstName),
            _buildProfileRow("Prezime", lastName),
            _buildProfileRow("Email", email),
            _buildProfileRow("Telefon", phone),
            _buildProfileRow("Datum rođenja", dateOfBirth),
            _buildProfileRow("Spol", gender),

            const SizedBox(height: 30),
            ElevatedButton.icon(
            onPressed: () {
              context.push('/edit-profile'); 
            
            },
            icon: const Icon(Icons.edit),
            label: const Text("Uredi profil"),
          ),

            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _logout,
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
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "-", softWrap: true)),
        ],
      ),
    );
  }
}
