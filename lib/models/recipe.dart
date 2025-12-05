import 'package:flutter/material.dart';

class Recipe {
  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final String description;
  final int minutes;
  final NutritionInfo nutritionInfo;
  final String category;
  final String? imageUrl;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.description,
    required this.minutes,
    required this.nutritionInfo,
    this.category = 'Diğer',
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      description: json['description'] ?? '',
      minutes: json['minutes'] ?? 0,
      nutritionInfo: NutritionInfo.fromJson(json['nutrition_info'] ?? {}),
      category: json['category'] ?? 'Diğer',
      imageUrl: json['image_url'],
    );
  }

  String get placeholderImage {
    // Generate placeholder based on category
    switch (category) {
      case 'Kahvaltı':
        return '🥞';
      case 'Öğle Yemeği':
        return '🍽️';
      case 'Akşam Yemeği':
        return '🍲';
      case 'Tatlı':
        return '🍰';
      case 'Atıştırmalık':
        return '🍕';
      case 'İçecek':
        return '🥤';
      default:
        return '🍴';
    }
  }
}

class RecipeCategory {
  static const List<String> categories = [
    'Tümü',
    'Kahvaltı',
    'Öğle Yemeği',
    'Akşam Yemeği',
    'Tatlı',
    'Atıştırmalık',
    'İçecek',
    'Diğer',
  ];

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Kahvaltı':
        return Icons.breakfast_dining;
      case 'Öğle Yemeği':
        return Icons.lunch_dining;
      case 'Akşam Yemeği':
        return Icons.dinner_dining;
      case 'Tatlı':
        return Icons.cake;
      case 'Atıştırmalık':
        return Icons.fastfood;
      case 'İçecek':
        return Icons.local_drink;
      default:
        return Icons.restaurant_menu;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Kahvaltı':
        return const Color(0xFFFFB84D);
      case 'Öğle Yemeği':
        return const Color(0xFF4ECDC4);
      case 'Akşam Yemeği':
        return const Color(0xFF6C5CE7);
      case 'Tatlı':
        return const Color(0xFFFF6B9D);
      case 'Atıştırmalık':
        return const Color(0xFF00B894);
      case 'İçecek':
        return const Color(0xFF74B9FF);
      default:
        return const Color(0xFF95A5A6);
    }
  }
}

class NutritionInfo {
  final double calories;
  final double fat;
  final double protein;
  final double carbs;

  NutritionInfo({
    required this.calories,
    required this.fat,
    required this.protein,
    required this.carbs,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
    );
  }
}

