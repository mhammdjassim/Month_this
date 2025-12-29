import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../pocketbase_instance.dart'; // استيراد مثيل PocketBase

class AuthProvider with ChangeNotifier {
  String? _userId;
  
  // التحقق مما إذا كان المستخدم مسجلاً دخوله من خلال PocketBase
  bool get isLoggedIn => pb.authStore.isValid;
  String? get userId => pb.authStore.model?.id;

  // دالة تسجيل الدخول الفعلية
  Future<void> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
      notifyListeners();
    } catch (e) {
      // يمكنك هنا معالجة أخطاء تسجيل الدخول (مثلاً كلمة مرور خاطئة)
      print('Login Error: $e');
      rethrow; // إعادة رمي الخطأ ليتم التعامل معه في الواجهة
    }
  }

  // دالة تسجيل الخروج
  Future<void> logout() async {
    pb.authStore.clear();
    notifyListeners();
  }

  // دالة لإنشاء حساب جديد
  Future<void> signup(String email, String password, String name) async {
    try {
      await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password, // تأكيد كلمة المرور مطلوب
        'name': name, // إضافة اسم المستخدم
      });
      // بعد إنشاء الحساب، قم بتسجيل الدخول مباشرة
      await login(email, password);
    } catch (e) {
      print('Signup Error: $e');
      rethrow;
    }
  }
}
