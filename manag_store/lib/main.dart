import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'order_detail_screen.dart'; // Import the new screen

// CORRECTED: Use 10.0.2.2 for Android Emulator
final pb = PocketBase('https://area-components-diego-query.trycloudflare.com');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لوحة التحكم',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _ordersCount = 0;
  int _productsCount = 0;
  String _mostRequestedRegion = 'N/A';
  bool _isLoading = true;
  List<RecordModel> _recentOrders = [];

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
    _fetchData();
    _subscribeToOrders();
  }

  @override
  void dispose() {
    pb.collection('orders').unsubscribe();
    super.dispose();
  }

  Future<void> _subscribeToOrders() async {
    try {
      await pb.collection('orders').subscribe('*', (e) {
        if (!mounted) return;
        print('Real-time event received: ${e.action}');

        setState(() {
          if (e.action == 'create') {
            _recentOrders.insert(0, e.record!);
            _ordersCount++;
          } else if (e.action == 'update') {
            final index = _recentOrders.indexWhere((r) => r.id == e.record!.id);
            if (index != -1) {
              _recentOrders[index] = e.record!;
            }
          } else if (e.action == 'delete') {
            _recentOrders.removeWhere((r) => r.id == e.record!.id);
            _ordersCount--;
          }
        });
      });
    } catch (e) {
      print('Failed to subscribe to orders collection: $e');
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final orders = await pb.collection('orders').getFullList(sort: '-created');
      final products = await pb.collection('products').getFullList(sort: '-created');

      final regionCounts = <String, int>{};
      for (final order in orders) {
        final region = order.data['governorate'] as String?;
        if (region != null && region.isNotEmpty) {
          regionCounts[region] = (regionCounts[region] ?? 0) + 1;
        }
      }

      String mostRequestedRegion = 'N/A';
      if (regionCounts.isNotEmpty) {
        mostRequestedRegion = regionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }
      
      if (mounted) {
        setState(() {
          _ordersCount = orders.length;
          _productsCount = products.length;
          _mostRequestedRegion = mostRequestedRegion;
          _recentOrders = orders;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المتجر'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          _buildDashboardCard('إجمالي الطلبات', '$_ordersCount', Icons.shopping_cart, Colors.orange),
                          _buildDashboardCard('إجمالي المنتجات', '$_productsCount', Icons.store, Colors.green),
                          _buildDashboardCard('المنطقة الأكثر طلباً', _mostRequestedRegion, Icons.location_city, Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('آخر الطلبات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  _recentOrders.isEmpty
                      ? const SliverFillRemaining(child: Center(child: Text('لا توجد طلبات حديثة.')))
                      : SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                          final order = _recentOrders[index];
                          final customerName = order.data['customer_name'] ?? 'زبون غير معروف';
                          final totalAmount = order.data['total_amount'] ?? 0;
                          final status = order.data['status'] ?? 'pending';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: Icon(Icons.receipt_long, color: _getStatusColor(status), size: 35),
                              title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('الحالة: ${_statusTranslations[status] ?? status}', style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                              trailing: Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)),
                                );
                              },
                            ),
                          );
                        }, childCount: _recentOrders.length)),
                ],
              ),
            ),
    );
  }

  Widget _buildDashboardCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(colors: [color.withOpacity(0.7), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
