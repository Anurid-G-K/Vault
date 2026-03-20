import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'package:vault/screens/actions_screen.dart';
import 'package:vault/models/finance_model.dart';  // Make sure this path is correct
import 'package:vault/models/transaction_model.dart';
import 'package:vault/models/category_model.dart';

import 'package:home_widget/home_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize home screen widget system
  await HomeWidget.setAppGroupId('group.finman');

  // Pre-load transaction data
  final transactionModel = TransactionModel();
  await transactionModel.loadTransactions();

  runApp(VaultApp(transactionModel: transactionModel));
}

class VaultApp extends StatelessWidget {
  final TransactionModel transactionModel;

  const VaultApp({super.key, required this.transactionModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FinanceModel>(
          create: (context) => FinanceModel(),
        ),
        ChangeNotifierProvider<TransactionModel>.value(
          value: transactionModel,
        ),
        ChangeNotifierProvider<CategoryModel>(
          create: (context) => CategoryModel(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with TickerProviderStateMixin {
  bool? loggedIn;
  bool _showWelcomeAnimation = false;
  bool _showLoginForm = false;
  bool _showExtroAnimation = false;
  late AnimationController _slideController;
  late AnimationController _confettiController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Login controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoginMode = true;

  @override
  void initState() {
    super.initState();
    checkLogin();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _confettiController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getBool("logged_in") ?? false;

    setState(() {
      loggedIn = session;
    });

    if (!session) {
      // Trigger welcome animation after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showWelcomeAnimation = true;
          });
          _slideController.forward();
          _confettiController.forward();
        }
      });
    }
  }

  void _showLogin() {
    setState(() {
      _showLoginForm = true;
      _showWelcomeAnimation = false;
      _confettiController.reset();
    });
  }

  void _proceedToDetails() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save user data
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Save user data with defaults
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", true);
    await prefs.setString("user_email", emailController.text);
    await prefs.setString("user_name", "User");
    await prefs.setDouble("monthly_income", 50000);
    await prefs.setDouble("monthly_budget", 25000);

    // Initialize default categories
    List<String> defaultCategories = [
      'Food & Dining', 'Transport', 'Entertainment', 'Shopping', 'Bills'
    ];

    final categoryModel = Provider.of<CategoryModel>(context, listen: false);

    // Update finance model with default budget
    final financeModel = Provider.of<FinanceModel>(context, listen: false);
    financeModel.setAllValues(
      monthlyBudget: 25000,
      totalSpent: 0,
      totalSavings: 10000,
      spentToday: 0,
      avgPerDay: 0,
      thisMonthSavings: 10000,
      lastMonthSavings: 0,
    );

    // Show exit animation
    setState(() {
      _showLoginForm = false;
      _showExtroAnimation = true;
    });
  }

  void _continueFromExtro() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ActionsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loggedIn == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1215),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loggedIn == true) {
      return const ActionsScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: Stack(
        children: [
          // Background content
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: _showWelcomeAnimation || _showLoginForm || _showExtroAnimation
                ? ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: _buildWelcomeBackground(),
            )
                : _buildWelcomeBackground(),
          ),

          // Welcome Animation Overlay
          if (_showWelcomeAnimation)
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _showLogin,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Stack(
                    children: [
                      // Non-looping confetti (plays once)
                      if (_confettiController.isAnimating)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _confettiController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: SingleShotConfettiPainter(
                                    progress: _confettiController.value,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Penny character slide-in - 20% larger and 20% left
                      SlideTransition(
                        position: _slideAnimation,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 336,
                            height: 540,
                            margin: const EdgeInsets.only(left: 40),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/icons/intro_penny.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Professional text at bottom
                      Positioned(
                        bottom: 50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.3)),
                            ),
                            child: const Text(
                              'TAP ANYWHERE TO CONTINUE',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Login Form
          if (_showLoginForm)
            Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2A30).withOpacity(0.98),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFF14B8A6).withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLoginMode ? 'Sign in to continue' : 'Create your account',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email field
                      _buildProfessionalTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      _buildProfessionalTextField(
                        controller: passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 32),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _proceedToDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14B8A6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Toggle between login/signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLoginMode ? "Don't have an account? " : "Already have an account? ",
                            style: const TextStyle(color: Colors.white54),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode;
                              });
                            },
                            child: Text(
                              _isLoginMode ? 'Sign Up' : 'Sign In',
                              style: const TextStyle(
                                color: Color(0xFF14B8A6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Extro Animation Overlay (when completing onboarding)
          if (_showExtroAnimation)
            GestureDetector(
              onTap: _continueFromExtro,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Stack(
                  children: [
                    // Non-looping confetti (plays once)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: SingleShotConfettiPainter(
                            progress: 1.0,
                          ),
                        ),
                      ),
                    ),

                    // Extro Penny character
                    Center(
                      child: Container(
                        width: 336,
                        height: 540,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/icons/extro_penny.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Success text
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.3)),
                          ),
                          child: const Text(
                            'WELCOME TO VAULT!',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tap anywhere text
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'TAP ANYWHERE TO CONTINUE',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                              color: Colors.white70,
                            ),
                          ),
                        ),
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

  Widget _buildWelcomeBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1215),
            Color(0xFF1F2A30),
            Color(0xFF0F3D3E),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Vault",
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.8,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Control Your Money",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1215),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF14B8A6).withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF14B8A6), size: 20),
              hintText: label,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// Single-shot confetti painter (non-looping)
class SingleShotConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> _pieces = [];
  final Random _random = Random();

  SingleShotConfettiPainter({required this.progress}) {
    if (_pieces.isEmpty) {
      for (int i = 0; i < 30; i++) {
        _pieces.add(_ConfettiPiece(_random));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in _pieces) {
      final paint = Paint()..color = piece.color;

      double y = piece.startY - (progress * 300 * piece.speed);
      double x = piece.startX + (progress * 50 * piece.drift);

      if (y > 0 && y < size.height) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, piece.size, piece.size * 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => progress < 1.0;
}

class _ConfettiPiece {
  final double startX;
  final double startY;
  final double speed;
  final double drift;
  final double size;
  final Color color;

  _ConfettiPiece(Random random)
      : startX = 200 + random.nextDouble() * 200,
        startY = -50 + random.nextDouble() * 100,
        speed = 0.5 + random.nextDouble() * 1.5,
        drift = -0.5 + random.nextDouble(),
        size = 4 + random.nextDouble() * 8,
        color = Color.fromRGBO(
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
          0.8,
        );
}