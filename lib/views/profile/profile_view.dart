import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_routes.dart';
import 'dart:io';


class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final auth = Get.find<AuthController>();
  int currentDogIndex = 0;

  void _nextDog() {
    final dogs = auth.appUser.value?.dogs.values.toList() ?? [];
    if (dogs.isNotEmpty) {
      setState(() {
        currentDogIndex = (currentDogIndex + 1) % dogs.length;
      });
    }
  }

  void _prevDog() {
    final dogs = auth.appUser.value?.dogs.values.toList() ?? [];
    if (dogs.isNotEmpty) {
      setState(() {
        currentDogIndex = (currentDogIndex - 1 + dogs.length) % dogs.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final user = auth.appUser.value;
          return Text(user?.name ?? 'Profile');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.toNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = auth.appUser.value;
        if (user == null) {
          return const Center(child: Text('Not logged in'));
        }

        final dogs = auth.appUser.value?.dogs.values.toList() ?? [];
        final dog = dogs[currentDogIndex];

        if (dogs.isEmpty) {
          return const Center(child: Text('No dogs added yet'));
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (dogs.length > 1)
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: _prevDog,
                    ),

                  CircleAvatar(
                    radius: 80,
                    backgroundImage: dog.photo.isNotEmpty
                        ? MemoryImage(base64Decode(dog.photo))
                        : null,
                    child: dog.photo.isEmpty
                        ? const Icon(Icons.pets, size: 80)
                        : null,
                  ),

                  if (dogs.length > 1)
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: _nextDog,
                    ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                dog.name,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Gender: ${dog.gender}'),
              Text('Type: ${dog.type}'),
              Text('Info: ${dog.info}'),
            ],
          ),
        );
      }),
    );
  }
}
