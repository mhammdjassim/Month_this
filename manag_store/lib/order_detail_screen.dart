import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'main.dart'; // To get the 'pb' instance

class OrderDetailScreen extends StatefulWidget {
  final RecordModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _currentStatus;
  final List<String> _statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  
  final Map<String, String> _statusTranslations = {
    'pending': 'قيد الانتظار',
    'processing': 'قيد التجهيز',
    'shipped': 'تم الشحن',
    'delivered': 'تم التسليم',
    'cancelled': 'ملغي',
  };

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.data['status'] ?? 'pending';
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      await pb.collection('orders').update(widget.order.id, body: {'status': newStatus});
      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث حالة الطلب إلى ${_statusTranslations[newStatus]!}'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('Failed to update order status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('فشل تحديث حالة الطلب.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.order.data['customer_name'] ?? 'زبون غير معروف';
    final totalAmount = widget.order.data['total_amount'] ?? 0;
    final creationDate = DateTime.parse(widget.order.created);
    final governorate = widget.order.data['governorate'] ?? 'غير محدد';
    final address = widget.order.data['address'] ?? 'لا يوجد عنوان';
    final items = (widget.order.data['items'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب: ${widget.order.id.substring(0, 7)}...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailCard('معلومات العميل', customerName, Icons.person),
            _buildDetailCard('العنوان', '$governorate, $address', Icons.location_on),
            _buildDetailCard('المبلغ الإجمالي', '\$${totalAmount.toStringAsFixed(2)}', Icons.monetization_on),
            _buildDetailCard('تاريخ الطلب', '${creationDate.toLocal()}'.split('.')[0], Icons.calendar_today),
            const SizedBox(height: 20),
            _buildOrderStatusDropdown(),
            const SizedBox(height: 20),
            const Text('المنتجات المطلوبة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildOrderItemsList(items),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تغيير حالة الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentStatus,
              isExpanded: true,
              items: _statuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(_statusTranslations[status] ?? status, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateOrderStatus(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsList(List<dynamic> items) {
    if (items.isEmpty) {
      return const Text('لا توجد منتجات في هذا الطلب.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        // The product details are already in the item data, so we can display them directly.
        final productName = item['product_name'] ?? 'منتج غير معروف';
        final quantity = item['quantity'] ?? 1;
        final price = item['price'] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.fastfood), // You can replace this with a product image later
            title: Text(productName),
            subtitle: Text('الكمية: $quantity'),
            trailing: Text('\$${(price * quantity).toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
