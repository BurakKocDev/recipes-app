import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recipe.dart';

class RecipeService {
  List<Recipe> _recipes = [];

  Future<void> loadRecipes() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/hazir_tarifler.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _recipes = jsonData.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }

  List<Recipe> filterRecipesByIngredients(List<String> userIngredients) {
    if (userIngredients.isEmpty) {
      return [];
    }

    // Convert user ingredients to lowercase for case-insensitive matching
    final lowerUserIngredients = userIngredients
        .map((ingredient) => ingredient.toLowerCase().trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    if (lowerUserIngredients.isEmpty) {
      return [];
    }

    return _recipes.where((recipe) {
      // Convert recipe ingredients to lowercase for matching
      final lowerRecipeIngredients = recipe.ingredients
          .map((ingredient) => ingredient.toLowerCase().trim())
          .toList();

      // Check if at least one user ingredient matches any recipe ingredient
      return lowerUserIngredients.any((userIngredient) {
        return lowerRecipeIngredients.any((recipeIngredient) {
          // Check for exact match or if recipe ingredient contains user ingredient
          return recipeIngredient.contains(userIngredient) ||
              userIngredient.contains(recipeIngredient);
        });
      });
    }).toList();
  }

  List<Recipe> getAllRecipes() {
    return _recipes;
  }

  List<Recipe> filterRecipesByCategory(String category) {
    if (category == 'Tümü' || category.isEmpty) {
      return _recipes;
    }
    return _recipes.where((recipe) => recipe.category == category).toList();
  }

  List<Recipe> filterRecipesByCategoryAndIngredients(
      String category, List<String> userIngredients) {
    List<Recipe> filtered = filterRecipesByCategory(category);
    if (userIngredients.isEmpty) {
      return filtered;
    }
    return filterRecipesByIngredients(userIngredients)
        .where((recipe) => filtered.contains(recipe))
        .toList();
  }

  List<String> getCategories() {
    final categories = _recipes.map((r) => r.category).toSet().toList();
    categories.sort();
    return ['Tümü', ...categories];
  }

  List<Recipe> getSimilarRecipes(Recipe recipe, {int limit = 5}) {
    // Find recipes with similar ingredients or same category
    final similarRecipes = _recipes.where((r) {
      if (r.name == recipe.name) return false; // Exclude the recipe itself
      
      // Check if same category
      if (r.category == recipe.category) return true;
      
      // Check if shares at least 2 ingredients
      final sharedIngredients = recipe.ingredients.where((ing) {
        return r.ingredients.any((rIng) => 
          rIng.toLowerCase().contains(ing.toLowerCase()) ||
          ing.toLowerCase().contains(rIng.toLowerCase())
        );
      }).length;
      
      return sharedIngredients >= 2;
    }).toList();
    
    // Sort by similarity (more shared ingredients first)
    similarRecipes.sort((a, b) {
      final aShared = recipe.ingredients.where((ing) {
        return a.ingredients.any((rIng) => 
          rIng.toLowerCase().contains(ing.toLowerCase()) ||
          ing.toLowerCase().contains(rIng.toLowerCase())
        );
      }).length;
      
      final bShared = recipe.ingredients.where((ing) {
        return b.ingredients.any((rIng) => 
          rIng.toLowerCase().contains(ing.toLowerCase()) ||
          ing.toLowerCase().contains(rIng.toLowerCase())
        );
      }).length;
      
      return bShared.compareTo(aShared);
    });
    
    return similarRecipes.take(limit).toList();
  }
}

