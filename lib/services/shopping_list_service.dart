import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class ShoppingListItem {
  final String name;
  bool isChecked;

  ShoppingListItem({required this.name, this.isChecked = false});

  Map<String, dynamic> toJson() => {
        'name': name,
        'isChecked': isChecked,
      };

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) =>
      ShoppingListItem(
        name: json['name'],
        isChecked: json['isChecked'] ?? false,
      );
}

class ShoppingListService {
  static const String _shoppingListKey = 'shopping_list';

  Future<List<ShoppingListItem>> getShoppingList() async {
    // Always get a fresh instance
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final listJson = prefs.getString(_shoppingListKey);
    if (listJson == null) return [];
    
    final List<dynamic> decoded = json.decode(listJson);
    return decoded.map((item) => ShoppingListItem.fromJson(item)).toList();
  }

  Future<void> addItem(String itemName) async {
    if (itemName.trim().isEmpty) return;
    
    final list = await getShoppingList();
    // Check if item already exists
    if (list.any((item) => item.name.toLowerCase() == itemName.toLowerCase())) {
      return;
    }
    
    list.add(ShoppingListItem(name: itemName.trim()));
    await _saveList(list);
  }

  Future<void> addItems(List<String> items) async {
    final list = await getShoppingList();
    for (final item in items) {
      if (item.trim().isEmpty) continue;
      final itemName = item.trim();
      if (!list.any((existing) => existing.name.toLowerCase() == itemName.toLowerCase())) {
        list.add(ShoppingListItem(name: itemName));
      }
    }
    await _saveList(list);
  }

  Future<void> toggleItem(String itemName) async {
    final list = await getShoppingList();
    final index = list.indexWhere((item) => item.name == itemName);
    if (index != -1) {
      list[index].isChecked = !list[index].isChecked;
      await _saveList(list);
    }
  }

  Future<void> removeItem(String itemName) async {
    final list = await getShoppingList();
    list.removeWhere((item) => item.name == itemName);
    await _saveList(list);
  }

  Future<void> clearList() async {
    for (int i = 0; i < 10; i++) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_shoppingListKey);
      await Future.delayed(const Duration(milliseconds: 500));
      final savedPrefs = await SharedPreferences.getInstance();
      await savedPrefs.reload();
      if (!savedPrefs.containsKey(_shoppingListKey)) {
        // One more verification
        await Future.delayed(const Duration(milliseconds: 200));
        final finalPrefs = await SharedPreferences.getInstance();
        await finalPrefs.reload();
        if (!finalPrefs.containsKey(_shoppingListKey)) {
          return; // Successfully removed
        }
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _saveList(List<ShoppingListItem> list) async {
    final jsonString = json.encode(list.map((item) => item.toJson()).toList());
    // Force save with multiple attempts using fresh instances
    for (int i = 0; i < 10; i++) {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_shoppingListKey, jsonString);
      if (success) {
        // Wait longer to ensure disk write
        await Future.delayed(const Duration(milliseconds: 500));
        // Verify with a completely fresh instance
        final verifyPrefs = await SharedPreferences.getInstance();
        await verifyPrefs.reload();
        final verifyJson = verifyPrefs.getString(_shoppingListKey);
        if (verifyJson == jsonString) {
          // One more verification
          await Future.delayed(const Duration(milliseconds: 200));
          final finalPrefs = await SharedPreferences.getInstance();
          await finalPrefs.reload();
          final finalJson = finalPrefs.getString(_shoppingListKey);
          if (finalJson == jsonString) {
            return; // Successfully saved
          }
        }
      }
      // If not successful, wait before retry
      await Future.delayed(const Duration(milliseconds: 200));
    }
    throw Exception('Failed to save shopping list after multiple attempts');
  }
}

