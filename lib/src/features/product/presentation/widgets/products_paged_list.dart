import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_app/src/features/product/domain/models/product.dart';
import 'package:market_app/src/features/data/repositories/product_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/app_router/app_routes.dart';
import 'package:market_app/src/dependencies.dart'; // ✅ dodaj ako već nemaš
import 'package:market_app/src/injection.dart' as di;

// 🔑 Globalni key za pristup refresh funkciji iz drugih fajlova
final productsPagedListKey = GlobalKey<_ProductsPagedListState>();

class ProductsPagedList extends StatefulWidget {
  final bool isGuest; // da sakrije edit kad je gost
  const ProductsPagedList({super.key, required this.isGuest});

  @override
  State<ProductsPagedList> createState() => _ProductsPagedListState();
}

class _ProductsPagedListState extends State<ProductsPagedList> {
  static const _pageSize = 10;

  final _pagingController =
      PagingController<DocumentSnapshot?, Product>(firstPageKey: null);

  final _repo = di.getIt<ProductRepository>();
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  void refreshProducts() {
    _pagingController.refresh();
  }

  Future<void> _fetchPage(DocumentSnapshot<Object?>? lastDoc) async {
    try {
      PageResult<Product> result;
      if (lastDoc == null) {
        result = await _repo.getFirstPage(limit: _pageSize);
      } else {
        result = await _repo.getNextPage(lastDoc: lastDoc, limit: _pageSize);
      }

      final isLastPage =
          result.lastDoc == null || result.items.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(result.items);
      } else {
        _pagingController.appendPage(result.items, result.lastDoc);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<DocumentSnapshot?, Product>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Product>(
        firstPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
        newPageProgressIndicatorBuilder: (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        ),
        noItemsFoundIndicatorBuilder: (_) =>
            const Center(child: Text('Nema unesenih proizvoda.')),
        itemBuilder: (context, product, index) {
          final img = product.imageUrl;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: (img != null && img.isNotEmpty)
                  ? Image.network(img, width: 60, height: 60, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(product.name),
              subtitle: Text(
                'Cijena: ${product.price.toStringAsFixed(2)} KM\nOpis: ${product.description}',
              ),
              trailing: widget.isGuest
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.push(
                          AppRoutes.addOrEditProduct,
                          extra: {
                            'productId': product.id,
                            'existingData': product.toFirestore(),
                          },
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
