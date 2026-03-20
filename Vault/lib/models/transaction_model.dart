// transaction_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Remove this incorrect import: import '../widgets/vault_navigator.dart';

class TransactionModel extends ChangeNotifier {
  static final TransactionModel _instance = TransactionModel._internal();
  factory TransactionModel() => _instance;
  TransactionModel._internal();

  List<Map<String, dynamic>> _transactions = [];

  List<Map<String, dynamic>> get transactions => List.unmodifiable(_transactions);

  // Load transactions from SharedPreferences
  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    String? transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      try {
        List<dynamic> decoded = jsonDecode(transactionsJson);
        _transactions = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        notifyListeners();
      } catch (e) {
        print('Error loading transactions: $e');
      }
    }
  }

  // Save transactions to SharedPreferences
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    String transactionsJson = jsonEncode(_transactions);
    await prefs.setString('transactions', transactionsJson);
  }

  // Add a new transaction
  Future<void> addTransaction({
    required String name,
    required int amount,
    required String category,
  }) async {
    DateTime now = DateTime.now();
    String timeString = _getTimeAgo(now);

    _transactions.insert(0, {
      'name': name,
      'amount': amount,
      'category': category,
      'time': timeString,
      'timestamp': now.millisecondsSinceEpoch,
    });

    // Keep only last 50 transactions
    if (_transactions.length > 50) {
      _transactions = _transactions.sublist(0, 50);
    }

    await _saveTransactions();
    notifyListeners();
  }

  // Get recent transactions (last 3 for home screen)
  List<Map<String, dynamic>> getRecentTransactions() {
    List<Map<String, dynamic>> sorted = List.from(_transactions);
    sorted.sort((a, b) {
      int timestampA = a['timestamp'] ?? 0;
      int timestampB = b['timestamp'] ?? 0;
      return timestampB.compareTo(timestampA);
    });
    return sorted.take(3).toList();
  }

  // Get all transactions (for transactions screen)
  List<Map<String, dynamic>> getAllTransactions() {
    List<Map<String, dynamic>> sorted = List.from(_transactions);
    sorted.sort((a, b) {
      int timestampA = a['timestamp'] ?? 0;
      int timestampB = b['timestamp'] ?? 0;
      return timestampB.compareTo(timestampA);
    });
    return sorted;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Group transactions by date for display
  Map<String, List<Map<String, dynamic>>> getGroupedTransactions() {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var tx in _transactions) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(tx['timestamp']);
      String dateKey;

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        dateKey = 'Today';
      } else if (difference.inDays == 1) {
        dateKey = 'Yesterday';
      } else if (difference.inDays < 7) {
        dateKey = '${difference.inDays} days ago';
      } else {
        dateKey = '${date.day}/${date.month}/${date.year}';
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }

    // Sort each group by timestamp
    grouped.forEach((key, list) {
      list.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
    });

    return grouped;
  }
}