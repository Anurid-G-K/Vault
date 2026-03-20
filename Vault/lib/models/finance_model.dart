// finance_model.dart
import 'package:flutter/material.dart';

class FinanceModel extends ChangeNotifier {
  static final FinanceModel _instance = FinanceModel._internal();
  factory FinanceModel() => _instance;
  FinanceModel._internal();

  double _monthlyBudget = 40000;
  double _totalSpent = 23800;
  double _totalSavings = 41200;
  double _savingsChange = 8.4;
  double _spentToday = 450;
  double _avgPerDay = 793;
  double _thisMonthSavings = 16200;
  double _lastMonthSavings = 14950;

  // Getters
  double get monthlyBudget => _monthlyBudget;
  double get totalSpent => _totalSpent;
  double get totalSavings => _totalSavings;
  double get savingsChange => _savingsChange;
  double get spentToday => _spentToday;
  double get avgPerDay => _avgPerDay;
  double get remaining => _monthlyBudget - _totalSpent;
  double get thisMonthSavings => _thisMonthSavings;
  double get lastMonthSavings => _lastMonthSavings;
  double get budgetProgress => _totalSpent / _monthlyBudget;

  String get formattedMonthlyBudget => '₹${_formatNumber(_monthlyBudget)}';
  String get formattedTotalSpent => '₹${_formatNumber(_totalSpent)}';
  String get formattedTotalSavings => '₹${_formatNumber(_totalSavings)}';
  String get formattedRemaining => '₹${_formatNumber(remaining)}';
  String get formattedSpentToday => '-₹${_formatNumber(_spentToday)}';
  String get formattedAvgPerDay => '₹${_formatNumber(_avgPerDay)}';
  String get formattedLeft => '+₹${_formatNumber(remaining)}';
  String get formattedThisMonthSavings => '₹${_formatNumber(_thisMonthSavings)}';
  String get formattedLastMonthSavings => '₹${_formatNumber(_lastMonthSavings)}';
  String get formattedSavingsChange => '+${_savingsChange.toStringAsFixed(1)}%';
  String get formattedBudgetProgress => '${(budgetProgress * 100).toStringAsFixed(0)}%';

  String _formatNumber(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Color get progressColor {
    if (budgetProgress > 1) return Colors.red;
    if (budgetProgress > 0.8) return Colors.orange;
    return const Color(0xFF14B8A6);
  }

  // Methods to update data
  void updateBudget(double newBudget) {
    _monthlyBudget = newBudget;
    notifyListeners();
  }

  void addExpense(double amount, String category) {
    _totalSpent += amount;
    _spentToday += amount;
    _totalSavings -= amount;
    _thisMonthSavings -= amount;
    notifyListeners();
  }

  void addIncome(double amount) {
    _totalSavings += amount;
    _thisMonthSavings += amount;
    notifyListeners();
  }

  // New method to set all values at once (for loading from storage)
  void setAllValues({
    required double monthlyBudget,
    required double totalSpent,
    required double totalSavings,
    required double spentToday,
    required double avgPerDay,
    required double thisMonthSavings,
    required double lastMonthSavings,
  }) {
    _monthlyBudget = monthlyBudget;
    _totalSpent = totalSpent;
    _totalSavings = totalSavings;
    _spentToday = spentToday;
    _avgPerDay = avgPerDay;
    _thisMonthSavings = thisMonthSavings;
    _lastMonthSavings = lastMonthSavings;
    notifyListeners();
  }
}