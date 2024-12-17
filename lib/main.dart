import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:my_vocabulary/view/MainScreenBinding.dart';
import 'package:my_vocabulary/view/QuizScreen.dart';
import 'package:my_vocabulary/viewModel/Shared.dart';
import 'view/vocabulary_list_screen.dart';
import 'view/add_vocabulary_screen.dart';
import 'view/update_vocabulary_screen.dart';
import 'Bindings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => HomeScreen(),
          binding: VocabularyBinding(),
        ),
        GetPage(
          name: '/addVocabulary',
          page: () => AddVocabularyScreen(),
        ),
        GetPage(
          name: '/updateVocabulary',
          page: () => UpdateVocabularyScreen(vocab: Get.arguments),
        ),
      ],
    ),
  );
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 1;
  bool test = false ; 
  // Define the screens for navigation
  final List<Widget> screens = [
    VocabularyListScreen(), // Left button: Vocabulary list
    MainScreen(), // Center button: Main screen
    QuizScreen(), // Right button: Quiz screen
  ];

  @override
  Widget build(BuildContext context) {
    final GameStateController gameStateController = Get.find<GameStateController>();
    return Scaffold(
      extendBody: true, // Ensures content extends behind the navigation bar
      body: screens[currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: CrystalNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) async {
            print(gameStateController.isGameInProgress.value);
            // Prevent switching if the game is in progress
            if (gameStateController.isGameInProgress.value) {
              Get.snackbar(
                "Game in Progress",
                "Finish the game before switching screens.",
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            if (index == 2) { // 2 corresponds to QuizScreen
            final hasData = await gameStateController.checkData();
            if (!hasData) {
              Get.snackbar(
                "No Vocabulary",
                "Please add vocabulary before starting the quiz.",
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
          }
            setState(() {
              currentIndex = index;
            });
          },
          height: Get.height * 0.07, // Responsive height
          items: [
            CrystalNavigationBarItem(
              icon: Icons.list,
              unselectedIcon: Icons.list_alt,
              selectedColor: Colors.blue,
            ),
            CrystalNavigationBarItem(
              icon: Icons.home,
              unselectedIcon: Icons.home_outlined,
              selectedColor: Colors.green,
            ),
            CrystalNavigationBarItem(
              icon: Icons.quiz,
              unselectedIcon: Icons.quiz_outlined,
              selectedColor: Colors.purple,
            ),
          ],
          backgroundColor: Colors.black.withOpacity(0.1), // Transparent background
          unselectedItemColor: Colors.grey,
          enableFloatingNavBar: true,
          borderRadius: 20,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}


