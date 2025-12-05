import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'models/recipe.dart';
import 'services/recipe_service.dart';
import 'services/favorites_service.dart';
import 'services/shopping_list_service.dart';
import 'services/nutrition_calculator_service.dart';
import 'services/notes_service.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatefulWidget {
  const RecipeApp({super.key});

  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadThemePreference();
    // Minimum loading time for smooth transition (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(_isDarkMode), // Force rebuild when theme changes
      title: 'Recipe Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF6C5CE7), width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
          ),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _isLoading
          ? SplashScreen(isDarkMode: _isDarkMode)
          : MainPage(
              onThemeToggle: _toggleTheme,
              isDarkMode: _isDarkMode,
            ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;

  const SplashScreen({super.key, required this.isDarkMode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = const Color(0xFF6C5CE7);
    final secondaryColor = const Color(0xFF00B894);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    // ignore: deprecated_member_use
                    primaryColor.withOpacity(0.3),
                    // ignore: deprecated_member_use
                    secondaryColor.withOpacity(0.2),
                    Colors.black87,
                  ]
                : [
                    // ignore: deprecated_member_use
                    primaryColor.withOpacity(0.15),
                    // ignore: deprecated_member_use
                    secondaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo/Icon
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 0.1,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor,
                                secondaryColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Recipe Finder',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        width: 200,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Animated progress bar
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 200 * (_controller.value * 0.5 + 0.5),
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Lezzetli tarifler keşfedin',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? Colors.white70
                        : primaryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main Page with Bottom Navigation Bar
class MainPage extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const MainPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final RecipeService _recipeService = RecipeService();
  final FavoritesService _favoritesService = FavoritesService();
  final ShoppingListService _shoppingListService = ShoppingListService();
  final NutritionCalculatorService _nutritionCalculatorService = NutritionCalculatorService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            RecipeSearchPage(
              onThemeToggle: widget.onThemeToggle,
              isDarkMode: widget.isDarkMode,
            ),
            FavoritesPage(
              favoritesService: _favoritesService,
              recipeService: _recipeService,
              shoppingListService: _shoppingListService,
              nutritionCalculatorService: _nutritionCalculatorService,
            ),
            ShoppingListPage(
              shoppingListService: _shoppingListService,
            ),
            NutritionCalculatorPage(
              nutritionCalculatorService: _nutritionCalculatorService,
              recipeService: _recipeService,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          selectedItemColor: const Color(0xFF6C5CE7),
          unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Icons.search : Icons.search_outlined),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 1 ? Icons.favorite : Icons.favorite_border),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2 ? Icons.shopping_cart : Icons.shopping_cart_outlined),
              label: 'Shopping',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 3 ? Icons.calculate : Icons.calculate_outlined),
              label: 'Nutrition',
            ),
          ],
        ),
            ),
    );
  }
}

