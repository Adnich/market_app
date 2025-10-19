import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_app/src/dependencies.dart';
import 'package:market_app/src/features/product/domain/models/product.dart';
import 'package:market_app/src/features/data/repositories/product_repository.dart';

class AddOrEditProductScreen extends HookWidget {
  final String? productId;
  final Map<String, dynamic>? existingData;

  const AddOrEditProductScreen({super.key, this.productId, this.existingData});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final priceController = useTextEditingController();
    final descriptionController = useTextEditingController();

    final pickedImage = useState<File?>(null);
    final imageUrl = useState<String?>(null);
    final isLoading = useState(false);

    final storage = getIt<FirebaseStorage>();
    final picker = getIt<ImagePicker>();
    final repository = getIt<ProductRepository>();

    useEffect(() {
      if (existingData != null) {
        nameController.text = existingData!['name'] ?? '';
        priceController.text = existingData!['price']?.toString() ?? '';
        descriptionController.text = existingData!['description'] ?? '';
        imageUrl.value = existingData!['imageUrl'];
      }
      return null;
    }, []);

    Future<void> pickImage() async {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        pickedImage.value = File(picked.path);
      }
    }

    Future<String?> uploadImage(String productId) async {
      if (pickedImage.value == null) return imageUrl.value;
      final ref = storage.ref().child('product_images').child('$productId.jpg');
      await ref.putFile(pickedImage.value!);
      return await ref.getDownloadURL();
    }

    Future<void> saveProduct() async {
      if (!formKey.currentState!.validate()) return;
      debugPrint(' Počinjem spremanje proizvoda...');

      isLoading.value = true;

      final productData = Product(
        id: productId ?? '',
        name: nameController.text.trim(),
        price: double.tryParse(priceController.text.trim()) ?? 0,
        description: descriptionController.text.trim(),
        imageUrl: imageUrl.value,
        available: true,
        createdAt: Timestamp.now(),
      );
      debugPrint(' Spremam novi proizvod u Firestore...');

      try {
        String id = productId ?? '';

        if (productId == null) {
          id = await repository.addProduct(productData);
          final newImageUrl = await uploadImage(id);
          if (newImageUrl != null) {
            await repository.updateProduct(
              id,
              productData.copyWith(imageUrl: newImageUrl),
            );
          }
        } else {
          final newImageUrl = await uploadImage(productId!);
          await repository.updateProduct(
            productId!,
            productData.copyWith(
              imageUrl: newImageUrl ?? imageUrl.value,
            ),
          );
        }

        if (context.mounted) context.pop();
      } on FirebaseException catch (e) {
        String message;
        switch (e.code) {
          case 'permission-denied':
            message = 'Nemate dozvolu za ovu akciju.';
            break;
          case 'unavailable':
            message = 'Usluga trenutno nije dostupna. Pokušajte kasnije.';
            break;
          case 'unauthenticated':
            message = 'Morate biti prijavljeni da biste izvršili ovu akciju.';
            break;
          default:
            message = 'Došlo je do greške prilikom spremanja proizvoda.';
        }

        debugPrint('FirebaseException [saveProduct]: ${e.code} - ${e.message}');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));

        rethrow; // ✅ propagira FirebaseException
      } catch (e, stackTrace) {
        debugPrint('Greška u saveProduct(): $e');
        debugPrint('Neočekivana greška: $e');
        debugPrintStack(stackTrace: stackTrace);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Došlo je do neočekivane greške.')),
        );

        rethrow; // ✅ propagira sve ostale greške
      } finally {
        isLoading.value = false; // ✅ sigurno se izvršava uvijek
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(productId == null ? 'Dodaj proizvod' : 'Izmijeni proizvod'),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: pickedImage.value != null
                          ? Image.file(pickedImage.value!, height: 150)
                          : imageUrl.value != null
                              ? Image.network(imageUrl.value!, height: 150)
                              : Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.add_a_photo, size: 50),
                                ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Naziv proizvoda'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Unesite naziv'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priceController,
                      decoration:
                          const InputDecoration(labelText: 'Cijena (KM)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final price = double.tryParse(value ?? '');
                        if (price == null || price <= 0) {
                          return 'Unesite validnu cijenu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Opis'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: saveProduct,
                      child: Text(productId == null
                          ? 'Dodaj'
                          : 'Spasi izmjene'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
