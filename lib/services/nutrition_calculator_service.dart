import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class NutritionGoals {
  final double dailyCalories;
  final double dailyProtein;
  final double dailyFat;
  final double dailyCarbs;

  NutritionGoals({
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyFat,
    required this.dailyCarbs,
  });

  Map<String, dynamic> toJson() => {
        'calories': dailyCalories,
        'protein': dailyProtein,
        'fat': dailyFat,
        'carbs': dailyCarbs,
      };

  factory NutritionGoals.fromJson(Map<String, dynamic> json) => NutritionGoals(
        dailyCalories: (json['calories'] ?? 2000).toDouble(),
        dailyProtein: (json['protein'] ?? 150).toDouble(),
        dailyFat: (json['fat'] ?? 65).toDouble(),
        dailyCarbs: (json['carbs'] ?? 250).toDouble(),
      );
}

class DailyNutrition {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final DateTime date;

  DailyNutrition({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'date': date.toIso8601String(),
      };

  factory DailyNutrition.fromJson(Map<String, dynamic> json) => DailyNutrition(
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        date: DateTime.parse(json['date']),
      );
}

class AddedRecipe {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final DateTime addedAt;

  AddedRecipe({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'addedAt': addedAt.toIso8601String(),
      };

  factory AddedRecipe.fromJson(Map<String, dynamic> json) => AddedRecipe(
        id: json['id'],
        name: json['name'],
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        addedAt: DateTime.parse(json['addedAt']),
      );
}

class NutritionCalculatorService {
  static const String _goalsKey = 'nutrition_goals';
  static const String _dailyNutritionKey = 'daily_nutrition';
  static const String _addedRecipesKey = 'added_recipes';

  Future<NutritionGoals> getGoals() async {
    // Always get a fresh instance
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final goalsJson = prefs.getString(_goalsKey);
    if (goalsJson == null) {
      return NutritionGoals(
        dailyCalories: 2000,
        dailyProtein: 150,
        dailyFat: 65,
        dailyCarbs: 250,
      );
    }
    return NutritionGoals.fromJson(
      Map<String, dynamic>.from(
        prefs.getString(_goalsKey) != null
            ? json.decode(prefs.getString(_goalsKey)!)
            : {},
      ),
    );
  }

  Future<void> setGoals(NutritionGoals goals) async {
    final goalsJson = json.encode(goals.toJson());
    // Force save with multiple attempts using fresh instances
    for (int i = 0; i < 10; i++) {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_goalsKey, goalsJson);
      if (success) {
        // Wait longer to ensure disk write
        await Future.delayed(const Duration(milliseconds: 500));
        // Verify with a completely fresh instance
        final verifyPrefs = await SharedPreferences.getInstance();
        await verifyPrefs.reload();
        final verifyGoalsJson = verifyPrefs.getString(_goalsKey);
        if (verifyGoalsJson == goalsJson) {
          // One more verification
          await Future.delayed(const Duration(milliseconds: 200));
          final finalPrefs = await SharedPreferences.getInstance();
          await finalPrefs.reload();
          final finalGoalsJson = finalPrefs.getString(_goalsKey);
          if (finalGoalsJson == goalsJson) {
            return; // Successfully saved
          }
        }
      }
      // If not successful, wait before retry
      await Future.delayed(const Duration(milliseconds: 200));
    }
    throw Exception('Failed to save nutrition goals after multiple attempts');
  }

  Future<void> addRecipeNutrition(String recipeName, double calories, double protein, double fat, double carbs) async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    // Add to added recipes list
    final recipeId = DateTime.now().millisecondsSinceEpoch.toString();
    final addedRecipe = AddedRecipe(
      id: recipeId,
      name: recipeName,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      addedAt: today,
    );
    
    // Get existing recipes with fresh instance
    final prefs1 = await SharedPreferences.getInstance();
    await prefs1.reload();
    final existingRecipesJson = prefs1.getString('$_addedRecipesKey$todayKey');
    List<AddedRecipe> recipes = [];
    if (existingRecipesJson != null) {
      final List<dynamic> decoded = json.decode(existingRecipesJson);
      recipes = decoded.map((r) => AddedRecipe.fromJson(r)).toList();
    }
    recipes.add(addedRecipe);
    final recipesJsonToSave = json.encode(recipes.map((r) => r.toJson()).toList());
    
    // Update daily nutrition totals
    final existingDailyJson = prefs1.getString('$_dailyNutritionKey$todayKey');
    
    DailyNutrition daily;
    if (existingDailyJson != null) {
      daily = DailyNutrition.fromJson(json.decode(existingDailyJson));
      daily = DailyNutrition(
        calories: daily.calories + calories,
        protein: daily.protein + protein,
        fat: daily.fat + fat,
        carbs: daily.carbs + carbs,
        date: today,
      );
    } else {
      daily = DailyNutrition(
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
        date: today,
      );
    }
    
