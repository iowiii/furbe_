import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import 'home/home_view.dart';
import 'save/save_view.dart';
import 'profile/profile_view.dart';
import 'tips/tips_view.dart';
import '../widgets/bottom_nav_bar.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MainController());
    final pages = [
      const HomeView(),
      const SaveView(),
      const TipsView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: Obx(() => pages[c.currentIndex.value]),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
