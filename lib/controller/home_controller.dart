import 'package:flutter/material.dart';
import '../views/home_page.dart';
import '../views/save_page.dart';
import '../views/profile_page.dart';
import '../views/settings_page.dart';

class HomeController extends StatefulWidget {
  const HomeController({super.key});

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    SaveView(),
    ProfileView(),
    SettingsView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE0D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAE0D1),
        centerTitle: true,
        elevation: 0,
        title: Container(
          width: 350,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFF914D),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            ['Home', 'Saved', 'Profile', 'Settings'][_currentIndex],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),



      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final isSelected = index == _currentIndex;
            final labels = ['Home', 'Saves', 'Profile', 'Setting'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  top: isSelected ? 0 : 10,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.5,
                  vertical: isSelected ? 28 : 24,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF914D) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [],
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}