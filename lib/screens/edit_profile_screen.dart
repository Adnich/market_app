import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _dateOfBirthController.text = data['dateOfBirth'] ?? '';
          _selectedGender = data['gender'];
        });
      }
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException [loadUserData]: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška pri učitavanju podataka. Pokušajte ponovo.'),
          ),
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Neuhvaćena greška [loadUserData]: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Došlo je do neočekivane greške.')),
        );
      }
      rethrow;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dateOfBirth': _dateOfBirthController.text.trim(),
        'gender': _selectedGender ?? '',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil uspješno ažuriran")),
        );
        context.pop();
      }

    } on FirebaseException catch (e) {
      String message;
      switch (e.code) {
        case 'permission-denied':
          message = 'Nemate dozvolu za izmjenu podataka.';
          break;
        case 'unavailable':
          message = 'Usluga trenutno nije dostupna. Pokušajte kasnije.';
          break;
        default:
          message = 'Greška pri spremanju podataka.';
      }

      debugPrint('FirebaseException [saveChanges]: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      rethrow;

    } catch (e, stackTrace) {
      debugPrint('Neuhvaćena greška [saveChanges]: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Došlo je do neočekivane greške.')),
        );
      }
      rethrow;

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uredi profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Ime'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Unesite ime' : null,
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Prezime'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Unesite prezime'
                          : null,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Broj telefona'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextFormField(
                      controller: _dateOfBirthController,
                      decoration:
                          const InputDecoration(labelText: 'Datum rođenja'),
                      keyboardType: TextInputType.datetime,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: (_selectedGender == 'muško' ||
                              _selectedGender == 'žensko' ||
                              _selectedGender == 'drugo')
                          ? _selectedGender
                          : null,
                      decoration: const InputDecoration(labelText: 'Spol'),
                      items: const [
                        DropdownMenuItem(
                          value: 'muško',
                          child: Text('Muško'),
                        ),
                        DropdownMenuItem(
                          value: 'žensko',
                          child: Text('Žensko'),
                        ),
                        DropdownMenuItem(
                          value: 'drugo',
                          child: Text('Drugo'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedGender = value);
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text("Spremi promjene"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
