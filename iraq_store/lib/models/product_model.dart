// lib/models/product_model.dart

import 'package:pocketbase/pocketbase.dart'; // <--- أضف هذا الاستيراد
import '../pocketbase_instance.dart';     // <--- أضف هذا الاستيراد للوصول إلى `pb`

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final String category;
  final double rating;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.stock,
  });

  // (يمكنك الإبقاء على fromJson إذا كنت ستستخدمه لأغراض أخرى أو إزالته إذا كان PocketBase هو مصدرك الوحيد)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] as int,
    );
  }

  // <--- هنا تبدأ بإضافة الـ factory constructor الجديد
  factory Product.fromPocketBaseRecord(RecordModel record) {
    final json = record.data;
    return Product(
      id: record.id, // جلب الـ ID مباشرة من RecordModel
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      // بناء الـ URL للصورة باستخدام pb.getFileUrl
      // تأكد أن 'image' هو اسم حقل الصورة في PocketBase
      imageUrl: pb.getFileUrl(record, json['imageUrl'] as String).toString(),
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] as int,
    );
  }
  // <--- هنا ينتهي الـ factory constructor الجديد

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'stock': stock,
    };
  }
}