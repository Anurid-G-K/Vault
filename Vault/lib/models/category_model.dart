import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryModel extends ChangeNotifier {

  List<Map<String, dynamic>> categories = [
    {'name': 'Food & Dining', 'amount': 6500, 'limit': 9000, 'color': Colors.orange.value, 'icon': Icons.restaurant.codePoint},
    {'name': 'Transport', 'amount': 2400, 'limit': 4000, 'color': Colors.blue.value, 'icon': Icons.directions_car.codePoint},
    {'name': 'Entertainment', 'amount': 2200, 'limit': 3500, 'color': Colors.pink.value, 'icon': Icons.movie.codePoint},
    {'name': 'Shopping', 'amount': 3500, 'limit': 6000, 'color': Colors.purple.value, 'icon': Icons.shopping_bag.codePoint},
    {'name': 'Bills', 'amount': 6200, 'limit': 8000, 'color': Colors.red.value, 'icon': Icons.receipt.codePoint},
    {'name': 'Health', 'amount': 1000, 'limit': 2500, 'color': Colors.green.value, 'icon': Icons.health_and_safety.codePoint},
    {'name': 'Education', 'amount': 800, 'limit': 3000, 'color': Colors.teal.value, 'icon': Icons.school.codePoint},
    {'name': 'Other', 'amount': 1200, 'limit': 4000, 'color': Colors.grey.value, 'icon': Icons.more_horiz.codePoint},
  ];

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('categories');

    if (data != null) {
      List decoded = jsonDecode(data);
      categories = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categories', jsonEncode(categories));
  }

  void addExpense(String categoryName, int amount) {
    for (var cat in categories) {
      if (cat['name'] == categoryName) {
        cat['amount'] += amount;
        break;
      }
    }

    saveCategories();
    notifyListeners();
  }

  /// NEW METHOD REQUIRED BY home_screen.dart
  void addCategory(String name, int limit) {
    categories.add({
      'name': name,
      'amount': 0,
      'limit': limit,
      'color': Colors.teal.value,
      'icon': Icons.category.codePoint,
    });

    saveCategories();
    notifyListeners();
  }

  List<Map<String, dynamic>> get topCategories {
    List<Map<String, dynamic>> sorted = List.from(categories);
    sorted.sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));
    return sorted.take(3).toList();
  }
}