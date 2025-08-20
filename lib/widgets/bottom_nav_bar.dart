import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MainController>();

    return Obx(
          () => BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        type: BottomNavigationBarType.fixed,
        currentIndex: c.currentIndex.value,
        onTap: (i) => c.changePage(i),
        selectedItemColor: const Color(0xFFE15C31),
        unselectedItemColor: const Color(0xFFE15C31),
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          _buildNavItem(Icons.home_outlined, "Home", 0, c),
          _buildNavItem(Icons.analytics, "Analysis", 1, c),
          _buildNavItem(Icons.screen_search_desktop_outlined, "Articles", 2, c),
          _buildNavItem(Icons.pets, "Profile", 3, c),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index, MainController c) {
    return BottomNavigationBarItem(
      icon: Obx(() {
        final isSelected = c.currentIndex.value == index;
        return Transform.translate(
          offset: Offset(0, isSelected ? -6 : 0),
          child: Icon(icon),
        );
      }),
      label: label,
    );
  }
}
