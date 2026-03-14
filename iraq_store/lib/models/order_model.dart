import 'package:iraq_store/models/cart_item_model.dart';

class OrderModel {
  final String? id;
  final String? userId; //  لربط الطلب بالمستخدم المسجل
  final String customerName;
  final String governorate;
  final String address;
  final String phoneNumber;
  final List<CartItem> items; // تعديل: قبول النوع الصحيح مباشرة
  final double totalAmount;
  final DateTime created;

  OrderModel({
    this.id,
    this.userId,
    required this.customerName,
    required this.governorate,
    required this.address,
    required this.phoneNumber,
    required this.items,
    required this.totalAmount,
    required this.created,
  });

  // دالة لتحويل بيانات الطلب إلى صيغة JSON لإرسالها إلى PocketBase
  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'customer_name': customerName,
      'governorate': governorate,
      'address': address,
      'phone_number': phoneNumber,
      // تحويل قائمة المنتجات إلى JSON
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': 'pending', // الحالة الافتراضية للطلب
    };
  }
}
