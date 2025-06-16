import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'AgriPoa'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Marketplace section title
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// Browse products title for buy mode
  ///
  /// In en, this message translates to:
  /// **'Browse Products'**
  String get browseProducts;

  /// My store title for sell mode
  ///
  /// In en, this message translates to:
  /// **'My Store'**
  String get myStore;

  /// Buy option in popup menu
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// Sell option in popup menu
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// Search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search products, equipment, services...'**
  String get searchProducts;

  /// Featured products section title
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get featuredProducts;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Empty state message for no listings
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noListingsYet;

  /// Empty state description for selling
  ///
  /// In en, this message translates to:
  /// **'Start selling your products and services'**
  String get startSelling;

  /// Add listing button text
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addListing;

  /// Floating action button text
  ///
  /// In en, this message translates to:
  /// **'Sell Item'**
  String get sellItem;

  /// Notifications title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Shopping cart title
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// Categories section title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Seeds category
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get seeds;

  /// Fertilizers category
  ///
  /// In en, this message translates to:
  /// **'Fertilizers'**
  String get fertilizers;

  /// Equipment category
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// Livestock category
  ///
  /// In en, this message translates to:
  /// **'Livestock'**
  String get livestock;

  /// Crops category
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get crops;

  /// Services category
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// Advanced filters title
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advancedFilters;

  /// Clear all filters button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Apply filters button
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Category filter label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Location filter label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Price range filter label
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// Distance filter label
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Rating filter label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// In stock filter label
  ///
  /// In en, this message translates to:
  /// **'In Stock Only'**
  String get inStockOnly;

  /// Sort by filter label
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// Recent sort option
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// Price low to high sort option
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// Price high to low sort option
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// Rating sort option
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating_sort;

  /// All locations filter option
  ///
  /// In en, this message translates to:
  /// **'All Locations'**
  String get allLocations;

  /// All categories filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Tanzanian Shilling currency symbol
  ///
  /// In en, this message translates to:
  /// **'TSh'**
  String get currency;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