    final dailyJsonToSave = json.encode(daily.toJson());
    // Save both with retry mechanism using fresh instances
    for (int i = 0; i < 10; i++) {
      final prefs = await SharedPreferences.getInstance();
      final recipesSuccess = await prefs.setString('$_addedRecipesKey$todayKey', recipesJsonToSave);
      final dailySuccess = await prefs.setString('$_dailyNutritionKey$todayKey', dailyJsonToSave);
      if (recipesSuccess && dailySuccess) {
        // Wait longer to ensure disk write
        await Future.delayed(const Duration(milliseconds: 500));
        // Verify with a completely fresh instance
        final verifyPrefs = await SharedPreferences.getInstance();
        await verifyPrefs.reload();
        final verifyRecipesJson = verifyPrefs.getString('$_addedRecipesKey$todayKey');
        final verifyDailyJson = verifyPrefs.getString('$_dailyNutritionKey$todayKey');
        if (verifyRecipesJson == recipesJsonToSave && verifyDailyJson == dailyJsonToSave) {
          // One more verification
          await Future.delayed(const Duration(milliseconds: 200));
          final finalPrefs = await SharedPreferences.getInstance();
          await finalPrefs.reload();
          final finalRecipesJson = finalPrefs.getString('$_addedRecipesKey$todayKey');
          final finalDailyJson = finalPrefs.getString('$_dailyNutritionKey$todayKey');
          if (finalRecipesJson == recipesJsonToSave && finalDailyJson == dailyJsonToSave) {
            return; // Successfully saved
          }
        }
      }
      // If not successful, wait before retry
      await Future.delayed(const Duration(milliseconds: 200));
    }
    throw Exception('Failed to save nutrition data after multiple attempts');
  }

  Future<List<AddedRecipe>> getTodayAddedRecipes() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    // Always get a fresh instance
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final recipesJson = prefs.getString('$_addedRecipesKey$todayKey');
    
