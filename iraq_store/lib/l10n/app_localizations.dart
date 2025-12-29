import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'main_title': 'Al-Jawhara',
      'menu': 'Menu',
      'home': 'Home',
      'categories': 'Categories',
      'favorites': 'Favorites',
      'my_account': 'My Account',
      'change_language': 'Change Language',
      'search_now': 'Search Now',
      'shop_now': 'Shop Now',
      'new_arrivals': 'New Arrivals',
      'daily_deals': 'Daily Deals',
      'best_sellers': 'Best Sellers',
      'iraqi_crafts': 'Authentic Iraqi Crafts',
      'view_all': 'View All',
    },
    'ar': {
      'main_title': 'الجوهرة',
      'menu': 'القائمة',
      'home': 'الرئيسية',
      'categories': 'الأقسام',
      'favorites': 'المفضلة',
      'my_account': 'حسابي',
      'change_language': 'تغيير اللغة',
      'search_now': 'ابحث الآن',
      'shop_now': 'تسوق الآن',
      'new_arrivals': 'وصل حديثاً',
      'daily_deals': 'عروض اليوم',
      'best_sellers': 'الأكثر مبيعاً',
      'iraqi_crafts': 'حرف عراقية أصيلة',
      'view_all': 'عرض الكل',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
