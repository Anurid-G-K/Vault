import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class PennyPage extends StatefulWidget {

  final int percentage;

  const PennyPage({
    super.key,
    required this.percentage,
  });

  @override
  State<PennyPage> createState() => _PennyPageState();
}

class _PennyPageState extends State<PennyPage> {

  String currentState = "neutral";
  String pennyImage = "";

  int level = Random().nextInt(10) + 5;
  int xp = Random().nextInt(90) + 10;
  int streak = Random().nextInt(7) + 1;

  late List<int> evolutionLevels;
  late List<int> skinLevels;

  List<String> moodImages = [];
  int activeMoodIndex = 0;

  final List<String> skins = [
    "assets/icons/skins/skin1.jpeg",
    "assets/icons/skins/skin2.jpeg",
    "assets/icons/skins/skin3.jpeg",
    "assets/icons/skins/skin4.jpeg",
    "assets/icons/skins/skin5.jpeg",
  ];

  final List<String> evolutions = [
    "assets/icons/evolutions/evo1.png",
    "assets/icons/evolutions/evo2.png",
    "assets/icons/evolutions/evo3.png",
    "assets/icons/evolutions/evo4.png",
    "assets/icons/evolutions/evo5.png",
  ];

  @override
  void initState() {
    super.initState();
    determineState();
    generateLevels();
  }

  void generateLevels() {

    final rand = Random();

    evolutionLevels = [
      1,
      rand.nextInt(10) + 10,
      rand.nextInt(10) + 15,
      rand.nextInt(10) + 18,
      rand.nextInt(10) + 22,
    ];

    skinLevels = List.generate(
      skins.length,
          (index) => rand.nextInt(12) + 3,
    );
  }

  void determineState() {

    int p = widget.percentage;

    if (p <= 20) {
      currentState = "celebrate";
    }
    else if (p <= 40) {
      currentState = "happy";
    }
    else if (p <= 60) {
      currentState = "longtimenosee";
    }
    else if (p <= 80) {
      currentState = "neutral";
    }
    else {
      currentState = "hurt";
    }

    int maxImages = currentState == "longtimenosee" ? 3 : 6;

    moodImages = List.generate(
      maxImages,
          (index) => "assets/icons/$currentState/${index + 1}.png",
    );

    activeMoodIndex = 0;
    pennyImage = moodImages[0];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1215),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Penny",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
            child: const Text(
              "HOME",
              style: TextStyle(
                color: Color(0xFF14B8A6),
                fontWeight: FontWeight.bold,
              ),
            ),
          )

        ],
      ),

      body: Column(
        children: [

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {

              int day = index + 1;
              bool completed = day < streak;
              bool current = day == streak;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [

                    Icon(
                      current
                          ? Icons.local_fire_department
                          : Icons.circle,
                      color: current
                          ? Colors.orange
                          : Colors.grey,
                      size: current ? 20 : 10,
                    ),

                    const SizedBox(width: 3),

                    Text(
                      "$day",
                      style: TextStyle(
                        color: completed || current
                            ? Colors.white
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    )

                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          Container(
            height: 210,
            width: 210,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2A30),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Transform.scale(
                scale: 1.15,
                child: Image.asset(
                  pennyImage,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: moodImages.length,
              itemBuilder: (context, index) {

                bool active = index == activeMoodIndex;

                return GestureDetector(
                  onTap: () {

                    setState(() {

                      activeMoodIndex = index;
                      pennyImage = moodImages[index];

                    });

                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active
                            ? const Color(0xFF14B8A6)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      moodImages[index],
                      width: 42,
                    ),
                  ),
                );

              },
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "LEVEL $level",
            style: const TextStyle(
              color: Color(0xFF14B8A6),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: xp / 100,
                minHeight: 8,
                backgroundColor: Colors.white12,
                color: const Color(0xFF14B8A6),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "$xp / 100 XP",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 30),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  sectionTitle("Evolutions"),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: evolutions.length,
                      itemBuilder: (context, index) {

                        bool unlocked = true;

                        return itemCard(
                          evolutions[index],
                          unlocked,
                          evolutionLevels[index],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  sectionTitle("Skins"),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: skins.length,
                      itemBuilder: (context, index) {

                        bool unlocked = true;

                        return itemCard(
                          skins[index],
                          unlocked,
                          skinLevels[index],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                ],
              ),
            ),
          )

        ],
      ),
    );
  }

  Widget sectionTitle(String title) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }

  Widget itemCard(String image, bool unlocked, int requiredLevel) {

    return GestureDetector(

      onTap: () {

        if (unlocked) {
          setState(() {
            pennyImage = image;
          });
        }

      },

      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2A30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [

            Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                image,
                color: unlocked ? null : Colors.black54,
                colorBlendMode:
                unlocked ? null : BlendMode.darken,
              ),
            ),

            Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: unlocked
                      ? Colors.green
                      : Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  unlocked
                      ? "UNLOCKED"
                      : "LVL $requiredLevel",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}