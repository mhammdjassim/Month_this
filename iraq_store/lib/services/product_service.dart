// lib/services/product_service.dart

import '../models/product_model.dart';
import '../models/category_model.dart';
import '../pocketbase_instance.dart';

class ProductService {
  // دالة لجلب جميع المنتجات
  Future<List<Product>> getProducts() async {
    try {
      final records = await pb.collection('products').getFullList(
            batch: 200,
            sort: '-created',
          );
      // <--- هنا التعديل: استخدام fromPocketBaseRecord
      return records.map((record) => Product.fromPocketBaseRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load products from PocketBase: $e');
    }
  }

  // دالة لجلب منتجات العروض اليومية
  Future<List<Product>> getDailyDeals() async {
    try {
      final records = await pb.collection('products').getFullList(
            batch: 200,
            filter: 'is_daily_deal = true',
          );
      // <--- هنا التعديل: استخدام fromPocketBaseRecord
      return records.map((record) => Product.fromPocketBaseRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load daily deals from PocketBase: $e');
    }
  }

  // دالة لجلب المنتجات الأكثر مبيعاً
  Future<List<Product>> getBestSellers() async {
    try {
      final records = await pb.collection('products').getFullList(
            batch: 200,
            filter: 'is_best_seller = true',
          );
      // <--- هنا التعديل: استخدام fromPocketBaseRecord
      return records.map((record) => Product.fromPocketBaseRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load best sellers from PocketBase: $e');
    }
  }

  // دالة لجلب المنتجات الحرفية العراقية
  Future<List<Product>> getIraqiCrafts() async {
    try {
      final records = await pb.collection('products').getFullList(
            batch: 200,
            filter: 'category = "Authentic Iraqi Crafts"',
          );
      // <--- هنا التعديل: استخدام fromPocketBaseRecord
      return records.map((record) => Product.fromPocketBaseRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load Iraqi crafts from PocketBase: $e');
    }
  }

  // دالة لجلب جميع الفئات
  Future<List<Category>> getCategories() async {
    try {
      final records = await pb.collection('categories').getFullList(
            batch: 200,
            sort: 'name',
          );
      // <--- هنا التعديل: استخدام fromPocketBaseRecord
      return records.map((record) => Category.fromPocketBaseRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load categories from PocketBase: $e');
    }
  }
}