// lib/providers/product_provider.dart

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart'; // استيراد موديل الفئة
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _newArrivals = [];
  List<Product> _dailyDeals = [];
  List<Product> _bestSellers = [];
  List<Product> _iraqiCrafts = [];
  List<Category> _categories = [];
  
  // قائمة تجمع كل المنتجات للبحث
  List<Product> _allProducts = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Product> get newArrivals => _newArrivals;
  List<Product> get dailyDeals => _dailyDeals;
  List<Product> get bestSellers => _bestSellers;
  List<Product> get iraqiCrafts => _iraqiCrafts;
  List<Category> get categories => _categories;
  List<Product> get allProducts => _allProducts; // Getter لكل المنتجات
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _productService.getProducts(),
        _productService.getDailyDeals(),
        _productService.getBestSellers(),
        _productService.getIraqiCrafts(),
        _productService.getCategories(),
      ]);

      _newArrivals = results[0] as List<Product>;
      _dailyDeals = results[1] as List<Product>;
      _bestSellers = results[2] as List<Product>;
      _iraqiCrafts = results[3] as List<Product>;
      _categories = results[4] as List<Category>;
      
      // دمج جميع المنتجات في قائمة واحدة للبحث (تجنب التكرار باستخدام Set)
      final Set<Product> allProductsSet = {};
      allProductsSet.addAll(_newArrivals);
      allProductsSet.addAll(_dailyDeals);
      allProductsSet.addAll(_bestSellers);
      allProductsSet.addAll(_iraqiCrafts);
      _allProducts = allProductsSet.toList();

    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      print('Error fetching home data: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
