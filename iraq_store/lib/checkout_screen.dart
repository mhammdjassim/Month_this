import 'package:flutter/material.dart';
import 'package:iraq_store/models/order_model.dart';
import 'package:iraq_store/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:iraq_store/providers/cart_provider.dart';
import 'package:iraq_store/pocketbase_instance.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGovernorate;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> _governorates = [
    'كربلاء', 'بغداد', 'ديالى', 'واسط', 'الموصل', 'أربيل', 'دهوك',
    'السليمانية', 'الأنبار', 'ميسان', 'البصرة', 'حلبجة', 'صلاح الدين',
    'بابل', 'النجف', 'القادسية', 'المثنى', 'ذي قار'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();

    final order = OrderModel(
      userId: auth.isLoggedIn ? auth.userId : null,
      customerName: _nameController.text,
      governorate: _selectedGovernorate!,
      address: _addressController.text,
      phoneNumber: _phoneController.text,
      items: cart.items.values.toList(), 
      totalAmount: cart.totalAmount,
      created: DateTime.now(),
    );

    try {
      await pb.collection('orders').create(body: order.toJson());

      cart.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلبك بنجاح!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ملخص الطلب
              const Text('ملخص الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المجموع الكلي', style: TextStyle(fontSize: 16)),
                      Text(
                        '${cart.totalAmount.toStringAsFixed(0)} د.ع',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. معلومات الشحن
              const Text('معلومات الشحن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'المحافظة',
                  border: OutlineInputBorder(),
                ),
                value: _selectedGovernorate,
                hint: const Text('اختر محافظتك'),
                isExpanded: true,
                items: _governorates.map((String governorate) {
                  return DropdownMenuItem<String>(
                    value: governorate,
                    child: Text(governorate),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGovernorate = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'الرجاء اختيار المحافظة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'العنوان بالتفصيل', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العنوان';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. طريقة الدفع
              const Text('طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: const Icon(Icons.delivery_dining, color: Colors.green),
                  title: const Text('الدفع عند الاستلام'),
                  trailing: Radio(value: true, groupValue: true, onChanged: (val){}),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
              : const Text('تأكيد الطلب', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