class RecipeSearchPage extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const RecipeSearchPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<RecipeSearchPage> createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage>
    with SingleTickerProviderStateMixin {
  final RecipeService _recipeService = RecipeService();
  final FavoritesService _favoritesService = FavoritesService();
  final ShoppingListService _shoppingListService = ShoppingListService();
  final NutritionCalculatorService _nutritionCalculatorService = NutritionCalculatorService();
  final TextEditingController _ingredientController = TextEditingController();
  List<Recipe> _filteredRecipes = [];
  Set<String> _favoriteRecipeNames = {};
  bool _isLoading = false;
  bool _isDataLoaded = false;
  String _sortBy = 'none'; // 'none', 'calories_low', 'calories_high', 'time_low', 'time_high', 'protein_high'
  
  // Nutrition filters
  double? _maxCalories;
  double? _minProtein;
  double? _maxFat;
  bool _showFilters = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadRecipes();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.getFavoriteRecipeNames();
    if (mounted) {
      setState(() {
        _favoriteRecipeNames = favorites.toSet();
      });
    }
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _recipeService.loadRecipes();
      setState(() {
        _isDataLoaded = true;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading recipes: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _searchRecipes() {
    final ingredients = _ingredientController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) {
      setState(() {
        _filteredRecipes = [];
      });
      return;
    }

    var filtered = _recipeService.filterRecipesByIngredients(ingredients);
    
    // Apply nutrition filters
    if (_maxCalories != null) {
      filtered = filtered.where((r) => r.nutritionInfo.calories <= _maxCalories!).toList();
    }
    if (_minProtein != null) {
      filtered = filtered.where((r) => r.nutritionInfo.protein >= _minProtein!).toList();
    }
    if (_maxFat != null) {
      filtered = filtered.where((r) => r.nutritionInfo.fat <= _maxFat!).toList();
    }
    
    List<Recipe> sortedRecipes = List.from(filtered);
    
    // Auto-sort based on active filters if no manual sort is selected
    if (_sortBy == 'none') {
      // If filters are active, auto-sort by most relevant
      if (_maxCalories != null) {
        // Sort by calories (low to high) when max calories filter is active
        sortedRecipes.sort((a, b) => a.nutritionInfo.calories.compareTo(b.nutritionInfo.calories));
      } else if (_minProtein != null) {
        // Sort by protein (high to low) when min protein filter is active
        sortedRecipes.sort((a, b) => b.nutritionInfo.protein.compareTo(a.nutritionInfo.protein));
      } else if (_maxFat != null) {
        // Sort by fat (low to high) when max fat filter is active
        sortedRecipes.sort((a, b) => a.nutritionInfo.fat.compareTo(b.nutritionInfo.fat));
      }
    } else {
      // Apply manual sorting
      switch (_sortBy) {
        case 'calories_low':
          sortedRecipes.sort((a, b) => a.nutritionInfo.calories.compareTo(b.nutritionInfo.calories));
          break;
        case 'calories_high':
          sortedRecipes.sort((a, b) => b.nutritionInfo.calories.compareTo(a.nutritionInfo.calories));
          break;
        case 'time_low':
          sortedRecipes.sort((a, b) => a.minutes.compareTo(b.minutes));
          break;
        case 'time_high':
          sortedRecipes.sort((a, b) => b.minutes.compareTo(a.minutes));
          break;
        case 'protein_high':
          sortedRecipes.sort((a, b) => b.nutritionInfo.protein.compareTo(a.nutritionInfo.protein));
          break;
      }
    }

    setState(() {
      _filteredRecipes = sortedRecipes;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _sortRecipes(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    if (_filteredRecipes.isNotEmpty) {
      _searchRecipes();
    }
  }

  Future<void> _toggleFavorite(String recipeName) async {
    await _favoritesService.toggleFavorite(recipeName);
    // Update favorites immediately for instant feedback
    final favorites = await _favoritesService.getFavoriteRecipeNames();
    if (mounted) {
      setState(() {
        _favoriteRecipeNames = favorites.toSet();
      });
    }
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF6C5CE7).withOpacity(0.2),
                    const Color(0xFF00B894).withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    const Color(0xFF6C5CE7).withOpacity(0.1),
                    const Color(0xFF00B894).withOpacity(0.05),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C5CE7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading recipes...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : !_isDataLoaded
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load recipes',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Modern AppBar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C5CE7),
                                const Color(0xFF8B7ED8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Recipe Finder',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'Discover delicious recipes',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  widget.onThemeToggle(!widget.isDarkMode);
                                },
                                tooltip: 'Toggle Theme',
                              ),
                            ],
                          ),
                        ),

                        // Search Section
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor.withOpacity(isDark ? 0.3 : 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _ingredientController,
                                decoration: InputDecoration(
                                  labelText: 'Enter ingredients (comma separated)',
                                  hintText: 'e.g., chicken, onion, garlic',
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C5CE7)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.search,
                                      color: Color(0xFF6C5CE7),
                                    ),
                                  ),
                                  suffixIcon: _ingredientController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _ingredientController.clear();
                                            setState(() {
                                              _filteredRecipes = [];
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                onSubmitted: (_) => _searchRecipes(),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6C5CE7),
                                      Color(0xFF8B7ED8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C5CE7)
                                          .withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _searchRecipes,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Search Recipes',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Search History
                        // Compact Sort and Filters Row
                        if (_filteredRecipes.isNotEmpty)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF6C5CE7).withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                              children: [
                                    const Icon(
                                      Icons.sort,
                                      color: Color(0xFF6C5CE7),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: _sortBy,
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                        dropdownColor: Theme.of(context).cardColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: 'none',
                                            child: Text(
                                              'Sıralama Yok',
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'calories_low',
                                            child: Text(
                                              'Kalori (Düşük→Yüksek)',
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'calories_high',
                                            child: Text(
                                              'Kalori (Yüksek→Düşük)',
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'time_low',
                                            child: Text(
                                              'Süre (Kısa)',
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'time_high',
                                            child: Text(
                                              'Süre (Uzun)',
                                  style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'protein_high',
                                            child: Text(
                                              'Protein (Yüksek)',
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        _sortRecipes(value);
                                      }
                                    },
                                  ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                                        size: 18,
                                      ),
                                      color: (_maxCalories != null || _minProtein != null || _maxFat != null)
                                          ? const Color(0xFF6C5CE7)
                                          : Colors.grey,
                                      onPressed: () {
                                        setState(() {
                                          _showFilters = !_showFilters;
                                        });
                                      },
                                      tooltip: 'Nutrition Filters',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    if (_maxCalories != null || _minProtein != null || _maxFat != null)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                              // Expandable Nutrition Filters
                              if (_showFilters)
                          Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  constraints: const BoxConstraints(maxHeight: 400),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF6C5CE7).withOpacity(0.2),
                              ),
                            ),
                                  child: SingleChildScrollView(
                            child: Column(
                                      mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.tune,
                                          size: 16,
                                          color: const Color(0xFF6C5CE7),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Nutrition Filters',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_maxCalories != null || _minProtein != null || _maxFat != null)
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _maxCalories = null;
                                            _minProtein = null;
                                            _maxFat = null;
                                          });
                                          if (_filteredRecipes.isNotEmpty) {
                                            _searchRecipes();
                                          }
                                        },
                                        icon: const Icon(Icons.refresh, size: 14),
                                        label: const Text(
                                          'Reset',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                        // Max Calories Slider
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.local_fire_department, size: 14, color: const Color(0xFFFF6B6B)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Max Kalori',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  _maxCalories != null
                                                      ? '${_maxCalories!.toInt()}'
                                                      : 'Yok',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: _maxCalories != null
                                                        ? const Color(0xFFFF6B6B)
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Slider(
                                              value: _maxCalories ?? 2000,
                                              min: 100,
                                              max: 3000,
                                              divisions: 29,
                                              activeColor: const Color(0xFFFF6B6B),
                                              inactiveColor: const Color(0xFFFF6B6B).withOpacity(0.3),
                                              onChangeEnd: (value) {
                                          setState(() {
                                                  _maxCalories = value;
                                          });
                                          if (_filteredRecipes.isNotEmpty) {
                                            _searchRecipes();
                                          }
                                        },
                                              onChanged: (value) {
                                                setState(() {
                                                  _maxCalories = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Min Protein Slider
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.fitness_center, size: 14, color: const Color(0xFF4ECDC4)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Min Protein',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  _minProtein != null
                                                      ? '${_minProtein!.toInt()}g'
                                                      : 'Yok',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: _minProtein != null
                                                        ? const Color(0xFF4ECDC4)
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Slider(
                                              value: _minProtein ?? 0,
                                              min: 0,
                                              max: 200,
                                              divisions: 40,
                                              activeColor: const Color(0xFF4ECDC4),
                                              inactiveColor: const Color(0xFF4ECDC4).withOpacity(0.3),
                                              onChangeEnd: (value) {
                                          setState(() {
                                                  _minProtein = value > 0 ? value : null;
                                          });
                                          if (_filteredRecipes.isNotEmpty) {
                                            _searchRecipes();
                                          }
                                        },
                                              onChanged: (value) {
                                                setState(() {
                                                  _minProtein = value > 0 ? value : null;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Max Fat Slider
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.water_drop, size: 14, color: const Color(0xFF6C5CE7)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Max Yağ',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  _maxFat != null
                                                      ? '${_maxFat!.toInt()}g'
                                                      : 'Yok',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: _maxFat != null
                                                        ? const Color(0xFF6C5CE7)
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Slider(
                                              value: _maxFat ?? 100,
                                              min: 0,
                                              max: 200,
                                              divisions: 40,
                                              activeColor: const Color(0xFF6C5CE7),
                                              inactiveColor: const Color(0xFF6C5CE7).withOpacity(0.3),
                                              onChangeEnd: (value) {
                                          setState(() {
                                                  _maxFat = value > 0 ? value : null;
                                          });
                                          if (_filteredRecipes.isNotEmpty) {
                                            _searchRecipes();
                                          }
                                        },
                                              onChanged: (value) {
                                                setState(() {
                                                  _maxFat = value > 0 ? value : null;
                                                });
                                              },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                                  ),
                                ),
                            ],
                          ),

                        // Results Section
                        if (_filteredRecipes.isEmpty &&
                            _ingredientController.text.isNotEmpty)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).shadowColor.withOpacity(isDark ? 0.3 : 0.2),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Column(
                                    children: [
                                  Text(
                                        '🔍',
                                        style: TextStyle(fontSize: 64),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Recipes Found',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.headlineMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                        'Try different ingredients',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (_filteredRecipes.isEmpty)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF6C5CE7)
                                              .withOpacity(0.1),
                                          const Color(0xFF00B894)
                                              .withOpacity(0.1),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      size: 80,
                                      color: const Color(0xFF6C5CE7),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'Ready to cook?',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.headlineLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Enter ingredients to discover\namazing recipes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                                      itemCount: _filteredRecipes.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            if (index == 0)
                                Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C5CE7)
                                              .withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                                        '${_filteredRecipes.length} tarif bulundu',
                                          style: const TextStyle(
                                            color: Color(0xFF6C5CE7),
                                            fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                            RecipeCard(
                                          recipe: _filteredRecipes[index],
                                          index: index,
                                          isFavorite: _favoriteRecipeNames.contains(_filteredRecipes[index].name),
                                          onFavoriteToggle: () => _toggleFavorite(_filteredRecipes[index].name),
                                          shoppingListService: _shoppingListService,
                                          nutritionCalculatorService: _nutritionCalculatorService,
                                          recipeService: _recipeService,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final ShoppingListService? shoppingListService;
  final NutritionCalculatorService? nutritionCalculatorService;
  final RecipeService? recipeService;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.index,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.shoppingListService,
    this.nutritionCalculatorService,
    this.recipeService,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = this.recipe;
    final isFavorite = this.isFavorite;
    final onFavoriteToggle = this.onFavoriteToggle;
    final shoppingListService = this.shoppingListService;
    final nutritionCalculatorService = this.nutritionCalculatorService;
    final recipeService = this.recipeService;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(
                  recipe: recipe,
                  shoppingListService: shoppingListService,
                  nutritionCalculatorService: nutritionCalculatorService,
                  recipeService: recipeService,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with recipe name and favorite button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineSmall?.color,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Favorite button
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Theme.of(context).iconTheme.color,
                        size: 24,
                      ),
                      onPressed: () {
                        onFavoriteToggle();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Time and nutrition info row
                Row(
                  children: [
                    // Time badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.minutes}m',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Compact nutrition info
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildCompactNutritionChip(
                            context,
                            '${recipe.nutritionInfo.calories.toStringAsFixed(0)}',
                            Icons.local_fire_department,
                            const Color(0xFFFF6B6B),
                          ),
                          _buildCompactNutritionChip(
                            context,
                            '${recipe.nutritionInfo.protein.toStringAsFixed(0)}g',
                            Icons.fitness_center,
                            const Color(0xFF4ECDC4),
                          ),
                          _buildCompactNutritionChip(
                            context,
                            '${recipe.nutritionInfo.fat.toStringAsFixed(0)}g',
                            Icons.water_drop,
                            const Color(0xFF6C5CE7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCompactNutritionChip(
    BuildContext context,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
                ),
              ],
            ),
    );
  }

}

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final ShoppingListService? shoppingListService;
  final NutritionCalculatorService? nutritionCalculatorService;
  final RecipeService? recipeService;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    this.shoppingListService,
    this.nutritionCalculatorService,
    this.recipeService,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final NotesService _notesService = NotesService();
  final ScrollController _scrollController = ScrollController();
  String? _note;
  double _titleOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final expandedHeight = 100.0;
    final collapsedHeight = kToolbarHeight;
    final difference = expandedHeight - collapsedHeight;
    
    if (offset > difference) {
      setState(() {
        _titleOpacity = 0.0;
      });
    } else {
      setState(() {
        _titleOpacity = 1.0 - (offset / difference).clamp(0.0, 1.0);
      });
    }
  }

  Future<void> _loadNote() async {
    final note = await _notesService.getNote(widget.recipe.name);
    if (mounted) {
      setState(() {
        _note = note;
      });
    }
  }

  Future<void> _showNoteDialog() async {
    final TextEditingController controller = TextEditingController(text: _note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.note_add, color: Color(0xFF6C5CE7)),
            const SizedBox(width: 8),
            const Text('Recipe Note'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Write your notes about this recipe here...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          if (_note != null && _note!.isNotEmpty)
            TextButton(
              onPressed: () async {
                await _notesService.deleteNote(widget.recipe.name);
                Navigator.pop(context, '');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _notesService.saveNote(widget.recipe.name, result);
        // Wait a bit to ensure data is saved
        await Future.delayed(const Duration(milliseconds: 300));
        // Reload note to verify it was saved
        await _loadNote();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.isEmpty ? 'Note deleted' : 'Note saved',
              ),
              backgroundColor: const Color(0xFF6C5CE7),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save note: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _shareRecipe(BuildContext context) async {
    final shareText = '''
🍽️ ${widget.recipe.name}

⏱️ Cooking Time: ${widget.recipe.minutes} minutes

📊 Nutrition Information:
• Calories: ${widget.recipe.nutritionInfo.calories.toStringAsFixed(0)}
• Protein: ${widget.recipe.nutritionInfo.protein.toStringAsFixed(0)}g
• Fat: ${widget.recipe.nutritionInfo.fat.toStringAsFixed(0)}g
• Carbs: ${widget.recipe.nutritionInfo.carbs.toStringAsFixed(0)}g

📝 Ingredients:
${widget.recipe.ingredients.map((ing) => '• $ing').join('\n')}

👨‍🍳 Instructions:
${widget.recipe.steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n\n')}
${_note != null && _note!.isNotEmpty ? '\n📝 My Notes:\n$_note\n' : ''}
Shared from Recipe Finder app 🍴
''';
    
    try {
      await Share.share(
        shareText,
        subject: '${widget.recipe.name} Recipe',
      );
    } catch (e) {
      // Fallback to clipboard if share fails
    Clipboard.setData(ClipboardData(text: shareText));
      if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
            content: const Text('Recipe copied to clipboard!'),
        backgroundColor: const Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF6C5CE7).withOpacity(0.2),
                    const Color(0xFF00B894).withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    const Color(0xFF6C5CE7).withOpacity(0.1),
                    const Color(0xFF00B894).withOpacity(0.05),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF6C5CE7),
                elevation: 0,
                collapsedHeight: kToolbarHeight,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Opacity(
                    opacity: _titleOpacity,
                    child: Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 4, right: 16),
                  centerTitle: false,
                ),
                title: null,
                actions: [
                  IconButton(
                    icon: Icon(
                      _note != null && _note!.isNotEmpty
                          ? Icons.note
                          : Icons.note_add,
                      color: Colors.white,
                      size: 22,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: _showNoteDialog,
                    tooltip: 'Recipe Note',
                  ),
                  IconButton(
                    icon: const Icon(Icons.compare_arrows, color: Colors.white, size: 22),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeComparisonPage(
                            recipe1: widget.recipe,
                            recipeService: widget.recipeService,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Compare Recipe',
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white, size: 22),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: () => _shareRecipe(context),
                    tooltip: 'Share Recipe',
                  ),
                  if (widget.shoppingListService != null)
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 22),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        await widget.shoppingListService!.addItems(widget.recipe.ingredients);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Ingredients added to shopping list!'),
                              backgroundColor: const Color(0xFF6C5CE7),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      tooltip: 'Add to Shopping List',
                    ),
                  if (widget.nutritionCalculatorService != null)
                    IconButton(
                      icon: const Icon(Icons.add_chart, color: Colors.white, size: 22),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        await widget.nutritionCalculatorService!.addRecipeNutrition(
                          widget.recipe.name,
                          widget.recipe.nutritionInfo.calories,
                          widget.recipe.nutritionInfo.protein,
                          widget.recipe.nutritionInfo.fat,
                          widget.recipe.nutritionInfo.carbs,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Added to daily nutrition!'),
                              backgroundColor: const Color(0xFF6C5CE7),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      tooltip: 'Add to Nutrition',
                    ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nutrition Info Cards
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildDetailNutritionItem(
                                context,
                                'Calories',
                                '${widget.recipe.nutritionInfo.calories.toStringAsFixed(0)}',
                                Icons.local_fire_department,
                                const Color(0xFFFF6B6B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailNutritionItem(
                                context,
                                'Protein',
                                '${widget.recipe.nutritionInfo.protein.toStringAsFixed(0)}g',
                                Icons.fitness_center,
                                const Color(0xFF4ECDC4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailNutritionItem(
                                context,
                                'Fat',
                                '${widget.recipe.nutritionInfo.fat.toStringAsFixed(0)}g',
                                Icons.water_drop,
                                const Color(0xFF6C5CE7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailNutritionItem(
                                context,
                                'Carbs',
                                '${widget.recipe.nutritionInfo.carbs.toStringAsFixed(0)}g',
                                Icons.grain,
                                const Color(0xFF00B894),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Time and Description
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6C5CE7).withOpacity(0.2),
                                  const Color(0xFF00B894).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF6C5CE7),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.recipe.minutes} minutes',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6C5CE7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      if (widget.recipe.description.isNotEmpty) ...[
                        _buildSectionTitle(context, 'Description'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.recipe.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Ingredients
                      _buildSectionTitle(context, 'Ingredients'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.recipe.ingredients.asMap().entries.map((entry) {
                            final index = entry.key;
                            final ingredient = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6C5CE7),
                                          Color(0xFF8B7ED8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ingredient,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Steps
                      _buildSectionTitle(context, 'Instructions'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.recipe.steps.asMap().entries.map((entry) {
                            final index = entry.key;
                            final step = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00B894),
                                          Color(0xFF00D2A8),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Similar Recipes
                      if (widget.recipeService != null) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, 'Similar Recipes'),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final similarRecipes = widget.recipeService!.getSimilarRecipes(widget.recipe, limit: 3);
                            if (similarRecipes.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'No similar recipes found',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: similarRecipes.length,
                                itemBuilder: (context, index) {
                                  final similarRecipe = similarRecipes[index];
                                  return Container(
                                    width: 180,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RecipeDetailPage(
                                                recipe: similarRecipe,
                                                shoppingListService: widget.shoppingListService,
                                                nutritionCalculatorService: widget.nutritionCalculatorService,
                                                recipeService: widget.recipeService,
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                similarRecipe.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${similarRecipe.minutes}m',
                                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6C5CE7),
                Color(0xFF00B894),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailNutritionItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  final FavoritesService favoritesService;
  final RecipeService recipeService;
  final ShoppingListService? shoppingListService;
  final NutritionCalculatorService? nutritionCalculatorService;

  const FavoritesPage({
    super.key,
    required this.favoritesService,
    required this.recipeService,
    this.shoppingListService,
    this.nutritionCalculatorService,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    // Make sure recipes are loaded
    try {
      await widget.recipeService.loadRecipes();
    } catch (e) {
      // Recipes might already be loaded, ignore error
    }

    final favorites = await widget.favoritesService.getFavoriteRecipeNames();
    final allRecipes = widget.recipeService.getAllRecipes();
    
    final favoriteRecipes = allRecipes
        .where((recipe) => favorites.contains(recipe.name))
        .toList();

    setState(() {
      _favoriteRecipes = favoriteRecipes;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String recipeName) async {
    await widget.favoritesService.removeFavorite(recipeName);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteRecipes.isEmpty
              ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
            Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add recipes to favorites to see them here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
            ),
          ],
        ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _favoriteRecipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      index: index,
                      isFavorite: true,
                      onFavoriteToggle: () => _removeFavorite(recipe.name),
                      recipeService: widget.recipeService,
                      shoppingListService: widget.shoppingListService,
                      nutritionCalculatorService: widget.nutritionCalculatorService,
                    );
                  },
                ),
    );
  }
}

// Share function helper
// Shopping List Page
class ShoppingListPage extends StatefulWidget {
  final ShoppingListService shoppingListService;

  const ShoppingListPage({
    super.key,
    required this.shoppingListService,
  });

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<ShoppingListItem> _shoppingList = [];
  bool _isLoading = true;
  final TextEditingController _itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final list = await widget.shoppingListService.getShoppingList();
    setState(() {
      _shoppingList = list;
      _isLoading = false;
    });
  }

  Future<void> _addItem() async {
    if (_itemController.text.trim().isNotEmpty) {
      await widget.shoppingListService.addItem(_itemController.text.trim());
      _itemController.clear();
      await _loadShoppingList();
    }
  }

  Future<void> _toggleItem(String itemName) async {
    await widget.shoppingListService.toggleItem(itemName);
    await _loadShoppingList();
  }

  Future<void> _removeItem(String itemName) async {
    await widget.shoppingListService.removeItem(itemName);
    await _loadShoppingList();
  }

  Future<void> _clearList() async {
    await widget.shoppingListService.clearList();
    await _loadShoppingList();
  }

  void _shareList() {
    final checkedItems = _shoppingList.where((item) => item.isChecked).map((item) => '✓ ${item.name}').join('\n');
    final uncheckedItems = _shoppingList.where((item) => !item.isChecked).map((item) => '☐ ${item.name}').join('\n');
    
    final shareText = '🛒 Shopping List\n\n$checkedItems${checkedItems.isNotEmpty && uncheckedItems.isNotEmpty ? '\n' : ''}$uncheckedItems';
    
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Shopping list copied to clipboard!'),
        backgroundColor: const Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        actions: [
          if (_shoppingList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareList,
              tooltip: 'Share List',
            ),
          if (_shoppingList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear List'),
                    content: const Text('Are you sure you want to clear all items?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _clearList();
                }
              },
              tooltip: 'Clear List',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      labelText: 'Add item',
                      hintText: 'e.g., chicken, tomatoes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: const Color(0xFF6C5CE7),
                  onPressed: _addItem,
                  tooltip: 'Add Item',
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _shoppingList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                            ),
                            const SizedBox(height: 24),
                            Column(
                              children: [
                            Text(
                                  '🛒',
                                  style: TextStyle(fontSize: 64),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Shopping List Empty',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                  'Add items to get started',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _shoppingList.length,
                        itemBuilder: (context, index) {
                          final item = _shoppingList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Checkbox(
                                value: item.isChecked,
                                onChanged: (_) => _toggleItem(item.name),
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                  color: item.isChecked
                                      ? Theme.of(context).textTheme.bodySmall?.color
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeItem(item.name),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Nutrition Calculator Page
class NutritionCalculatorPage extends StatefulWidget {
  final NutritionCalculatorService nutritionCalculatorService;
  final RecipeService? recipeService;

  const NutritionCalculatorPage({
    super.key,
    required this.nutritionCalculatorService,
    this.recipeService,
  });

  @override
  State<NutritionCalculatorPage> createState() => _NutritionCalculatorPageState();
}

class _NutritionCalculatorPageState extends State<NutritionCalculatorPage> {
  NutritionGoals _goals = NutritionGoals(
    dailyCalories: 2000,
    dailyProtein: 150,
    dailyFat: 65,
    dailyCarbs: 250,
  );
  DailyNutrition _todayNutrition = DailyNutrition(
    calories: 0,
    protein: 0,
    fat: 0,
    carbs: 0,
    date: DateTime.now(),
  );
  List<AddedRecipe> _addedRecipes = [];
  bool _isLoading = true;
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(NutritionCalculatorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when widget updates
    _loadData();
  }

  Future<void> _loadData() async {
    final goals = await widget.nutritionCalculatorService.getGoals();
    final today = await widget.nutritionCalculatorService.getTodayNutrition();
    final recipes = await widget.nutritionCalculatorService.getTodayAddedRecipes();
    setState(() {
      _goals = goals;
      _todayNutrition = today;
      _addedRecipes = recipes;
      _caloriesController.text = _goals.dailyCalories.toStringAsFixed(0);
      _proteinController.text = _goals.dailyProtein.toStringAsFixed(0);
      _fatController.text = _goals.dailyFat.toStringAsFixed(0);
      _carbsController.text = _goals.dailyCarbs.toStringAsFixed(0);
      _isLoading = false;
    });
  }

  Future<void> _removeRecipe(String recipeId) async {
    try {
      await widget.nutritionCalculatorService.removeRecipe(recipeId);
      // Force reload data to ensure UI is updated
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recipe removed from daily nutrition'),
            backgroundColor: const Color(0xFF6C5CE7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // If removal fails, reload data anyway to sync state
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error removing recipe. Data refreshed.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveGoals() async {
    final goals = NutritionGoals(
      dailyCalories: double.tryParse(_caloriesController.text) ?? 2000,
      dailyProtein: double.tryParse(_proteinController.text) ?? 150,
      dailyFat: double.tryParse(_fatController.text) ?? 65,
      dailyCarbs: double.tryParse(_carbsController.text) ?? 250,
    );
    await widget.nutritionCalculatorService.setGoals(goals);
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Goals saved!'),
        backgroundColor: const Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caloriesProgress = (_todayNutrition.calories / _goals.dailyCalories).clamp(0.0, 1.0);
    final proteinProgress = (_todayNutrition.protein / _goals.dailyProtein).clamp(0.0, 1.0);
    final fatProgress = (_todayNutrition.fat / _goals.dailyFat).clamp(0.0, 1.0);
    final carbsProgress = (_todayNutrition.carbs / _goals.dailyCarbs).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Calculator'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        actions: [
          if (_addedRecipes.isNotEmpty || _todayNutrition.calories > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Data'),
                    content: const Text('Are you sure you want to clear all added recipes and reset today\'s nutrition? This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await widget.nutritionCalculatorService.clearTodayData();
                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('All data cleared successfully'),
                        backgroundColor: const Color(0xFF6C5CE7),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              },
              tooltip: 'Clear All Data',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Progress",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.headlineSmall?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildProgressBar(
                          'Calories',
                          _todayNutrition.calories.toStringAsFixed(0),
                          _goals.dailyCalories.toStringAsFixed(0),
                          caloriesProgress,
                          const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressBar(
                          'Protein',
                          _todayNutrition.protein.toStringAsFixed(0),
                          _goals.dailyProtein.toStringAsFixed(0),
                          proteinProgress,
                          const Color(0xFF4ECDC4),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressBar(
                          'Fat',
                          _todayNutrition.fat.toStringAsFixed(0),
                          _goals.dailyFat.toStringAsFixed(0),
                          fatProgress,
                          const Color(0xFF6C5CE7),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressBar(
                          'Carbs',
                          _todayNutrition.carbs.toStringAsFixed(0),
                          _goals.dailyCarbs.toStringAsFixed(0),
                          carbsProgress,
                          const Color(0xFF00B894),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Daily Goals
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Goals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.headlineSmall?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _caloriesController,
                                decoration: const InputDecoration(
                                  labelText: 'Calories',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _proteinController,
                                decoration: const InputDecoration(
                                  labelText: 'Protein (g)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _fatController,
                                decoration: const InputDecoration(
                                  labelText: 'Fat (g)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _carbsController,
                                decoration: const InputDecoration(
                                  labelText: 'Carbs (g)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveGoals,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save Goals'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Added Recipes List
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Added Recipes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.headlineSmall?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _addedRecipes.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu,
                                        size: 48,
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No recipes added yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add recipes from recipe details',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _addedRecipes.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final recipe = _addedRecipes[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).textTheme.headlineSmall?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 12,
                                                runSpacing: 8,
                                                children: [
                                                  _buildMiniNutritionInfo(
                                                    'Cal',
                                                    recipe.calories.toStringAsFixed(0),
                                                    const Color(0xFFFF6B6B),
                                                  ),
                                                  _buildMiniNutritionInfo(
                                                    'P',
                                                    '${recipe.protein.toStringAsFixed(0)}g',
                                                    const Color(0xFF4ECDC4),
                                                  ),
                                                  _buildMiniNutritionInfo(
                                                    'F',
                                                    '${recipe.fat.toStringAsFixed(0)}g',
                                                    const Color(0xFF6C5CE7),
                                                  ),
                                                  _buildMiniNutritionInfo(
                                                    'C',
                                                    '${recipe.carbs.toStringAsFixed(0)}g',
                                                    const Color(0xFF00B894),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _removeRecipe(recipe.id),
                                          tooltip: 'Remove',
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniNutritionInfo(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, String current, String goal, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              '$current / $goal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// Recipe Comparison Page
class RecipeComparisonPage extends StatefulWidget {
  final Recipe recipe1;
  final RecipeService? recipeService;

  const RecipeComparisonPage({
    super.key,
    required this.recipe1,
    this.recipeService,
  });

  @override
  State<RecipeComparisonPage> createState() => _RecipeComparisonPageState();
}

class _RecipeComparisonPageState extends State<RecipeComparisonPage> {
  Recipe? _recipe2;
  List<Recipe> _allRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    if (widget.recipeService != null) {
      try {
        await widget.recipeService!.loadRecipes();
        final all = widget.recipeService!.getAllRecipes();
        setState(() {
          _allRecipes = all.where((r) => r.name != widget.recipe1.name).toList();
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectRecipe2() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Recipe to Compare',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _allRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = _allRecipes[index];
                  return ListTile(
                    title: Text(recipe.name),
                    subtitle: Text('${recipe.minutes} min • ${recipe.nutritionInfo.calories.toStringAsFixed(0)} cal'),
                    onTap: () {
                      setState(() {
                        _recipe2 = recipe;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Recipes'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Recipe 1
                  _buildRecipeCard(widget.recipe1, 'Recipe 1'),
                  const SizedBox(height: 20),
                  // Select Recipe 2 Button
                  if (_recipe2 == null)
                    ElevatedButton.icon(
                      onPressed: _selectRecipe2,
                      icon: const Icon(Icons.add),
                      label: const Text('Select Recipe 2'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildRecipeCard(_recipe2!, 'Recipe 2'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _selectRecipe2,
                          child: const Text('Change Recipe 2'),
                        ),
                      ],
                    ),
                  if (_recipe2 != null) ...[
                    const SizedBox(height: 20),
                    _buildComparisonTable(widget.recipe1, _recipe2!),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recipe.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat('Time', '${recipe.minutes}m', Icons.access_time),
              const SizedBox(width: 16),
              _buildMiniStat('Calories', recipe.nutritionInfo.calories.toStringAsFixed(0), Icons.local_fire_department),
              const SizedBox(width: 16),
              _buildMiniStat('Protein', '${recipe.nutritionInfo.protein.toStringAsFixed(0)}g', Icons.fitness_center),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6C5CE7)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonTable(Recipe recipe1, Recipe recipe2) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Comparison',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 20),
          _buildComparisonRow('Time', '${recipe1.minutes}m', '${recipe2.minutes}m'),
          _buildComparisonRow('Calories', recipe1.nutritionInfo.calories.toStringAsFixed(0), recipe2.nutritionInfo.calories.toStringAsFixed(0)),
          _buildComparisonRow('Protein', '${recipe1.nutritionInfo.protein.toStringAsFixed(0)}g', '${recipe2.nutritionInfo.protein.toStringAsFixed(0)}g'),
          _buildComparisonRow('Fat', '${recipe1.nutritionInfo.fat.toStringAsFixed(0)}g', '${recipe2.nutritionInfo.fat.toStringAsFixed(0)}g'),
          _buildComparisonRow('Carbs', '${recipe1.nutritionInfo.carbs.toStringAsFixed(0)}g', '${recipe2.nutritionInfo.carbs.toStringAsFixed(0)}g'),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value1, String value2) {
    final num1 = double.tryParse(value1.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final num2 = double.tryParse(value2.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final isBetter1 = num1 < num2; // Lower is better for most metrics
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBetter1 ? const Color(0xFF00B894).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBetter1 ? const Color(0xFF00B894) : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: !isBetter1 ? const Color(0xFF00B894).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !isBetter1 ? const Color(0xFF00B894) : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
