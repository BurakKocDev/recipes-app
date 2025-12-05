import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class NotesService {
  static const String _notesKeyPrefix = 'recipe_note_';

  /// Get note for a recipe
  Future<String?> getNote(String recipeName) async {
    // Always get a fresh instance to ensure we have the latest data
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getString('$_notesKeyPrefix$recipeName');
  }

  /// Save note for a recipe
  Future<void> saveNote(String recipeName, String note) async {
    final key = '$_notesKeyPrefix$recipeName';
    if (note.trim().isEmpty) {
      // Remove note if empty
      for (int i = 0; i < 10; i++) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
        await Future.delayed(const Duration(milliseconds: 500));
        final verifyPrefs = await SharedPreferences.getInstance();
        await verifyPrefs.reload();
        if (!verifyPrefs.containsKey(key)) {
          // One more verification
          await Future.delayed(const Duration(milliseconds: 200));
          final finalPrefs = await SharedPreferences.getInstance();
          await finalPrefs.reload();
          if (!finalPrefs.containsKey(key)) {
            return; // Successfully removed
          }
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } else {
      final noteValue = note.trim();
      // Force save with multiple attempts using fresh instances
      for (int i = 0; i < 10; i++) {
        final prefs = await SharedPreferences.getInstance();
        final success = await prefs.setString(key, noteValue);
        if (success) {
          // Wait longer to ensure disk write
          await Future.delayed(const Duration(milliseconds: 500));
          // Verify with a completely fresh instance
          final verifyPrefs = await SharedPreferences.getInstance();
          await verifyPrefs.reload();
          final verifyNote = verifyPrefs.getString(key);
          if (verifyNote == noteValue) {
            // One more verification
            await Future.delayed(const Duration(milliseconds: 200));
            final finalPrefs = await SharedPreferences.getInstance();
            await finalPrefs.reload();
            final finalNote = finalPrefs.getString(key);
            if (finalNote == noteValue) {
              return; // Successfully saved
            }
          }
        }
        // If not successful, wait before retry
        await Future.delayed(const Duration(milliseconds: 200));
      }
      throw Exception('Failed to save note after multiple attempts');
    }
  }

  /// Delete note for a recipe
  Future<void> deleteNote(String recipeName) async {
    final key = '$_notesKeyPrefix$recipeName';
    for (int i = 0; i < 10; i++) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      await Future.delayed(const Duration(milliseconds: 500));
      final verifyPrefs = await SharedPreferences.getInstance();
      await verifyPrefs.reload();
      if (!verifyPrefs.containsKey(key)) {
        // One more verification
        await Future.delayed(const Duration(milliseconds: 200));
        final finalPrefs = await SharedPreferences.getInstance();
        await finalPrefs.reload();
        if (!finalPrefs.containsKey(key)) {
          return; // Successfully removed
        }
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  /// Check if recipe has a note
  Future<bool> hasNote(String recipeName) async {
    final note = await getNote(recipeName);
    return note != null && note.isNotEmpty;
  }

  /// Get all recipes with notes
  Future<List<String>> getRecipesWithNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys
        .where((key) => key.startsWith(_notesKeyPrefix))
        .map((key) => key.replaceFirst(_notesKeyPrefix, ''))
        .toList();
  }
}

