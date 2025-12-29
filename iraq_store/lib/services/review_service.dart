import '../pocketbase_instance.dart';
import '../models/review_model.dart';

class ReviewService {
  // جلب التقييمات لمنتج معين
  Future<List<Review>> getReviewsForProduct(String productId) async {
    try {
      final records = await pb.collection('reviews').getFullList(
            filter: 'product = "$productId"',
            expand: 'user', // جلب بيانات المستخدم المرتبط بالتقييم
            sort: '-created',
          );
      return records.map((record) => Review.fromRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // إضافة تقييم جديد
  Future<void> addReview({
    required String productId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      final body = <String, dynamic>{
        "product": productId,
        "user": userId,
        "rating": rating,
        "comment": comment,
      };
      await pb.collection('reviews').create(body: body);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }
}
