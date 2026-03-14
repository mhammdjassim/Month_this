import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/product_model.dart';
import 'models/review_model.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart'; // استيراد مزود المفضلة
import 'services/review_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ReviewService _reviewService = ReviewService();
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = _reviewService.getReviewsForProduct(widget.product.id);
    });
  }
  
  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'سيئ';
      case 2:
        return 'مقبول';
      case 3:
        return 'جيد';
      case 4:
        return 'جيد جداً';
      case 5:
        return 'ممتاز';
      default:
        return '';
    }
  }

  void _showAddReviewSheet(BuildContext context) {
    int currentRating = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('أضف تقييمك', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setModalState(() {
                            currentRating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < currentRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 35,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      _getRatingText(currentRating),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final authProvider = context.read<AuthProvider>();
                              final userId = authProvider.userId;

                              if (userId == null) return;

                              setModalState(() {
                                isSending = true;
                              });

                              await _reviewService.addReview(
                                productId: widget.product.id,
                                userId: userId,
                                rating: currentRating,
                                comment: '', // تم حذف التعليق
                              );

                              setModalState(() {
                                isSending = false;
                              });
                              
                              Navigator.of(ctx).pop();
                              _loadReviews();
                            },
                      child: isSending
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('إرسال التقييم'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              favoritesProvider.toggleFavorite(widget.product);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: Image.network(
                widget.product.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${widget.product.currency} ${widget.product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.product.rating}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Text(
                        '(${widget.product.stock > 0 ? "متوفر" : "نفذت الكمية"})',
                        style: TextStyle(color: widget.product.stock > 0 ? Colors.green : Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text('الوصف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description.isNotEmpty
                        ? widget.product.description
                        : 'لا يوجد وصف متاح لهذا المنتج حالياً.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('التقييمات والآراء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Consumer<AuthProvider>(
                        builder: (ctx, auth, _) => auth.isLoggedIn
                            ? TextButton(
                                onPressed: () => _showAddReviewSheet(context),
                                child: const Text('أضف تقييمك'),
                              )
                            : Container(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('خطأ في تحميل التقييمات'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('لا توجد تقييمات لهذا المنتج بعد.'));
                      }

                      final reviews = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (ctx, index) {
                          final review = reviews[index];
                          return _buildReviewItem(review.username, review.rating, review.comment);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () {
            final cart = context.read<CartProvider>();
            cart.addItem(widget.product);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت إضافة المنتج إلى السلة بنجاح!')), 
            );
          },
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text('إضافة إلى السلة', style: TextStyle(fontSize: 18, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(String name, int rating, String comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(name.isNotEmpty ? name[0] : '؟'),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(comment),
            ],
          ],
        ),
      ),
    );
  }
}
