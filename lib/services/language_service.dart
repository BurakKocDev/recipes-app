import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'isTurkish';
  static bool _isTurkish = false;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isTurkish = prefs.getBool(_languageKey) ?? false;
  }

  static bool get isTurkish => _isTurkish;

  static Future<void> setLanguage(bool isTurkish) async {
    _isTurkish = isTurkish;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_languageKey, isTurkish);
  }

  static Future<void> toggleLanguage() async {
    await setLanguage(!_isTurkish);
  }
}

class Translations {
  static Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': 'Recipe Finder',
      'discoverRecipes': 'Discover delicious recipes',
      'enterIngredients': 'Enter ingredients (comma separated)',
      'search': 'Search',
      'recentSearches': 'Recent Searches',
      'clear': 'Clear',
      'sortBy': 'Sort by:',
      'none': 'None',
      'caloriesLow': 'Calories (Low to High)',
      'caloriesHigh': 'Calories (High to Low)',
      'timeShortest': 'Time (Shortest)',
      'timeLongest': 'Time (Longest)',
      'proteinHigh': 'Protein (High to Low)',
      'nutritionFilters': 'Nutrition Filters',
      'maxCalories': 'Max Calories',
      'minProtein': 'Min Protein (g)',
      'maxFat': 'Max Fat (g)',
      'noLimit': 'No limit',
      'noResults': 'No recipes found',
      'tryDifferentIngredients': 'Try different ingredients',
      'favorites': 'Favorites',
      'noFavorites': 'No favorites yet',
      'addToFavorites': 'Add recipes to favorites to see them here',
      'shoppingList': 'Shopping List',
      'addItem': 'Add item',
      'emptyShoppingList': 'Your shopping list is empty',
      'addItemsToStart': 'Add items to get started',
      'shareList': 'Share List',
      'clearList': 'Clear List',
      'areYouSureClear': 'Are you sure you want to clear all items?',
      'cancel': 'Cancel',
      'nutritionCalculator': 'Nutrition Calculator',
      'todaysProgress': "Today's Progress",
      'dailyGoals': 'Daily Goals',
      'saveGoals': 'Save Goals',
      'calories': 'Calories',
      'protein': 'Protein',
      'fat': 'Fat',
      'carbs': 'Carbs',
      'compareRecipes': 'Compare Recipes',
      'recipe1': 'Recipe 1',
      'recipe2': 'Recipe 2',
      'selectRecipe2': 'Select Recipe 2',
      'changeRecipe2': 'Change Recipe 2',
      'comparison': 'Comparison',
      'time': 'Time',
      'description': 'Description',
      'ingredients': 'Ingredients',
      'instructions': 'Instructions',
      'addToShoppingList': 'Add to Shopping List',
      'addToNutrition': 'Add to Nutrition',
      'shareRecipe': 'Share Recipe',
      'recipeCopied': 'Recipe copied to clipboard!',
      'ingredientsAdded': 'Ingredients added to shopping list!',
      'addedToNutrition': 'Added to daily nutrition!',
      'goalsSaved': 'Goals saved!',
      'shoppingListCopied': 'Shopping list copied to clipboard!',
    },
    'tr': {
      'appTitle': 'Tarif Bulucu',
      'discoverRecipes': 'Lezzetli tarifler keşfedin',
      'enterIngredients': 'Malzemeleri girin (virgülle ayırın)',
      'search': 'Ara',
      'recentSearches': 'Son Aramalar',
      'clear': 'Temizle',
      'sortBy': 'Sırala:',
      'none': 'Yok',
      'caloriesLow': 'Kalori (Düşükten Yükseğe)',
      'caloriesHigh': 'Kalori (Yüksekten Düşüğe)',
      'timeShortest': 'Süre (En Kısa)',
      'timeLongest': 'Süre (En Uzun)',
      'proteinHigh': 'Protein (Yüksekten Düşüğe)',
      'nutritionFilters': 'Beslenme Filtreleri',
      'maxCalories': 'Maksimum Kalori',
      'minProtein': 'Minimum Protein (g)',
      'maxFat': 'Maksimum Yağ (g)',
      'noLimit': 'Limit yok',
      'noResults': 'Tarif bulunamadı',
      'tryDifferentIngredients': 'Farklı malzemeler deneyin',
      'favorites': 'Favoriler',
      'noFavorites': 'Henüz favori yok',
      'addToFavorites': 'Favorilere eklemek için tarifleri favorilere ekleyin',
      'shoppingList': 'Alışveriş Listesi',
      'addItem': 'Ürün ekle',
      'emptyShoppingList': 'Alışveriş listeniz boş',
      'addItemsToStart': 'Başlamak için ürün ekleyin',
      'shareList': 'Listeyi Paylaş',
      'clearList': 'Listeyi Temizle',
      'areYouSureClear': 'Tüm ürünleri temizlemek istediğinizden emin misiniz?',
      'cancel': 'İptal',
      'nutritionCalculator': 'Beslenme Hesaplayıcı',
      'todaysProgress': 'Bugünün İlerlemesi',
      'dailyGoals': 'Günlük Hedefler',
      'saveGoals': 'Hedefleri Kaydet',
      'calories': 'Kalori',
      'protein': 'Protein',
      'fat': 'Yağ',
      'carbs': 'Karbonhidrat',
      'compareRecipes': 'Tarifleri Karşılaştır',
      'recipe1': 'Tarif 1',
      'recipe2': 'Tarif 2',
      'selectRecipe2': 'Tarif 2 Seç',
      'changeRecipe2': 'Tarif 2 Değiştir',
      'comparison': 'Karşılaştırma',
      'time': 'Süre',
      'description': 'Açıklama',
      'ingredients': 'Malzemeler',
      'instructions': 'Talimatlar',
      'addToShoppingList': 'Alışveriş Listesine Ekle',
      'addToNutrition': 'Beslenmeye Ekle',
      'shareRecipe': 'Tarifi Paylaş',
      'recipeCopied': 'Tarif panoya kopyalandı!',
      'ingredientsAdded': 'Malzemeler alışveriş listesine eklendi!',
      'addedToNutrition': 'Günlük beslenmeye eklendi!',
      'goalsSaved': 'Hedefler kaydedildi!',
      'shoppingListCopied': 'Alışveriş listesi panoya kopyalandı!',
    },
  };

  static String get(String key) {
    final lang = LanguageService.isTurkish ? 'tr' : 'en';
    return _translations[lang]?[key] ?? key;
  }
}