    if (recipesJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(recipesJson);
      final recipes = decoded.map((r) => AddedRecipe.fromJson(r)).toList();
      
      // Filter out any recipes that don't have valid data
      return recipes.where((r) => 
        r.id.isNotEmpty && 
        r.name.isNotEmpty &&
        r.calories >= 0 &&
        r.protein >= 0 &&
        r.fat >= 0 &&
        r.carbs >= 0
      ).toList();
    } catch (e) {
      // If parsing fails, clear the corrupted data
      await prefs.remove('$_addedRecipesKey$todayKey');
      return [];
    }
  }

  Future<void> clearTodayData() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_addedRecipesKey$todayKey');
    await prefs.remove('$_dailyNutritionKey$todayKey');
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(_addedRecipesKey) || key.startsWith(_dailyNutritionKey)) {
        await prefs.remove(key);
      }
    }
  }

  Future<void> removeRecipe(String recipeId) async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final recipesJson = prefs.getString('$_addedRecipesKey$todayKey');
    
    if (recipesJson == null) return;
    
    try {
      final List<dynamic> decoded = json.decode(recipesJson);
      List<AddedRecipe> recipes = decoded.map((r) => AddedRecipe.fromJson(r)).toList();
      
      // Find the recipe to remove
      final recipeIndex = recipes.indexWhere((r) => r.id == recipeId);
      if (recipeIndex == -1) {
        // Recipe not found, might be from old format - recalculate from scratch
        await _recalculateDailyNutrition();
        return;
      }
      
      final recipeToRemove = recipes[recipeIndex];
      recipes.removeAt(recipeIndex);
      
      // Update stored recipes
      if (recipes.isEmpty) {
        for (int i = 0; i < 10; i++) {
          final removePrefs = await SharedPreferences.getInstance();
          await removePrefs.remove('$_addedRecipesKey$todayKey');
          await Future.delayed(const Duration(milliseconds: 500));
          final verifyPrefs = await SharedPreferences.getInstance();
          await verifyPrefs.reload();
          if (!verifyPrefs.containsKey('$_addedRecipesKey$todayKey')) {
            await Future.delayed(const Duration(milliseconds: 200));
            final finalPrefs = await SharedPreferences.getInstance();
            await finalPrefs.reload();
            if (!finalPrefs.containsKey('$_addedRecipesKey$todayKey')) {
              break; // Successfully removed
            }
          }
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } else {
        final recipesJsonToSave = json.encode(recipes.map((r) => r.toJson()).toList());
        // Force save with multiple attempts using fresh instances
        for (int i = 0; i < 10; i++) {
          final savePrefs = await SharedPreferences.getInstance();
          final success = await savePrefs.setString('$_addedRecipesKey$todayKey', recipesJsonToSave);
          if (success) {
            await Future.delayed(const Duration(milliseconds: 500));
            final verifyPrefs = await SharedPreferences.getInstance();
            await verifyPrefs.reload();
            final verifyRecipesJson = verifyPrefs.getString('$_addedRecipesKey$todayKey');
            if (verifyRecipesJson == recipesJsonToSave) {
              await Future.delayed(const Duration(milliseconds: 200));
              final finalPrefs = await SharedPreferences.getInstance();
              await finalPrefs.reload();
              final finalRecipesJson = finalPrefs.getString('$_addedRecipesKey$todayKey');
              if (finalRecipesJson == recipesJsonToSave) {
                break; // Successfully saved
              }
            }
          }
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      
      // Update daily nutrition totals by subtracting removed recipe
      final dailyJson = prefs.getString('$_dailyNutritionKey$todayKey');
      if (dailyJson != null) {
        final daily = DailyNutrition.fromJson(json.decode(dailyJson));
        final updatedDaily = DailyNutrition(
          calories: (daily.calories - recipeToRemove.calories).clamp(0.0, double.infinity),
          protein: (daily.protein - recipeToRemove.protein).clamp(0.0, double.infinity),
          fat: (daily.fat - recipeToRemove.fat).clamp(0.0, double.infinity),
          carbs: (daily.carbs - recipeToRemove.carbs).clamp(0.0, double.infinity),
          date: today,
        );
        final updatedDailyJson = json.encode(updatedDaily.toJson());
        // Force save with multiple attempts using fresh instances
        for (int i = 0; i < 10; i++) {
          final savePrefs = await SharedPreferences.getInstance();
          final success = await savePrefs.setString('$_dailyNutritionKey$todayKey', updatedDailyJson);
          if (success) {
            await Future.delayed(const Duration(milliseconds: 500));
            final verifyPrefs = await SharedPreferences.getInstance();
            await verifyPrefs.reload();
            final verifyDailyJson = verifyPrefs.getString('$_dailyNutritionKey$todayKey');
            if (verifyDailyJson == updatedDailyJson) {
              await Future.delayed(const Duration(milliseconds: 200));
              final finalPrefs = await SharedPreferences.getInstance();
              await finalPrefs.reload();
              final finalDailyJson = finalPrefs.getString('$_dailyNutritionKey$todayKey');
              if (finalDailyJson == updatedDailyJson) {
                return; // Successfully saved
              }
            }
          }
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    } catch (e) {
      // If there's an error, recalculate from scratch
      await _recalculateDailyNutrition();
    }
  }

  Future<void> _recalculateDailyNutrition() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final recipesJson = prefs.getString('$_addedRecipesKey$todayKey');
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;
    
    if (recipesJson != null) {
      try {
        final List<dynamic> decoded = json.decode(recipesJson);
        final recipes = decoded.map((r) => AddedRecipe.fromJson(r)).toList();
        
        for (final recipe in recipes) {
          totalCalories += recipe.calories;
          totalProtein += recipe.protein;
          totalFat += recipe.fat;
          totalCarbs += recipe.carbs;
        }
      } catch (e) {
        // If parsing fails, clear the data
        await prefs.remove('$_addedRecipesKey$todayKey');
      }
    }
    
    final updatedDaily = DailyNutrition(
      calories: totalCalories,
      protein: totalProtein,
      fat: totalFat,
      carbs: totalCarbs,
      date: today,
    );
    final updatedDailyJson = json.encode(updatedDaily.toJson());
    // Force save with multiple attempts using fresh instances
    for (int i = 0; i < 10; i++) {
      final savePrefs = await SharedPreferences.getInstance();
      final success = await savePrefs.setString('$_dailyNutritionKey$todayKey', updatedDailyJson);
      if (success) {
        // Wait longer to ensure disk write
        await Future.delayed(const Duration(milliseconds: 500));
        // Verify with a completely fresh instance
        final verifyPrefs = await SharedPreferences.getInstance();
        await verifyPrefs.reload();
        final verifyDailyJson = verifyPrefs.getString('$_dailyNutritionKey$todayKey');
        if (verifyDailyJson == updatedDailyJson) {
          // One more verification
          await Future.delayed(const Duration(milliseconds: 200));
          final finalPrefs = await SharedPreferences.getInstance();
          await finalPrefs.reload();
          final finalDailyJson = finalPrefs.getString('$_dailyNutritionKey$todayKey');
          if (finalDailyJson == updatedDailyJson) {
            return; // Successfully saved
          }
        }
      }
      // If not successful, wait before retry
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<DailyNutrition> getTodayNutrition() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    
    // Always get a fresh instance
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final dailyJson = prefs.getString('$_dailyNutritionKey$todayKey');
    
    if (dailyJson == null) {
      return DailyNutrition(
        calories: 0,
        protein: 0,
        fat: 0,
        carbs: 0,
        date: today,
      );
    }
    
    return DailyNutrition.fromJson(json.decode(dailyJson));
  }
}

