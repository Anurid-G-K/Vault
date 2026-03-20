import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/screens/home_screen.dart';

class ActionsScreen extends StatelessWidget {
  const ActionsScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
          (route) => false,
    );
  }

  Future<String> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString("user_name");

    return name ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),

      body: FutureBuilder<String>(
        future: getUser(),
        builder: (context, snapshot) {

          final username = snapshot.data ?? "User";

          return SingleChildScrollView(
            child: Column(
              children: [

                /// PUSH CONTENT DOWN BY 10%
                SizedBox(height: screenHeight * 0.10),

                /// BUTTON ROW
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// LOGOUT BUTTON
                      GestureDetector(
                        onTap: () => logout(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2A30),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.logout, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// HOME BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14B8A6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.home, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                "Home",
                                style: TextStyle(
                                  color: Colors.white,
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

                const SizedBox(height: 30),

                /// HAPPY PENNY IMAGE
                SizedBox(
                  height: screenHeight * 0.30,
                  width: double.infinity,
                  child: Image.asset(
                    "assets/icons/happy_penny.png",
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),

                /// USER GREETING
                Text(
                  "Welcome $username",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Your actions will appear here",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}