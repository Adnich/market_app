import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddOrEditProductScreen extends StatefulWidget {
  final String? productId; 
  final Map<String, dynamic>? existingData;

  const AddOrEditProductScreen({super.key, this.productId, this.existingData});

  @override
  State<AddOrEditProductScreen> createState() => _AddOrEditProductScreenState();
}

class _AddOrEditProductScreenState extends State<AddOrEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _pickedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _priceController.text = widget.existingData!['price']?.toString() ?? '';
      _descriptionController.text = widget.existingData!['description'] ?? '';
      _imageUrl = widget.existingData!['imageUrl'];
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(String productId) async {
    if (_pickedImage == null) return _imageUrl;
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images')
        .child('$productId.jpg');

    await ref.putFile(_pickedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProduct() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  final data = {
    'name': _nameController.text.trim(),
    'price': double.tryParse(_priceController.text.trim()) ?? 0,
    'description': _descriptionController.text.trim(),
    'createdAt': Timestamp.now(),
  };

  try {
    if (widget.productId == null) {
      final docRef = await FirebaseFirestore.instance.collection('products').add(data);
      final imageUrl = await _uploadImage(docRef.id);
      await docRef.update({'imageUrl': imageUrl});
    } else {
      final imageUrl = await _uploadImage(widget.productId!);
      data['imageUrl'] = imageUrl ?? _imageUrl ?? '';
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId!)
          .update(data);
    }

    if (mounted) {
      context.pop();
    }

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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    rethrow; 

  } catch (e, stackTrace) {
    debugPrint('Neuhvaćena greška kod spremanja proizvoda: $e');
    debugPrintStack(stackTrace: stackTrace);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do neočekivane greške. Pokušajte ponovo.'),
        ),
      );
    }
    rethrow;
  }

  setState(() => _isLoading = false);
}


  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Dodaj proizvod' : 'Izmijeni proizvod'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _pickedImage != null
                          ? Image.file(_pickedImage!, height: 150)
                          : _imageUrl != null
                              ? Image.network(_imageUrl!, height: 150)
                              : Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.add_a_photo, size: 50),
                                ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Naziv proizvoda'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Unesite naziv' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Cijena (KM)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final price = double.tryParse(value ?? '');
                        if (price == null || price <= 0) return 'Unesite validnu cijenu';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Opis'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(widget.productId == null ? 'Dodaj' : 'Spasi izmjene'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
