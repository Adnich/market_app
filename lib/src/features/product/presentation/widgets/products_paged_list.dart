import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_app/src/features/product/domain/models/product.dart';
import 'package:market_app/src/features/data/repositories/product_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:market_app/src/app_router/app_routes.dart';
import 'package:market_app/src/injection.dart';

class ProductsPagedList extends HookWidget {
  final bool isGuest;

  final Function(VoidCallback refresh)? onRefreshCallback;

  const ProductsPagedList({
    super.key,
    required this.isGuest,
    this.onRefreshCallback,
  });

  static const _pageSize = 10;

  @override
  Widget build(BuildContext context) {
    final pagingController = useMemoized(
      () => PagingController<DocumentSnapshot?, Product>(firstPageKey: null),
    );
    final repo = getIt<ProductRepository>();

    Future<void> fetchPage(DocumentSnapshot<Object?>? lastDoc) async {
      try {
        PageResult<Product> result;
        if (lastDoc == null) {
          result = await repo.getFirstPage(limit: _pageSize);
        } else {
          result = await repo.getNextPage(lastDoc: lastDoc, limit: _pageSize);
        }

        final isLastPage =
            result.lastDoc == null || result.items.length < _pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(result.items);
        } else {
          pagingController.appendPage(result.items, result.lastDoc);
        }
      } catch (e) {
        pagingController.error = e;
        rethrow; 
      }
    }

    useEffect(() {
      pagingController.addPageRequestListener(fetchPage);

      onRefreshCallback?.call(() {
        pagingController.refresh();
      });

      return pagingController.dispose;
    }, [pagingController]);

    return PagedListView<DocumentSnapshot?, Product>(
      pagingController: pagingController,
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
                  ? Image.network(
                      img,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.image_not_supported),
              title: Text(product.name),
              subtitle: Text(
                'Cijena: ${product.price.toStringAsFixed(2)} KM\nOpis: ${product.description}',
              ),
              trailing: isGuest
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.push(
                          AppRoutes.addOrEditProduct,
                          extra: {
                            'productId': product.id,
                            'existingProduct': product,
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
