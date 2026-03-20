import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vault/screens/penny_screen.dart';
import 'package:vault/screens/transactions_screen.dart';
import 'package:vault/screens/insights_screen.dart';
import '../widgets/vault_navbar.dart';
import 'package:provider/provider.dart';
import '../models/finance_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import 'package:home_widget/home_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentLanguage = 'english';
  late Map<String, List<Map<String, String>>> resourcesDB;

  @override
  void initState() {
    super.initState();
    _initResourcesDB();
    _loadSavedData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryModel>(context, listen: false).loadCategories();
    });
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load finance model data
    double? monthlyBudget = prefs.getDouble('monthlyBudget');
    double? totalSpent = prefs.getDouble('totalSpent');
    double? totalSavings = prefs.getDouble('totalSavings');
    double? spentToday = prefs.getDouble('spentToday');
    double? avgPerDay = prefs.getDouble('avgPerDay');
    double? thisMonthSavings = prefs.getDouble('thisMonthSavings');
    double? lastMonthSavings = prefs.getDouble('lastMonthSavings');

    if (monthlyBudget != null) {
      final finance = Provider.of<FinanceModel>(context, listen: false);
      finance.updateBudget(monthlyBudget);

      if (totalSpent != null && totalSavings != null && spentToday != null) {
        finance.setAllValues(
          monthlyBudget: monthlyBudget,
          totalSpent: totalSpent,
          totalSavings: totalSavings,
          spentToday: spentToday,
          avgPerDay: avgPerDay ?? 1080,
          thisMonthSavings: thisMonthSavings ?? 11750,
          lastMonthSavings: lastMonthSavings ?? 8000,
        );
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save finance model data
    final finance = Provider.of<FinanceModel>(context, listen: false);
    await prefs.setDouble('monthlyBudget', finance.monthlyBudget);
    await prefs.setDouble('totalSpent', finance.totalSpent);
    await prefs.setDouble('totalSavings', finance.totalSavings);
    await prefs.setDouble('spentToday', finance.spentToday);
    await prefs.setDouble('avgPerDay', finance.avgPerDay);
    await prefs.setDouble('thisMonthSavings', finance.thisMonthSavings);
    await prefs.setDouble('lastMonthSavings', finance.lastMonthSavings);
  }

  String _formatIndianNumber(int number) {
    String numStr = number.toString();
    if (numStr.length <= 3) return numStr;

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
      return '${buffer.toString()},$lastThree';
    }
    return lastThree;
  }

  String _formatCurrency(int amount) {
    return '₹${_formatIndianNumber(amount)}';
  }

  void _initResourcesDB() {
    resourcesDB = {
      'english': [
        {'title': 'Personal Finance Basics: Beginners Guide', 'source': 'Money Instructor', 'type': 'Video · 5 min', 'link': 'blog'},
        {'title': 'Stock Market Basics for Beginners', 'source': 'Zerodha Varsity', 'type': 'Course · Free', 'link': 'varsity'},
        {'title': 'Better Money Habits', 'source': 'Bank of America', 'type': 'Official Handbook', 'link': 'sebi'},
      ],
      'hindi': [
        {'title': '50/30/20 बजट नियम', 'source': 'NerdWallet हिंदी', 'type': 'लेख · 5 मिनट', 'link': 'blog-hi'},
        {'title': 'शेयर बाजार की बुनियादी बातें', 'source': 'Zerodha वर्सिटी', 'type': 'कोर्स · मुफ्त', 'link': 'varsity-hi'},
        {'title': 'SEBI निवेशक गाइड', 'source': 'SEBI', 'type': 'आधिकारिक हैंडबुक', 'link': 'sebi-hi'},
      ],
      'tamil': [
        {
          'title': 'Top 8 Money Management Tips in Tamil',
          'source': 'YouTube · Madhumitha',
          'type': 'Video',
          'link': 'tamil1'
        },
        {
          'title': 'Financial Management in Tamil',
          'source': 'Udemy Course',
          'type': 'Course · Free',
          'link': 'tamil2'
        },
        {
          'title': 'Top 6 Finance Doubts Answered in Tamil',
          'source': 'YouTube · Meghala',
          'type': 'Video',
          'link': 'tamil3'
        },
      ],

      'telugu': [
        {
          'title': 'Top 5 Assets That Can Make You Rich',
          'source': 'SumanTV Money',
          'type': 'Video',
          'link': 'telugu1'
        },
        {
          'title': 'Indian Economy & Financial System',
          'source': 'Testbook Article',
          'type': 'Article',
          'link': 'telugu2'
        },
        {
          'title': 'Best Financial Planning in Telugu',
          'source': 'SumanTV Finance',
          'type': 'Video',
          'link': 'telugu3'
        },
      ],
      'kannada': [
        {'title': '50/30/20 ಬಜೆಟ್ ನಿಯಮ', 'source': 'NerdWallet ಕನ್ನಡ', 'type': 'ಲೇಖನ · 5 ನಿಮಿಷಗಳು', 'link': 'blog-kn'},
        {'title': 'ಷೇರು ಮಾರುಕಟ್ಟೆ ಮೂಲಗಳು', 'source': 'Zerodha ವರ್ಸಿಟಿ', 'type': 'ಕೋರ್ಸ್ · ಉಚಿತ', 'link': 'varsity-kn'},
        {'title': 'SEBI ಹೂಡಿಕೆದಾರರ ಮಾರ್ಗದರ್ಶಿ', 'source': 'SEBI', 'type': 'ಅಧಿಕೃತ ಕೈಪಿಡಿ', 'link': 'sebi-kn'},
      ],
      'malayalam': [
        {'title': '50/30/20 ബജറ്റ് നിയമം', 'source': 'NerdWallet മലയാളം', 'type': 'ലേഖനം · 5 മിനിറ്റ്', 'link': 'blog-ml'},
        {'title': 'സ്റ്റോക്ക് മാർക്കറ്റ് അടിസ്ഥാനങ്ങൾ', 'source': 'Zerodha വാഴ്സിറ്റി', 'type': 'കോഴ്സ് · സൗജന്യം', 'link': 'varsity-ml'},
        {'title': 'SEBI നിക്ഷേപക ഗൈഡ്', 'source': 'SEBI', 'type': 'ഔദ്യോഗിക കൈപ്പുസ്തകം', 'link': 'sebi-ml'},
      ],
    };
  }

  List<Map<String, dynamic>> get topCategories {
    final categories = context.watch<CategoryModel>().categories;

    List<Map<String, dynamic>> sorted = List.from(categories);
    sorted.sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      bottomNavigationBar: const VaultNavbar(
        selectedIndex: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER WITH PENNY BUTTON IN SAME ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand
                  Row(
                    children: [
                      const Text(
                        "Vault",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
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
                      ),
                    ],
                  ),

                  // Header Actions with Penny Button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {

                          final finance = Provider.of<FinanceModel>(context, listen: false);
                          int percentage = (finance.budgetProgress * 100).toInt();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PennyPage(
                                percentage: percentage,
                              ),
                            ),
                          );

                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14B8A6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.smart_toy,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Penny",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      buildHeaderIcon(Icons.video_call),
                      const SizedBox(width: 10),
                      Stack(
                        children: [
                          buildHeaderIcon(Icons.notifications),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF1F2A30), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// MAIN FINANCE CARD
              buildFinanceCard(),

              const SizedBox(height: 20),

              /// RED ALERT PREDICTION CARD
              buildPredictionCard(),

              const SizedBox(height: 20),

              /// SMART CATEGORIES
              buildCategoriesSection(),

              const SizedBox(height: 20),

              /// FINANCIAL LITERACY SECTION
              buildFinancialLiteracySection(),

              const SizedBox(height: 20),

              /// RECENT TRANSACTIONS
              Consumer<TransactionModel>(
                builder: (context, transactionModel, child) {
                  return buildTransactionsSection(transactionModel);
                },
              ),
            ],
          ),
        ),
      ),
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
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget buildFinanceCard() {
    return Consumer<FinanceModel>(
      builder: (context, finance, child) {
        double remaining = finance.remaining;
        String remainingText = remaining < 0
            ? '₹${_formatIndianNumber(remaining.abs().toInt())}'
            : '₹${_formatIndianNumber(remaining.toInt())}';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2A30),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress stats
              Row(
                children: [
                  // Custom progress ring representation
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white12,
                              width: 8,
                            ),
                          ),
                        ),
                        Container(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            value: finance.budgetProgress.clamp(0.0, 1.0),
                            backgroundColor: Colors.transparent,
                            color: finance.progressColor,
                            strokeWidth: 8,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                finance.formattedBudgetProgress,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "used",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        buildProgressStat("Monthly Budget", '₹${_formatIndianNumber(finance.monthlyBudget.toInt())}'),
                        const SizedBox(height: 12),
                        buildProgressStat("Spent", '₹${_formatIndianNumber(finance.totalSpent.toInt())}'),
                        const SizedBox(height: 12),
                        _buildRemainingStat(finance),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Stats
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    buildQuickStat("Spent Today", '₹${_formatIndianNumber(finance.spentToday.toInt())}', isNegative: true),
                    buildQuickStat("Avg / Day", '₹${_formatIndianNumber(finance.avgPerDay.toInt())}'),
                    buildQuickStat(
                      remaining < 0 ? "Overspent" : "Left",
                      remainingText,
                      isNegative: remaining < 0,
                      isPositive: remaining > 0,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons with functionality
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showBudgetModal(context, finance),
                      child: buildActionButton(
                        label: "Set Budget",
                        color: const Color(0xFF1F2A30),
                        borderColor: const Color(0xFF14B8A6).withOpacity(0.3),
                        textColor: const Color(0xFF14B8A6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showExpenseModal(context, finance),
                      child: buildActionButton(
                        label: "Add Expense",
                        color: const Color(0xFF1F2A30),
                        borderColor: Colors.red.withOpacity(0.3),
                        textColor: Colors.redAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showPayModal(context, finance),
                      child: buildActionButton(
                        label: "Pay",
                        color: const Color(0xFF1F2A30),
                        borderColor: Colors.green.withOpacity(0.3),
                        textColor: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRemainingStat(FinanceModel finance) {
    double remaining = finance.remaining;
    bool isExceeding = remaining < 0;
    String label = isExceeding ? "Exceeding by" : "Remaining";
    String value = isExceeding
        ? '₹${_formatIndianNumber(remaining.abs().toInt())}'
        : '₹${_formatIndianNumber(remaining.toInt())}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isExceeding ? const Color(0xFFEF4444) : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.8,
          ),
        ),
      ],
    );
  }

  // Professional Budget Modal with improved UX and keyboard handling
  void _showBudgetModal(BuildContext context, FinanceModel finance) {
    final List<String> predefinedCategories = [
      'Food & Dining', 'Transport', 'Entertainment', 'Shopping', 'Bills', 'Health', 'Education', 'Other'
    ];

    Map<String, TextEditingController> categoryControllers = {};
    Map<String, TextEditingController> categoryNameControllers = {};

    for (var category in predefinedCategories) {
      var categories = Provider.of<CategoryModel>(context, listen: false).categories;

      var existing = categories.firstWhere(
            (c) => c['name'] == category,
        orElse: () => {'name': category, 'limit': 5000},
      );
      categoryControllers[category] = TextEditingController(
        text: (existing['limit'] as int).toString(),
      );
    }

    TextEditingController totalBudgetController = TextEditingController(
      text: finance.monthlyBudget.toString(),
    );

    List<String> customCategories = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Color(0xFF1F2A30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'back',
                        style: TextStyle(
                          color: Color(0xFF14B8A6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Set Monthly Budget",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const Divider(color: Colors.white24, height: 1),

              // Content - Using SingleChildScrollView with padding for keyboard
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Budget - Modern Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF14B8A6).withOpacity(0.15),
                              const Color(0xFF0B1215),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF14B8A6).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14B8A6).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Color(0xFF14B8A6),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Total Monthly Budget",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: totalBudgetController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                prefixStyle: const TextStyle(color: Color(0xFF14B8A6), fontSize: 24, fontWeight: FontWeight.bold),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: const Color(0xFF0B1215),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Category Budgets",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Predefined Categories - Modern Cards
                      ...predefinedCategories.map((category) {
                        IconData icon;
                        Color categoryColor;
                        switch (category) {
                          case 'Food & Dining':
                            icon = Icons.restaurant;
                            categoryColor = Colors.orange;
                            break;
                          case 'Transport':
                            icon = Icons.directions_car;
                            categoryColor = Colors.blue;
                            break;
                          case 'Entertainment':
                            icon = Icons.movie;
                            categoryColor = Colors.pink;
                            break;
                          case 'Shopping':
                            icon = Icons.shopping_bag;
                            categoryColor = Colors.purple;
                            break;
                          case 'Bills':
                            icon = Icons.receipt;
                            categoryColor = Colors.red;
                            break;
                          case 'Health':
                            icon = Icons.health_and_safety;
                            categoryColor = Colors.green;
                            break;
                          case 'Education':
                            icon = Icons.school;
                            categoryColor = Colors.teal;
                            break;
                          default:
                            icon = Icons.more_horiz;
                            categoryColor = Colors.grey;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                categoryColor.withOpacity(0.1),
                                const Color(0xFF0B1215),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: categoryColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                width: 110,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B1215),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: categoryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: TextField(
                                  controller: categoryControllers[category],
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: categoryColor, fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    prefixText: '₹ ',
                                    prefixStyle: TextStyle(color: categoryColor, fontSize: 12),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Custom Categories
                      if (customCategories.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          "Custom Categories",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...customCategories.asMap().entries.map((entry) {
                          int index = entry.key;
                          String category = entry.value;
                          if (!categoryControllers.containsKey(category)) {
                            categoryControllers[category] = TextEditingController(text: '3000');
                          }
                          if (!categoryNameControllers.containsKey(category)) {
                            categoryNameControllers[category] = TextEditingController(text: category);
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.withOpacity(0.1),
                                  const Color(0xFF0B1215),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.teal.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.add_box, color: Colors.teal, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: categoryNameControllers[category],
                                        style: const TextStyle(color: Colors.white, fontSize: 15),
                                        decoration: InputDecoration(
                                          hintText: "Category name",
                                          hintStyle: const TextStyle(color: Colors.white38),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          customCategories.removeAt(index);
                                          categoryControllers.remove(category);
                                          categoryNameControllers.remove(category);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const SizedBox(width: 54),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0B1215),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.teal.withOpacity(0.3),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: categoryControllers[category],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
                                          decoration: InputDecoration(
                                            prefixText: '₹ ',
                                            prefixStyle: const TextStyle(color: Colors.teal, fontSize: 12),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 16),

                      // Add Category Button - Modern Design
                      GestureDetector(
                        onTap: () {
                          String newCategory = 'Custom ${customCategories.length + 1}';
                          setState(() {
                            customCategories.add(newCategory);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF14B8A6).withOpacity(0.1),
                                const Color(0xFF0B1215),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF14B8A6).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, color: Color(0xFF14B8A6), size: 22),
                              SizedBox(width: 8),
                              Text(
                                "Add Custom Category",
                                style: TextStyle(
                                  color: Color(0xFF14B8A6),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Update total budget
                          double newTotalBudget = double.tryParse(totalBudgetController.text) ?? finance.monthlyBudget;
                          finance.updateBudget(newTotalBudget);

                          // Update category limits and names
                          setState(() {
                            // Update existing categories

                            var categories = Provider.of<CategoryModel>(context, listen:false).categories;
                            for (var category in categories) {
                              String catName = category['name'] as String;
                              if (categoryControllers.containsKey(catName)) {
                                double limit = double.tryParse(categoryControllers[catName]!.text) ?? 5000;
                                category['limit'] = limit.toInt();
                              }
                            }

                            // Add custom categories to allCategories with custom names
                            for (var catName in customCategories) {
                              if (categoryControllers.containsKey(catName)) {
                                String customName = categoryNameControllers.containsKey(catName)
                                    ? categoryNameControllers[catName]!.text
                                    : catName;
                                double limit = double.tryParse(categoryControllers[catName]!.text) ?? 3000;
                                Provider.of<CategoryModel>(context, listen:false).addCategory(customName, limit.toInt());
                              }
                            }
                          });

                          _saveData();
                          Navigator.pop(context);
                          _showSuccessImage(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF14B8A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Save Budget",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Improved Expense Modal with Chip-based category selection and keyboard handling
  void _showExpenseModal(BuildContext context, FinanceModel finance) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = "Food & Dining";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFF1F2A30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Add Expense",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Amount (₹)",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter amount",
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0B1215),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Category",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Chip-based category selection

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: context.watch<CategoryModel>().categories.map((category) {
                          String catName = category['name'] as String;
                          Color catColor = Color(category['color'] as int);
                          bool isSelected = selectedCategory == catName;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = catName;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? catColor.withOpacity(0.2) : const Color(0xFF0B1215),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected ? catColor : Colors.white24,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    IconData(category['icon'] as int, fontFamily: 'MaterialIcons'),
                                    color: isSelected ? catColor : Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    catName,
                                    style: TextStyle(
                                      color: isSelected ? catColor : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Description",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "e.g., Grocery store, Uber ride",
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0B1215),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          double amount = double.tryParse(amountController.text) ?? 0;
                          String description = descriptionController.text.isNotEmpty
                              ? descriptionController.text
                              : selectedCategory;

                          if (amount > 0) {

                            // Update category amount
                            Provider.of<CategoryModel>(context, listen: false).addExpense(selectedCategory, amount.toInt());

                            // Add to transaction model
                            final transactionModel = Provider.of<TransactionModel>(context, listen: false);
                            await transactionModel.addTransaction(
                              name: description,
                              amount: amount.toInt(),
                              category: selectedCategory,
                            );

                            finance.addExpense(amount, selectedCategory);
                            _saveData();

                            // Close the modal first
                            Navigator.pop(context);

                            // Small delay to ensure modal is closed before showing success image
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _showSuccessImage(context);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF14B8A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Add Expense",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPayModal(BuildContext context, FinanceModel finance) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController recipientController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF1F2A30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Make Payment",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Amount (₹)",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter amount",
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0B1215),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Recipient",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: recipientController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter recipient name/UPI ID",
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0B1215),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          double amount = double.tryParse(amountController.text) ?? 0;
                          String recipient = recipientController.text.isNotEmpty
                              ? recipientController.text
                              : "Payment";

                          if (amount > 0) {
                            // Add to transaction model
                            final transactionModel = Provider.of<TransactionModel>(context, listen: false);
                            await transactionModel.addTransaction(
                              name: 'Payment to $recipient',
                              amount: amount.toInt(),
                              category: 'Transfer',
                            );

                            finance.addExpense(amount, "Other");
                            _saveData();

                            // Close the modal first
                            Navigator.pop(context);

                            // Small delay to ensure modal is closed before showing success image
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _showSuccessImage(context);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF14B8A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Send",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessImage(BuildContext context) {
    final List<String> images = [
      "you_are_good_to_go.png",
      "done.png",
      "noted.png",
      "all_set.png",
      "taken_care_of.png",
      "I_got_u.png",
    ];

    final random = Random();
    final randomImage = images[random.nextInt(images.length)];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2A30),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Center(
              child: Image.asset(
                'assets/icons/$randomImage',
                width: 340,
                height: 340,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF14B8A6),
                      size: 180,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildProgressStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.8,
          ),
        ),
      ],
    );
  }

  Widget buildQuickStat(String label, String value,
      {bool isNegative = false, bool isPositive = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isNegative
                  ? const Color(0xFFEF4444)
                  : isPositive
                  ? const Color(0xFF10B981)
                  : Colors.white70,
              fontSize: 16.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton({
    required String label,
    required Color color,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildPredictionCard() {
    return Consumer<FinanceModel>(
      builder: (context, finance, child) {
        double exceedingAmount = finance.totalSpent - finance.monthlyBudget;
        bool isExceeding = exceedingAmount > 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InsightsScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isExceeding
                  ? Colors.red.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isExceeding
                    ? const Color(0xFFEF4444).withOpacity(0.3)
                    : const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExceeding
                      ? "Exceeding budget by ₹${_formatIndianNumber(exceedingAmount.abs().toInt())}"
                      : "You're within budget!",
                  style: TextStyle(
                    color: isExceeding ? Colors.redAccent : Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "View detailed analysis",
                      style: TextStyle(
                        color: isExceeding ? Colors.redAccent : Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: isExceeding ? Colors.redAccent : Colors.greenAccent,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Top Spending",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                _showAllCategoriesModal(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF14B8A6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Top 3 Category Items - Dynamically updated
        ...topCategories.map((category) => buildCategoryItem(
          category['name'] as String,
          category['amount'] as int,
          category['limit'] as int,
          Color(category['color'] as int),
        )),
      ],
    );
  }

  void _showAllCategoriesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFF1F2A30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "All Categories",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(color: Colors.white24, height: 1),

// Category List
              Expanded(
                child: Consumer<CategoryModel>(
                  builder: (context, categoryModel, child) {
                    final categories = categoryModel.categories;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        var category = categories[index];
                        int amount = category['amount'] as int;
                        int limit = category['limit'] as int;
                        double percent = limit == 0 ? 0 : amount / limit;
                        int percentValue = (percent * 100).round();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1215),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(category['color'] as int).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  IconData(
                                    category['icon'] as int,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  color: Color(category['color'] as int),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category['name'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Spent: ${_formatCurrency(amount)} of ${_formatCurrency(limit)}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(category['color'] as int).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$percentValue%',
                                  style: TextStyle(
                                    color: Color(category['color'] as int),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget buildCategoryItem(String name, int amount, int limit, Color color) {
    double percent = limit == 0 ? 0 : amount / limit;
    int percentValue = (percent * 100).round();

    // For bar width, use the actual percentage but cap at 100% for visual representation
    // This ensures the bar fills completely at 100% and stays full beyond that
    double barPercent = percent.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _formatCurrency(amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentValue%',
                    style: TextStyle(
                      color: percent > 1 ? Colors.redAccent : Colors.white54,
                      fontSize: 13,
                      fontWeight: percent > 1 ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * 1 * barPercent,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Budget: ${_formatCurrency(limit)}',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFinancialLiteracySection() {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Financial Literacy",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Language Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildLanguagePill("English", isActive: currentLanguage == 'english', onTap: () => _switchLanguage('english')),
                buildLanguagePill("हिन्दी", isActive: currentLanguage == 'hindi', onTap: () => _switchLanguage('hindi')),
                buildLanguagePill("தமிழ்", isActive: currentLanguage == 'tamil', onTap: () => _switchLanguage('tamil')),
                buildLanguagePill("తెలుగు", isActive: currentLanguage == 'telugu', onTap: () => _switchLanguage('telugu')),
                buildLanguagePill("ಕನ್ನಡ", isActive: currentLanguage == 'kannada', onTap: () => _switchLanguage('kannada')),
                buildLanguagePill("മലയാളം", isActive: currentLanguage == 'malayalam', onTap: () => _switchLanguage('malayalam')),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Featured Resource (only for English)
          if (currentLanguage == 'english')
            GestureDetector(
              onTap: () => _openResource('featured'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F3D3E),
                      Color(0xFF0A2D2E)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Animated background pattern effect
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "FEATURED",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Beginner's Guide to Personal Finance (Zerodha Varsity)",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Watch now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Resources List
          ...resourcesDB[currentLanguage]!.map((resource) => GestureDetector(
            onTap: () => _openResource(resource['link']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2A30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              resource['source']!,
                              style: TextStyle(
                                color: const Color(0xFF14B8A6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: Colors.white54,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              resource['type']!,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF14B8A6),
                    size: 16,
                  ),
                ],
              ),
            ),
          )),

          const SizedBox(height: 16),

          // CDSL Footer
          GestureDetector(
            onTap: () => _openCDSL(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2A30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF14B8A6).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Free investor education in 12 languages by CDSL IPF",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    "cdslipf.com →",
                    style: TextStyle(
                      color: const Color(0xFF14B8A6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _switchLanguage(String lang) {
    setState(() {
      currentLanguage = lang;
    });
  }

  void _openResource(String type) async {
    Map<String, String> resources = {
      'tamil1': 'https://www.youtube.com/watch?v=PEvN9xcexXQ',
      'tamil2': 'https://www.udemy.com/course/financial-management-in-tamil/',
      'tamil3': 'https://www.youtube.com/watch?v=dqgYzl2MUVw',

      'telugu1': 'https://www.youtube.com/watch?v=EiIaL0QHL9w',
      'telugu2': 'https://testbook.com/objective-questions/te/mcq-on-indian-economy-indian-financial-system-ie-ifs--6874d939860bcbaf72f1ad54',
      'telugu3': 'https://www.youtube.com/watch?v=dqgYzl2MUVw',
      'blog': 'https://www.youtube.com/watch?v=WiH2T933xn8',
      'varsity': 'https://zerodha.com/varsity/',
      'sebi': 'https://bettermoneyhabits.bankofamerica.com',
      'ebook': 'https://www.nefe.org/initiatives/cashcourse.aspx',
      'featured': 'https://www.youtube.com/watch?v=6sq2o1atWLY',

      'blog-hi': 'https://hindi.nerdwallet.com',
      'varsity-hi': 'https://zerodha.com/varsity-hi/',
      'sebi-hi': 'https://www.sebi.gov.in/hindi/',
      'ebook-hi': 'https://www.finmin.nic.in/hindi/investor-awareness',

      'blog-ta': 'https://tamil.nerdwallet.com',
      'varsity-ta': 'https://zerodha.com/varsity-ta/',
      'sebi-ta': 'https://www.sebi.gov.in/tamil/',
      'ebook-ta': 'https://www.finmin.nic.in/tamil/investor-awareness',

      'blog-te': 'https://telugu.nerdwallet.com',
      'varsity-te': 'https://zerodha.com/varsity-te/',
      'sebi-te': 'https://www.sebi.gov.in/telugu/',
      'ebook-te': 'https://www.finmin.nic.in/telugu/investor-awareness',

      'blog-kn': 'https://kannada.nerdwallet.com',
      'varsity-kn': 'https://zerodha.com/varsity-kn/',
      'sebi-kn': 'https://www.sebi.gov.in/kannada/',
      'ebook-kn': 'https://www.finmin.nic.in/kannada/investor-awareness',

      'blog-ml': 'https://malayalam.nerdwallet.com',
      'varsity-ml': 'https://zerodha.com/varsity-ml/',
      'sebi-ml': 'https://www.sebi.gov.in/malayalam/',
      'ebook-ml': 'https://www.finmin.nic.in/malayalam/investor-awareness'
    };

    if (resources.containsKey(type)) {
      final url = Uri.parse(resources[type]!);

      try {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening link: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _openCDSL() async {
    final url = Uri.parse('https://www.cdslindia.com/ipf.aspx');

    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildLanguagePill(String label, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF14B8A6).withOpacity(0.15)
              : const Color(0xFF1F2A30),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive
                ? const Color(0xFF14B8A6)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? const Color(0xFF14B8A6)
                : Colors.white70,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildTransactionsSection(TransactionModel transactionModel) {
    // Get recent transactions (last 3)
    List<Map<String, dynamic>> displayTransactions = transactionModel.getRecentTransactions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Recent Activity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "See All",
                  style: TextStyle(
                    color: Color(0xFF14B8A6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Transaction Items - Dynamic from user actions
        if (displayTransactions.isEmpty)
          Container(
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
          )
        else
          ...displayTransactions.map((tx) => buildTransactionItem(
            tx['name'] as String,
            tx['amount'] as int,
            tx['category'] as String,
            tx['time'] as String,
          )),
      ],
    );
  }

  Widget buildTransactionItem(String name, int amount, String category,
      String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '-${_formatCurrency(amount)}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}