import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController=TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'muško';
  
  Future<void> _register() async {
  final lastName=_lastNameController.text.trim();
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final phone=_phoneController.text.trim();
  final dateOfBirth=_dobController.text.trim();
  final gender=_selectedGender;
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'firstName': name,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'createdAt': Timestamp.now(),
    });

    await FirebaseAuth.instance.signOut();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registracija uspješna! Prijavite se.')),
      );
      context.go('/login');
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Greška: ${e.toString()}')),
    );
  }
}


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
             decoration: const InputDecoration(labelText: 'Ime'),
            ),
            TextField(
             controller: _lastNameController,
             decoration: const InputDecoration(labelText: 'Prezime'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Lozinka'),
              obscureText: true,
            ),
            TextField(
  controller: _phoneController,
  decoration: const InputDecoration(labelText: 'Telefon'),
),

TextField(
  controller: _dobController,
  decoration: const InputDecoration(labelText: 'Datum rođenja (YYYY-MM-DD)'),
),


DropdownButtonFormField<String>(
  initialValue: _selectedGender,
  items: const [
    DropdownMenuItem(value: 'muško', child: Text('Muško')),
    DropdownMenuItem(value: 'žensko', child: Text('Žensko')),
  ],
  onChanged: (value) {
    setState(() {
      _selectedGender = value!;
    });
  },
  decoration: const InputDecoration(labelText: 'Spol'),
),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _register,
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
    );
  }
}
