import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/data_controller.dart';
import '../../core/app_routes.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final auth = Get.find<DataController>();
  final ImagePicker _picker = ImagePicker();

  Future<void> _changeDogPhoto() async {
    // Ask user where to pick the photo
    final newSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Select Image Source',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFE15C31)),
                title: const Text('Camera'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFE15C31)),
                title: const Text('Gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE15C31),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (newSource != null) {
      final newFile = await _picker.pickImage(source: newSource);
      if (newFile != null) {
        final bytes = await newFile.readAsBytes();
        final base64Photo = base64Encode(bytes);

        // Update current dog's photo in your controller
        final dog = auth.currentDog.value;
        if (dog != null) {
          dog.photo = base64Photo;
          auth.updateDog(dog); // <-- implement updateDog in DataController
          setState(() {});
        }
      }
    }
  }

  void _nextDog() {
    final dogs = auth.userDogs;
    if (dogs.isEmpty) return;

    int currentIndex =
    dogs.indexWhere((d) => d.id == auth.currentDog.value?.id);
    currentIndex = (currentIndex + 1) % dogs.length;
    auth.setCurrentDog(dogs[currentIndex]);
  }

  void _prevDog() {
    final dogs = auth.userDogs;
    if (dogs.isEmpty) return;

    int currentIndex =
    dogs.indexWhere((d) => d.id == auth.currentDog.value?.id);
    currentIndex = (currentIndex - 1 + dogs.length) % dogs.length;
    auth.setCurrentDog(dogs[currentIndex]);
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
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        final dog = auth.currentDog.value;
        if (dog == null) {
          return const Center(child: Text('No dogs added yet'));
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (auth.userDogs.length > 1) //  Only show if multiple dogs
                    IconButton(icon: const Icon(Icons.arrow_left), onPressed: _prevDog),

                  // Avatar with edit icon
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: dog.photo.isNotEmpty
                            ? MemoryImage(base64Decode(dog.photo))
                            : null,
                        child: dog.photo.isEmpty
                            ? const Icon(Icons.pets, size: 80)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _changeDogPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE15C31),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (auth.userDogs.length > 1) // Only show if multiple dogs
                    IconButton(icon: const Icon(Icons.arrow_right), onPressed: _nextDog),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                dog.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gender field
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE15C31)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title inside the box
                        const Text(
                          "Gender",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dog.gender,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),


                  // Breed field
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE15C31)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Breed",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dog.type,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}
