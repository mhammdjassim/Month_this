// lib/models/category_model.dart

import 'package:pocketbase/pocketbase.dart'; // <--- أضف هذا الاستيراد
import '../pocketbase_instance.dart';     // <--- أضف هذا الاستيراد للوصول إلى `pb`

class Category {
  final String id;
  final String name;
  final String iconUrl;

  Category({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  // (يمكنك الإبقاء على fromJson أو إزالته)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
    );
  }

  // <--- هنا تبدأ بإضافة الـ factory constructor الجديد
  factory Category.fromPocketBaseRecord(RecordModel record) {
    final json = record.data;
    return Category(
      id: record.id,
      name: json['name'] as String,
      // بناء الـ URL للأيقونة باستخدام pb.getFileUrl
      // تأكد أن 'icon' هو اسم حقل الأيقونة في PocketBase
      iconUrl: pb.getFileUrl(record, json['iconUrl'] as String).toString(),
    );
  }
  // <--- هنا ينتهي الـ factory constructor الجديد

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
    };
  }
}