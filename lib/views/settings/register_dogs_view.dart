import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import 'package:image_picker/image_picker.dart';

class RegisteredDogsView extends StatefulWidget {
  const RegisteredDogsView({super.key});

  @override
  State<RegisteredDogsView> createState() => _RegisteredDogsViewState();
}

class _RegisteredDogsViewState extends State<RegisteredDogsView> {
  final auth = Get.find<DataController>();
  final ImagePicker _picker = ImagePicker();
  bool _picking = false;
  String? _dogGender;

  Future<void> _addDog() async {
    if (auth.currentPhone == null || auth.appUser.value == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    if (_picking) return;
    _picking = true;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    _picking = false;
    if (pickedFile == null) return;

    final dogNameController = TextEditingController();
    String? gender;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Add Dog'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 50, backgroundImage: FileImage(File(pickedFile.path))),
            const SizedBox(height: 12),
            TextField(
              controller: dogNameController,
              decoration: const InputDecoration(labelText: 'Dog Name'),
            ),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: (val) => gender = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Add')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await auth.addDog(
        name: dogNameController.text.trim(),
        gender: gender ?? '',
        type: 'unknown',
        info: '',
        photoPath: pickedFile.path,
      );

      await auth.loadAppUser(auth.currentPhone!);
      Get.snackbar('Success', 'Dog added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add dog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registered Dogs')),
      body: Obx(() {
        if (auth.currentPhone == null || auth.appUser.value == null) {
          return const Center(child: Text('Loading user...'));
        }
        print('Current phone: ${auth.currentPhone}');
        print('AppUser: ${auth.appUser.value}');


        final dogs = auth.userDogs;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: dogs.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (_, index) {
            if (index == dogs.length) {
              return GestureDetector(
                onTap: _addDog,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.add, size: 40),
                    ),
                    SizedBox(height: 8),
                    Text('Add Dog'),
                  ],
                ),
              );
            }

            final dog = dogs[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: dog.photo.isNotEmpty
                          ? MemoryImage(base64Decode(dog.photo))
                          : null,
                      child: dog.photo.isEmpty
                          ? const Icon(Icons.pets, size: 80)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Delete Dog'),
                            content: Text('Are you sure you want to delete ${dog.name}?'),
                            actions: [
                              TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await auth.deleteDog(dog.id);
                            Get.snackbar('Deleted', '${dog.name} removed successfully');
                          } catch (e) {
                            Get.snackbar('Error', 'Failed to delete: $e');
                          }
                        }
                      },
                    ),
                  ],
                ),
                Text(dog.name),
              ],
            );
          },
        );
      }),
    );
  }
}
