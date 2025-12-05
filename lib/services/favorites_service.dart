import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class FavoritesService {
  static const String _favoritesKey = 'favorite_recipes';

  Future<List<String>> getFavoriteRecipeNames() async {
    // Always get a fresh instance
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesJson;
  }

  Future<bool> isFavorite(String recipeName) async {
    final favorites = await getFavoriteRecipeNames();
    return favorites.contains(recipeName);
  }

  Future<void> addFavorite(String recipeName) async {
    final favorites = await getFavoriteRecipeNames();
    if (!favorites.contains(recipeName)) {
      favorites.add(recipeName);
      // Force save with multiple attempts using fresh instances
      for (int i = 0; i < 10; i++) {
        final prefs = await SharedPreferences.getInstance();
        final success = await prefs.setStringList(_favoritesKey, favorites);
        if (success) {
          // Wait longer to ensure disk write
          await Future.delayed(const Duration(milliseconds: 500));
          // Verify with a completely fresh instance
          final verifyPrefs = await SharedPreferences.getInstance();
          await verifyPrefs.reload();
          final verifyFavorites = verifyPrefs.getStringList(_favoritesKey) ?? [];
          if (verifyFavorites.contains(recipeName)) {
            // One more verification
            await Future.delayed(const Duration(milliseconds: 200));
            final finalPrefs = await SharedPreferences.getInstance();
            await finalPrefs.reload();
            final finalFavorites = finalPrefs.getStringList(_favoritesKey) ?? [];
            if (finalFavorites.contains(recipeName)) {
              return; // Successfully saved
            }
          }
        }
        // If not successful, wait before retry
        await Future.delayed(const Duration(milliseconds: 200));
      }
      throw Exception('Failed to save favorites after multiple attempts');
    }
  }

  Future<void> removeFavorite(String recipeName) async {
    final favorites = await getFavoriteRecipeNames();
    favorites.remove(recipeName);
    // Force save with multiple attempts using fresh instances
    for (int i = 0; i < 10; i++) {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setStringList(_favoritesKey, favorites);
      if (success) {
        // Wait longer to ensure disk write
        await Future.delayed(const Duration(milliseconds: 500));
        // Verify with a completely fresh instance
        final verifyPrefs = await SharedPreferences.getInstance();
        await verifyPrefs.reload();
        final verifyFavorites = verifyPrefs.getStringList(_favoritesKey) ?? [];
        if (!verifyFavorites.contains(recipeName)) {
          // One more verification
          await Future.delayed(const Duration(milliseconds: 200));
          final finalPrefs = await SharedPreferences.getInstance();
          await finalPrefs.reload();
          final finalFavorites = finalPrefs.getStringList(_favoritesKey) ?? [];
          if (!finalFavorites.contains(recipeName)) {
            return; // Successfully saved
          }
        }
      }
      // If not successful, wait before retry
      await Future.delayed(const Duration(milliseconds: 200));
    }
    throw Exception('Failed to save favorites after multiple attempts');
  }

  Future<void> toggleFavorite(String recipeName) async {
    final isFav = await isFavorite(recipeName);
    if (isFav) {
      await removeFavorite(recipeName);
    } else {
      await addFavorite(recipeName);
    }
  }
}

