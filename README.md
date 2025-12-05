# Recipe Finder App  

https://youtube.com/shorts/glwgDypJrGQ

A comprehensive Flutter mobile application that helps users discover recipes based on available ingredients, manage their cooking preferences, and track nutrition information. The app uses recipe data from a Kaggle dataset and provides an intuitive interface for searching, filtering, and organizing recipes.

## Features

### 🔍 Recipe Search & Discovery
- **Ingredient-based Search**: Find recipes by entering available ingredients (comma-separated)
- **Smart Filtering**: Filter recipes by nutrition values (calories, protein, fat)
- **Missing Ingredient Calculation**: Automatically calculates and displays missing ingredients for each recipe
- **Recipe Recommendations**: Get similar recipe suggestions based on ingredients and categories
- **Sorting Options**: Sort recipes by calories, cooking time, or protein content

### 📋 Recipe Management
- **Favorites**: Save your favorite recipes for quick access
- **Shopping List**: Add missing ingredients to a shopping list with check-off functionality
- **Recipe Notes**: Add personal notes to any recipe for customization tips or modifications
- **Recipe Comparison**: Compare multiple recipes side-by-side
- **Recipe Sharing**: Share recipes via social media or messaging apps

### 📊 Nutrition Tracking
- **Nutrition Calculator**: Set daily nutrition goals (calories, protein, fat, carbs)
- **Daily Nutrition Tracking**: Track your daily nutrition intake by adding recipes
- **Nutrition Information**: View detailed nutrition facts for each recipe
- **Progress Visualization**: Monitor your progress toward daily nutrition goals

### 🎨 User Experience
- **Dark/Light Theme**: Toggle between dark and light modes with persistent preference
- **Bottom Navigation**: Easy navigation between main sections
- **Smooth Animations**: Polished page transitions and UI animations
- **Offline Support**: Works completely offline with local recipe data
- **Empty States**: Helpful empty state messages with visual indicators

## Tech Stack

### Frontend
- **Flutter** (Dart) - Cross-platform mobile framework
- **Material Design** - Modern UI components
- **SharedPreferences** - Local data persistence
- **Share Plus** - Social media sharing functionality

### Backend/Data Processing
- **Python** - Data processing and translation
- **Pandas** - Data manipulation and processing
- **Deep Translator** - Recipe data translation

## Dataset

This application uses recipe data from a **Kaggle dataset**. The dataset has been processed and translated using Python scripts to create a comprehensive recipe database with ingredients, instructions, nutrition information, and cooking times.

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Python 3.x (for data processing, optional)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd recipes
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Data Processing (Optional)

If you need to process or update the recipe data:

1. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run data processing scripts**
   ```bash
   cd python_data
   python data_translate.py
   ```

## Project Structure

```
recipes/
├── lib/
│   ├── main.dart                 # Main application entry point
│   ├── models/
│   │   └── recipe.dart           # Recipe data model
│   └── services/
│       ├── recipe_service.dart           # Recipe search and filtering logic
│       ├── favorites_service.dart        # Favorites management
│       ├── shopping_list_service.dart    # Shopping list management
│       ├── nutrition_calculator_service.dart  # Nutrition tracking
│       ├── notes_service.dart            # Recipe notes management
│       └── search_history_service.dart   # Search history
├── assets/
│   └── hazir_tarifler.json       # Recipe dataset (JSON)
├── python_data/
│   ├── data_translate.py         # Data processing script
│   └── hazir_tarifler.json       # Source recipe data
└── pubspec.yaml                  # Flutter dependencies
```

## Key Dependencies

- `shared_preferences: ^2.2.2` - Local data persistence
- `share_plus: ^10.1.2` - Social media sharing
- `cached_network_image: ^3.3.1` - Image caching (if needed)

## Usage

1. **Search Recipes**: Enter ingredients separated by commas in the search bar
2. **Filter Results**: Use the filter button to set nutrition constraints
3. **View Recipe Details**: Tap on any recipe to see full details, ingredients, and instructions
4. **Add to Favorites**: Tap the heart icon to save recipes
5. **Create Shopping List**: Add missing ingredients directly to your shopping list
6. **Track Nutrition**: Set goals and add recipes to track daily nutrition intake
7. **Add Notes**: Add personal notes to recipes for future reference

## Data Persistence

All user data (favorites, shopping lists, nutrition goals, notes) is persisted locally using SharedPreferences. Data is automatically saved and restored when the app is closed and reopened.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Recipe data sourced from Kaggle
- Built with Flutter and Dart
- Icons and UI components from Material Design
