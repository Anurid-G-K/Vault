import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/vault_navbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString("user_name") ?? "User";
    final email = prefs.getString("user_email");
    final phone = prefs.getString("user_phone");

    return {
      "name": name,
      "contact": email ?? phone ?? "",
    };
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),

      bottomNavigationBar: const VaultNavbar(
        selectedIndex: 3,
      ),

      body: SafeArea(
        child: FutureBuilder<Map<String, String>>(
          future: getUserData(),
          builder: (context, snapshot) {

            final name = snapshot.data?["name"] ?? "User";
            final contact = snapshot.data?["contact"] ?? "";

            return SingleChildScrollView(
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

                  /// PROFILE CARD (Centered)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2A30),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [

                          /// AVATAR
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            contact,
                            style: const TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Premium Member",
                              style: TextStyle(
                                color: Color(0xFF14B8A6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// STATS GRID
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.2,
                    children: const [

                      _StatCard(
                        label: "Total Savings",
                        value: "₹19,750",
                        trend: "+12.5% vs last month",
                      ),

                      _StatCard(
                        label: "Monthly Budget",
                        value: "₹45,000",
                        trend: "74% utilized",
                      ),

                      _StatCard(
                        label: "Auto-Pay",
                        value: "6",
                        trend: "4 to be paid",
                      ),

                      _StatCard(
                        label: "Linked Accounts",
                        value: "4",
                        trend: "2 banks, 2 cards",
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  /// MEMBERSHIP CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3D3E), Color(0xFF0A2D2E)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Premium Plan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Renews Dec 15, 2024",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Upgrade",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ACCOUNT SETTINGS
                  const Text(
                    "Account Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _settingItem("Edit Profile", Icons.person),
                  _settingItem("Linked Bank Accounts", Icons.account_balance),

                  const SizedBox(height: 24),

                  /// SECURITY
                  const Text(
                    "Security",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _settingItem("Change Password", Icons.lock),
                  _settingItem("Two-Factor Authentication", Icons.security),
                  _settingItem("Trusted Devices", Icons.devices),

                  const SizedBox(height: 30),

                  /// LOGOUT
                  Center(
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
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

  static Widget _settingItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF14B8A6)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white54, size: 16)
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;

  const _StatCard({
    required this.label,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(label,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 12)),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            trend,
            style: const TextStyle(
                color: Color(0xFF14B8A6), fontSize: 12),
          ),
        ],
      ),
    );
  }
}