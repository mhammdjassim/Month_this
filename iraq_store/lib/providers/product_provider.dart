import 'package:flutter/material.dart';
import 'package:iraq_store/models/banner_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<BannerModel> _banners = [];
  List<Product> _newArrivals = [];
  List<Product> _dailyDeals = [];
  List<Product> _bestSellers = [];
  List<Product> _iraqiCrafts = [];
  List<Category> _categories = [];
  
  List<Product> _allProducts = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<BannerModel> get banners => _banners;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get dailyDeals => _dailyDeals;
  List<Product> get bestSellers => _bestSellers;
  List<Product> get iraqiCrafts => _iraqiCrafts;
  List<Category> get categories => _categories;
  List<Product> get allProducts => _allProducts;
  
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
        _productService.getBanners(),
        _productService.getProducts(),
        _productService.getDailyDeals(),
        _productService.getBestSellers(),
        _productService.getIraqiCrafts(),
        _productService.getCategories(),
      ]);

      _banners = results[0] as List<BannerModel>;
      _newArrivals = results[1] as List<Product>;
      _dailyDeals = results[2] as List<Product>;
      _bestSellers = results[3] as List<Product>;
      _iraqiCrafts = results[4] as List<Product>;
      _categories = results[5] as List<Category>;
      
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
