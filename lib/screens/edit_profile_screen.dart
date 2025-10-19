import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/injection.dart';
import 'package:market_app/src/features/user/data/repositories/user_repository.dart';

class EditProfileScreen extends HookWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final dateOfBirthController = useTextEditingController();

    final selectedGender = useState<String?>(null);
    final isLoading = useState(false);

    final userRepo = getIt<UserRepository>();
    final uid = userRepo.uid!;

    useEffect(() {
      Future<void> loadUserData() async {
        try {
          final doc = await userRepo.getUserDoc();

          if (doc.exists) {
            final data = doc.data()!;
            firstNameController.text = data['firstName'] ?? '';
            lastNameController.text = data['lastName'] ?? '';
            phoneController.text = data['phone'] ?? '';
            dateOfBirthController.text = data['dateOfBirth'] ?? '';
            selectedGender.value = data['gender'];
          }
        } on FirebaseException catch (e) {
          debugPrint('FirebaseException [loadUserData]: ${e.code} - ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Greška pri učitavanju podataka. Pokušajte ponovo.')),
          );
          rethrow; 
        } catch (e, stackTrace) {
          debugPrint('Neuhvaćena greška [loadUserData]: $e');
          debugPrintStack(stackTrace: stackTrace);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Došlo je do neočekivane greške.')),
          );
          rethrow; 
        }
      }

      loadUserData();
      return null;
    }, []);

    Future<void> saveChanges() async {
      if (!formKey.currentState!.validate()) return;
      isLoading.value = true;

      try {
        await userRepo
            .getUserDoc()
            .then((_) async {
          await userRepo.refreshUser();
          await userRepo.firestore
              .collection('users')
              .doc(uid)
              .update({
            'firstName': firstNameController.text.trim(),
            'lastName': lastNameController.text.trim(),
            'phone': phoneController.text.trim(),
            'dateOfBirth': dateOfBirthController.text.trim(),
            'gender': selectedGender.value ?? '',
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil uspješno ažuriran")),
        );
        context.pop();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        rethrow; 
      } catch (e, stackTrace) {
        debugPrint('Neuhvaćena greška [saveChanges]: $e');
        debugPrintStack(stackTrace: stackTrace);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Došlo je do neočekivane greške.')),
        );
        rethrow; 
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Uredi profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(labelText: 'Ime'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Unesite ime' : null,
                    ),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Prezime'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Unesite prezime' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Broj telefona'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextFormField(
                      controller: dateOfBirthController,
                      decoration: const InputDecoration(labelText: 'Datum rođenja'),
                      keyboardType: TextInputType.datetime,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedGender.value,
                      decoration: const InputDecoration(labelText: 'Spol'),
                      items: const [
                        DropdownMenuItem(value: 'muško', child: Text('Muško')),
                        DropdownMenuItem(value: 'žensko', child: Text('Žensko')),
                        DropdownMenuItem(value: 'drugo', child: Text('Drugo')),
                      ],
                      onChanged: (value) => selectedGender.value = value,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: saveChanges,
                      child: const Text("Spremi promjene"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
