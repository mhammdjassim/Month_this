import 'package:iraq_store/models/banner_model.dart';

import '../models/product_model.dart';
import '../models/category_model.dart';
import '../pocketbase_instance.dart';

class ProductService {

  // دالة لجلب البانرات الإعلانية
  Future<List<BannerModel>> getBanners() async {
    try {
      final records = await pb.collection('banners').getFullList(sort: '-created');
      return records.map((record) => BannerModel.fromRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load banners from PocketBase: $e');
    }
  }

  // دالة لجلب جميع المنتجات
  Future<List<Product>> getProducts() async {
    try {
      final records = await pb.collection('products').getFullList(
            batch: 200,
            sort: '-created',
          );
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
      return records.map((record) => Product.fromPocketBaseRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load best sellers from PocketBase: $e');
    }
  }

  // دالة لجلب المنتجات الحرفية العراقية
  Future<List<Product>> getIraqiCrafts() async {
    try {
      // البحث عن الفئة بالاسم المحدد
      final categoryRecords = await pb.collection('categories').getList(
            page: 1,
            perPage: 1,
            filter: 'name = "Authentic Iraqi Crafts"',
          );

      // إذا لم يتم العثور على الفئة، يتم إرجاع قائمة فارغة لتجنب تعطل التطبيق
      if (categoryRecords.items.isEmpty) {
        print("Warning: Category 'Authentic Iraqi Crafts' not found. Returning empty list.");
        return [];
      }

      final categoryId = categoryRecords.items.first.id;

      final records = await pb.collection('products').getFullList(
            batch: 200,
            filter: 'categoryid = "$categoryId"',
          );
      return records.map((record) => Product.fromPocketBaseRecord(record)).toList();
    } catch (e) {
      print('Error in getIraqiCrafts: $e');
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
      return records.map((record) => Category.fromPocketBaseRecord(record)).toList();
    } catch (e) {
      throw Exception('Failed to load categories from PocketBase: $e');
    }
  }
}
