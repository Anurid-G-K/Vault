import 'package:flutter/material.dart';
import '../widgets/vault_navbar.dart';
import '../models/finance_model.dart';
import '../models/transaction_model.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  String _formatCurrency(int amount) {
    String numStr = amount.toString();
    if (numStr.length <= 3) return '₹$numStr';

    String lastThree = numStr.substring(numStr.length - 3);
    String rest = numStr.substring(0, numStr.length - 3);

    if (rest.isNotEmpty) {
      StringBuffer buffer = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) {
          buffer.write(',');
        }
        buffer.write(rest[i]);
      }
      return '₹${buffer.toString()},$lastThree';
    }
    return '₹$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),

      bottomNavigationBar: const VaultNavbar(
        selectedIndex: 2,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Vault",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    ],
                  ),

                  Row(
                    children: [
                      _headerIcon(Icons.videocam),
                      const SizedBox(width: 10),
                      _headerIcon(Icons.notifications),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 24),

              /// SUMMARY CARD
              Consumer<FinanceModel>(
                builder: (context, finance, child) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2A30),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [

                        SizedBox(
                          width: 194,
                          height: 194,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [

                              /// BACKGROUND RING
                              SizedBox(
                                width: 194,
                                height: 194,
                                child: CircularProgressIndicator(
                                  value: 1,
                                  strokeWidth: 17,
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.white12,
                                  ),
                                ),
                              ),

                              /// PROGRESS RING (color changes with percentage)
                              SizedBox(
                                width: 194,
                                height: 194,
                                child: CircularProgressIndicator(
                                  value: finance.budgetProgress.clamp(0.0, 1.0),
                                  strokeWidth: 17,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation(
                                    finance.progressColor,
                                  ),
                                ),
                              ),

                              /// CENTER TEXT
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    finance.formattedTotalSpent,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    "of ${finance.formattedMonthlyBudget}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      Text(
                                        "${(finance.budgetProgress * 100).toStringAsFixed(0)}% Used",
                                        style: TextStyle(
                                          color: finance.progressColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      if (finance.budgetProgress >= 0.9) ...[
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: finance.budgetProgress > 1 ? Colors.red : Colors.orange,
                                          size: 20,
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// QUICK STATS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _QuickStat(
                              label: "Today's Spending",
                              value: finance.formattedSpentToday,
                              color: Colors.red,
                            ),
                            _QuickStat(
                              label: "Amount Left",
                              value: finance.formattedLeft,
                              color: Colors.green,
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              /// SECTION HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Transaction History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Text("+", style: TextStyle(color: Colors.white)),
                        SizedBox(width: 4),
                        Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// TRANSACTIONS
              Consumer<TransactionModel>(
                builder: (context, transactionModel, child) {
                  var groupedTransactions = transactionModel.getGroupedTransactions();

                  if (groupedTransactions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2A30),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text(
                          "No transactions yet",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  // Convert map entries to list and sort by date (most recent first)
                  var sortedEntries = groupedTransactions.entries.toList()
                    ..sort((a, b) {
                      // Custom sorting for date keys
                      int getPriority(String key) {
                        if (key == 'Today') return 0;
                        if (key == 'Yesterday') return 1;
                        if (key.contains('days ago')) return 2;
                        return 3; // Specific dates
                      }

                      int priorityA = getPriority(a.key);
                      int priorityB = getPriority(b.key);

                      if (priorityA != priorityB) {
                        return priorityA.compareTo(priorityB);
                      }

                      // If both are specific dates, sort by timestamp of first transaction in group
                      if (priorityA == 3) {
                        int timestampA = a.value.isNotEmpty ? (a.value.first['timestamp'] ?? 0) : 0;
                        int timestampB = b.value.isNotEmpty ? (b.value.first['timestamp'] ?? 0) : 0;
                        return timestampB.compareTo(timestampA);
                      }

                      return 0;
                    });

                  return Column(
                    children: sortedEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildTransactionGroup(entry.key, entry.value),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionGroup(String date, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2A30),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: transactions.map((tx) {
              return _buildTransactionItem(tx);
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    // Safely extract values with type checking
    String name = tx['name']?.toString() ?? 'Unknown';
    String category = tx['category']?.toString() ?? '';
    String time = tx['time']?.toString() ?? '';
    int amount = 0;

    if (tx['amount'] is int) {
      amount = tx['amount'] as int;
    } else if (tx['amount'] is double) {
      amount = (tx['amount'] as double).toInt();
    } else if (tx['amount'] is String) {
      amount = int.tryParse(tx['amount'] as String) ?? 0;
    }

    return ListTile(
      title: Row(
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white),
          ),
          if (category.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: const TextStyle(
                    color: Color(0xFF14B8A6),
                    fontSize: 10
                ),
              ),
            )
        ],
      ),
      subtitle: time.isNotEmpty
          ? Text(time, style: const TextStyle(color: Colors.white54))
          : null,
      trailing: Text(
        '-${_formatCurrency(amount)}',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  static Widget _headerIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 20),
        )
      ],
    );
  }
}