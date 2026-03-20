import 'package:flutter/material.dart';
import '../widgets/vault_navbar.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/finance_model.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedCategory = 'all';
  int _touchedPieIndex = -1;

  static const List<Color> _categoryColors = [
    Color(0xFFFF6B6B), // Bright Red
    Color(0xFF4ECDC4), // Turquoise
    Color(0xFFFFD166), // Golden Yellow
    Color(0xFF9B87F8), // Lavender
    Color(0xFFFF9F1C), // Orange
    Color(0xFF2EC4B6), // Teal
    Color(0xFFE76F51), // Coral
    Color(0xFF8A89C0), // Purple
    Color(0xFF6B4E71), // Plum
    Color(0xFF4A8FE4), // Bright Blue
  ];

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

  String _formatAmountShort(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      bottomNavigationBar: const VaultNavbar(
        selectedIndex: 1,
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
                      buildHeaderIcon(Icons.video_call),
                      const SizedBox(width: 10),
                      buildHeaderIcon(Icons.notifications),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 26),

              /// BUDGET VS EXPENDITURE
              Consumer<CategoryModel>(
                builder: (context, categoryModel, child) {
                  return buildInsightCard(
                    title: "Budget vs Expenditure",
                    showFilter: true,
                    filterValue: _selectedCategory,
                    onFilterChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    filterItems: [
                      {'value': 'all', 'label': 'All Categories'},
                      ...categoryModel.categories.map((c) => {
                        'value': c['name'].toString().toLowerCase().replaceAll(' & ', '_').replaceAll(' ', '_'),
                        'label': c['name'].toString(),
                      }),
                    ],
                    showLegend: true,
                    legendItems: const [
                      {'label': 'Budget', 'color': Color(0xFFFF6B6B)},
                      {'label': 'Expenditure', 'color': Color(0xFF4ECDC4)},
                    ],
                    child: SizedBox(
                      height: 280,
                      child: _buildBarChart(categoryModel.categories, _selectedCategory),
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              /// EXPENSE DISTRIBUTION
              Consumer<CategoryModel>(
                builder: (context, categoryModel, child) {
                  return buildInsightCard(
                    title: "Expense Distribution",
                    showLegend: false,
                    child: _buildPieChart(categoryModel.categories),
                  );
                },
              ),

              const SizedBox(height: 22),

              /// CATEGORY SPENDING
              buildInsightCard(
                title: "Category Spending",
                showLegend: true,
                legendItems: const [
                  {'label': 'Spent vs Budget', 'color': Color(0xFF14B8A6)},
                ],
                child: Consumer<CategoryModel>(
                  builder: (context, categoryModel, child) {
                    final categories = categoryModel.categories;

                    return Column(
                      children: categories.map((category) {
                        return buildCategoryStat(
                          category['name'],
                          category['amount'],
                          category['limit'],
                          Color(category['color']),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> categories, String selectedCategory) {
    List<String> labels = [];
    List<double> budgetData = [];
    List<double> expenditureData = [];

    if (selectedCategory == 'all') {
      // Calculate total budget and expenditure across all categories
      int totalBudget = categories.fold(0, (sum, c) => sum + (c['limit'] as int));
      int totalExpenditure = categories.fold(0, (sum, c) => sum + (c['amount'] as int));

      labels = ['Total'];
      budgetData = [totalBudget.toDouble()];
      expenditureData = [totalExpenditure.toDouble()];
    } else {
      // Find the selected category
      var selectedCat = categories.firstWhere(
            (c) => c['name'].toString().toLowerCase().replaceAll(' & ', '_').replaceAll(' ', '_') == selectedCategory,
        orElse: () => categories.first,
      );

      labels = [selectedCat['name']];
      budgetData = [(selectedCat['limit'] as int).toDouble()];
      expenditureData = [(selectedCat['amount'] as int).toDouble()];
    }

    double maxBudget = budgetData.fold<double>(0, (max, val) => val > max ? val : max);
    double maxValue = maxBudget + 2000;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF1F2A30),
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String value = _formatCurrency(rod.toY.round());
              return BarTooltipItem(
                '${rodIndex == 0 ? "Budget" : "Expenditure"}\n$value',
                const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxValue / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCurrency(value.toInt()),
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                );
              },
              reservedSize: 50,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Colors.white38),
            bottom: BorderSide(color: Colors.white38),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.white.withOpacity(0.15), strokeWidth: 1);
          },
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: budgetData[0],
                color: const Color(0xFFFF6B6B),
                width: 34,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              BarChartRodData(
                toY: expenditureData[0],
                color: const Color(0xFF4ECDC4),
                width: 34,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> categories) {
    // Get categories with non-zero spending
    List<Map<String, dynamic>> nonZeroCategories = categories.where((c) => (c['amount'] as int) > 0).toList();
    nonZeroCategories.sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));

    List<String> labels = nonZeroCategories.map((c) => c['name'] as String).toList();
    List<double> data = nonZeroCategories.map((c) => (c['amount'] as int).toDouble()).toList();

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No expense data',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return Column(
      children: [
        // Pie chart - adaptable height based on number of categories
        SizedBox(
          height: data.length > 8 ? 280 : 240,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions) {
                      _touchedPieIndex = -1;
                      return;
                    }
                    if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                      _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    } else {
                      _touchedPieIndex = -1;
                    }
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: List.generate(data.length, (i) {
                final isTouched = i == _touchedPieIndex;
                final double fontSize = isTouched ? 14 : 11;
                final double radius = isTouched ? 110 : 100;

                return PieChartSectionData(
                  color: _categoryColors[i % _categoryColors.length],
                  value: data[i],
                  title: '${_formatAmountShort(data[i].toInt())}',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  titlePositionPercentageOffset: 0.55,
                  badgeWidget: isTouched
                      ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      labels[i],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  )
                      : null,
                  badgePositionPercentageOffset: 1.2,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Legend
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1215),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Wrap(
            spacing: 20,
            runSpacing: 16,
            children: List.generate(labels.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _categoryColors[i % _categoryColors.length],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    labels[i],
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatAmountShort(data[i].toInt()),
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget buildInsightCard({
    required String title,
    required Widget child,
    bool showLegend = false,
    bool showFilter = false,
    String filterValue = 'all',
    Function(String)? onFilterChanged,
    List<Map<String, dynamic>> filterItems = const [],
    List<Map<String, dynamic>> legendItems = const [],
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              if (showFilter)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1215),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF14B8A6).withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: filterValue,
                    dropdownColor: const Color(0xFF1F2A30),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF14B8A6)),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: filterItems.map((item) {
                      return DropdownMenuItem(
                        value: item['value'] as String,
                        child: Text(
                          item['label'] as String,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && onFilterChanged != null) {
                        onFilterChanged(value);
                      }
                    },
                  ),
                ),

              if (showLegend && !showFilter)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1215),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: legendItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item['label'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          child
        ],
      ),
    );
  }

  Widget buildCategoryStat(
      String name, int spent, int budget, Color color) {

    double percent = budget == 0 ? 0 : spent / budget;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              Text(
                '${_formatCurrency(spent)} of ${_formatCurrency(budget)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              )
            ],
          ),

          const SizedBox(height: 6),

          Stack(
            children: [

              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              FractionallySizedBox(
                widthFactor: percent > 1.0 ? 1.0 : percent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}