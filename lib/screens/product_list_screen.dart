import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductListScreen extends HookWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = useMemoized(() => ProductService());
    final productsFuture = useMemoized(() => productService.getProducts(), []);

    final snapshot = useFuture(productsFuture);

    return Scaffold(
      appBar: AppBar(title: const Text('Proizvodi')),
      body: snapshot.connectionState == ConnectionState.waiting
          ? const Center(child: CircularProgressIndicator())
          : snapshot.hasError
              ? Center(child: Text('Greška: ${snapshot.error}'))
              : !snapshot.hasData || snapshot.data!.isEmpty
                  ? const Center(child: Text('Nema dostupnih proizvoda.'))
                  : ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final product = snapshot.data![index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                              'Cijena: ${product.price.toStringAsFixed(2)} KM'),
                          trailing: Icon(
                            product.available
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: product.available ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
    );
  }
}
