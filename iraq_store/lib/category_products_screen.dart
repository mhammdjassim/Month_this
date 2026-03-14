import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/product_model.dart';
import 'providers/product_provider.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // استخدام Consumer للوصول إلى البيانات وإعادة بناء الواجهة عند التغيير
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // فلترة المنتجات بناءً على معرف القسم
          final products = productProvider.allProducts
              .where((p) => p.categoryId == categoryId)
              .toList();

          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (products.isEmpty) {
            return const Center(
              child: Text('لا توجد منتجات في هذا القسم حالياً.'),
            );
          }

          // عرض المنتجات في شبكة
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // عمودين
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7, // تعديل النسبة لتناسب البطاقة بشكل أفضل
            ),
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final product = products[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            product.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.currency} ${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
