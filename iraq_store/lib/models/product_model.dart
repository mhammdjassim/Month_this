import 'package:pocketbase/pocketbase.dart';
import '../pocketbase_instance.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final String categoryId;
  final double rating;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.categoryId,
    required this.rating,
    required this.stock,
  });

  factory Product.fromPocketBaseRecord(RecordModel record) {
    final json = record.data;

    // دالة مساعدة للتعامل مع الحقول التي قد تكون قائمة (مثل حقول الملفات والعلاقات)
    String _getFirstFromListOrString(dynamic data) {
      if (data is List && data.isNotEmpty) {
        return data.first as String? ?? '';
      }
      if (data is String) {
        return data;
      }
      return '';
    }

    return Product(
      id: record.id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? '',
      // التصحيح النهائي: استخدام اسم الحقل الصحيح 'imageUrl' من المخطط
      imageUrl: pb.getFileUrl(record, _getFirstFromListOrString(json['imageUrl'])).toString(),
      // التصحيح النهائي: استخدام اسم الحقل الصحيح 'categoryId' من المخطط
      categoryId: _getFirstFromListOrString(json['categoryId']),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      stock: json['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'rating': rating,
      'stock': stock,
    };
  }
}
