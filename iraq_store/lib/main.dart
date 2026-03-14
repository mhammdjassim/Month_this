import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/locale_provider.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'favorites_screen.dart';
import 'category_products_screen.dart';
import 'all_products_screen.dart'; // استيراد الشاشة الجديدة

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Al-Jawhara',
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Cairo',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          toolbarTextStyle: TextStyle(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final hasConnection = result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi);
      if (!hasConnection) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('أنت غير متصل بالإنترنت'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // جلب البيانات عند بدء التشغيل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchHomeData().then((_) {
        // بدء المؤقت بعد جلب البيانات
        _startBannerTimer(context.read<ProductProvider>());
      });
    });
  }

  void _startBannerTimer(ProductProvider productProvider) {
    _timer?.cancel(); // إلغاء أي مؤقت موجود
    if (productProvider.banners.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        if (_currentPage < (productProvider.banners.length - 1)) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await context.read<ProductProvider>().fetchHomeData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFA),
      appBar: _buildAppBar(context, productProvider.allProducts),
      drawer: _buildDrawer(),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : productProvider.errorMessage != null
              ? _buildErrorView(productProvider.errorMessage!)
              : _buildBodyContent(productProvider, authProvider),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
            child: Text(AppLocalizations.of(context).translate('menu'), style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(AppLocalizations.of(context).translate('home')),
            onTap: () {
              _onItemTapped(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(AppLocalizations.of(context).translate('categories')),
            onTap: () {
              _onItemTapped(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(AppLocalizations.of(context).translate('favorites')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
            },
          ),
           ListTile(
            leading: const Icon(Icons.person),
            title: Text(AppLocalizations.of(context).translate('my_account')),
            onTap: () {
              _onItemTapped(3);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context).translate('change_language')),
            onTap: () {
              context.read<LocaleProvider>().toggleLocale();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(ProductProvider productProvider, AuthProvider authProvider) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(productProvider);
      case 1:
        return _buildCategoriesContent(productProvider.categories);
      case 2:
        return const CartScreen();
      case 3:
        return authProvider.isLoggedIn ? _buildProfileContent(authProvider) : const LoginScreen();
      default:
        return Center(child: Text('الصفحة قيد الإنشاء', style: TextStyle(fontSize: 18, color: Colors.grey[600])));
    }
  }

  Widget _buildHomeContent(ProductProvider productProvider) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.green,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildPageViewBanner(productProvider),
            const SizedBox(height: 20),
            _buildProductSectionHeader(AppLocalizations.of(context).translate('new_arrivals'), productProvider.newArrivals),
            _buildProductScrollList(productProvider.newArrivals),
            const SizedBox(height: 20),
            _buildProductSectionHeader(AppLocalizations.of(context).translate('daily_deals'), productProvider.dailyDeals),
            _buildProductScrollList(productProvider.dailyDeals),
            const SizedBox(height: 20),
            _buildProductSectionHeader(AppLocalizations.of(context).translate('best_sellers'), productProvider.bestSellers),
            _buildProductScrollList(productProvider.bestSellers),
            const SizedBox(height: 20),
            _buildProductSectionHeader(AppLocalizations.of(context).translate('iraqi_crafts'), productProvider.iraqiCrafts),
            _buildIraqiCraftsGrid(productProvider.iraqiCrafts),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPageViewBanner(ProductProvider productProvider) {
    final banners = productProvider.banners;

    if (banners.isEmpty) {
      return const SizedBox(height: 180, child: Center(child: Text('لا توجد إعلانات حالياً')));
    }

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.green));
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () => _onItemTapped(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context).translate('shop_now'), style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesContent(List<Category> categories) {
    if (categories.isEmpty) {
      return const Center(child: Text('لا توجد أقسام متاحة حالياً.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryProductsScreen(categoryId: category.id, categoryName: category.name),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.network(
                      category.iconUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.category, size: 30, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'مرحباً بك!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildProfileOption(Icons.shopping_bag_outlined, 'طلباتي'),
          _buildProfileOption(Icons.location_on_outlined, 'عناويني'),
          _buildProfileOption(Icons.settings_outlined, 'الإعدادات'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                authProvider.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildErrorView(String message) {
    String displayMessage = 'أنت غير متصل بالإنترنت';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, List<Product> allProducts) {
    return AppBar(
      toolbarHeight: 80,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 35,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.diamond, color: Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                showSearch(
                  context: context,
                  delegate: ProductSearchDelegate(products: allProducts),
                );
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(AppLocalizations.of(context).translate('search_now'), style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const Spacer(),
                    const Icon(Icons.filter_list, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        Consumer<FavoritesProvider>(
          builder: (ctx, favorites, _) => IconButton(
            icon: Icon(
              favorites.favoriteItems.isNotEmpty ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductSectionHeader(String title, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllProductsScreen(title: title, products: products),
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context).translate('view_all'),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductScrollList(List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('لا توجد منتجات متوفرة في هذا القسم.', style: TextStyle(color: Colors.grey)),
      );
    }
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16.0 : 8.0, right: index == products.length - 1 ? 16.0 : 0),
            child: _buildProductCard(context, product),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                product.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/placeholder.jpg',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 100, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.currency} ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(product.rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIraqiCraftsGrid(List<Product> crafts) {
    if (crafts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('لا توجد حرف عراقية متوفرة حالياً.', style: TextStyle(color: Colors.grey)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: crafts.length,
        itemBuilder: (context, index) {
          final craft = crafts[index];
          return _buildCraftItemCard(context, craft);
        },
      ),
    );
  }

  Widget _buildCraftItemCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.currency} ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context).translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.category),
          label: AppLocalizations.of(context).translate('categories'),
        ),
        BottomNavigationBarItem(
          icon: Consumer<CartProvider>(
            builder: (ctx, cart, _) => Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
          ),
          label: AppLocalizations.of(context).translate('cart'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: AppLocalizations.of(context).translate('my_account'),
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
    );
  }
}

// --- كلاس البحث ---
class ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;

  ProductSearchDelegate({required this.products});

 @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'بحث بالذكاء الاصطناعي',
        icon: const Icon(Icons.auto_awesome),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text("بحث بالذكاء الاصطناعي"),
                    content: const Text("قريباً! ستتمكن من وصف ما تتخيله لنجد لك أفضل المنتجات."),
                    actions: [
                      TextButton(
                        child: const Text("موافق"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
        },
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, '');
          } else {
            query = '';
          }
        },
      ),
    ];
  }


  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = products.where((product) => product.name.toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) {
      return const Center(child: Text('لا توجد نتائج'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported)),
          title: Text(product.name),
          subtitle: Text('${product.currency} ${product.price.toStringAsFixed(0)}'),
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
  
  @override
  String get searchFieldLabel => 'ابحث عن منتج أو صف ما تتخيله...';
}
