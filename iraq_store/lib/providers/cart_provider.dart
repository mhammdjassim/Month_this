import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart'; // استيراد النموذج الموحد

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
      // التعديل: الوصول إلى السعر من خلال كائن المنتج
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  // إضافة منتج إلى السلة
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // إذا كان المنتج موجوداً، قم بزيادة الكمية فقط
      _items.update(
        product.id,
        (existingCartItem) {
          existingCartItem.quantity++;
          return existingCartItem;
        },
      );
    } else {
      // إذا كان المنتج جديداً، قم بإضافته للسلة باستخدام النموذج الموحد
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: product.id, // استخدام معرف المنتج كمعرف لمنتج السلة
          product: product, // تمرير كائن المنتج بالكامل
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
