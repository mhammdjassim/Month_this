import 'package:iraq_store/models/product_model.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;

  CartItem({required this.id, required this.product, this.quantity = 1});

  // دالة لتحويل بيانات المنتج في السلة إلى JSON
  // هذه البيانات هي التي سيتم تخزينها في الطلب
  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'quantity': quantity,
      'price': product.price,
    };
  }
}
