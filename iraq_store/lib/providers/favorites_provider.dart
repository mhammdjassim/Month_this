import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favoriteItems = [];

  List<Product> get favoriteItems => _favoriteItems;

  // التحقق مما إذا كان المنتج في المفضلة
  bool isFavorite(String productId) {
    return _favoriteItems.any((product) => product.id == productId);
  }

  // إضافة أو حذف المنتج من المفضلة
  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      _favoriteItems.removeWhere((item) => item.id == product.id);
    } else {
      _favoriteItems.add(product);
    }
    notifyListeners();
  }
}
