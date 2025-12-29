import 'package:pocketbase/pocketbase.dart';

class Review {
  final String id;
  final String comment;
  final int rating;
  final String userId;
  final String username;

  Review({
    required this.id,
    required this.comment,
    required this.rating,
    required this.userId,
    required this.username,
  });

  factory Review.fromRecord(RecordModel record) {
    // للوصول لاسم المستخدم، يجب أن نطلب من السيرفر "توسيع" العلاقة
    // وهذا ما سنفعله عند جلب البيانات
    final user = record.expand['user']?.first;
    
    return Review(
      id: record.id,
      comment: record.data['comment'] ?? '',
      rating: (record.data['rating'] as num).toInt(),
      userId: record.data['user'] ?? '',
      username: user?.data['name'] ?? 'مستخدم', // جلب اسم المستخدم من العلاقة الموسعة
    );
  }
}
