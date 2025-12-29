import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

// كلاس لتمثيل المنتج داخل السلة (مع الكمية)
class CartItem {
  final String id; // ID المنتج
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  // عدد المنتجات الفريدة في السلة
  int get itemCount {
    return _items.length;
  }

  // السعر الإجمالي لكل المنتجات في السلة
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // إضافة منتج إلى السلة
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // إذا كان المنتج موجوداً، قم بزيادة الكمية فقط
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // إذا كان المنتج جديداً، قم بإضافته للسلة
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); // إعلام الواجهة بالتغييرات
  }

  // حذف منتج من السلة
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // مسح جميع المنتجات من السلة
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
