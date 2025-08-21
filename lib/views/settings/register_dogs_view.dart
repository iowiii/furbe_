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
    String? selectedBreed;

    final breeds = ["Shih Tzu", "Pug", "Pomeranian"];

    final confirmed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: const Color(0xFFF4EDF4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Dog',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(File(pickedFile.path)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dogNameController,
                  decoration: InputDecoration(
                    labelText: 'Dog Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE15C31),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE15C31),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (val) => gender = val,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedBreed,
                  decoration: InputDecoration(
                    labelText: 'Breed',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE15C31),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: breeds.map((breed) {
                    return DropdownMenuItem(
                      value: breed,
                      child: Text(breed),
                    );
                  }).toList(),
                  onChanged: (val) {
                    selectedBreed = val;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFFE15C31)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE15C31),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Add', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      await auth.addDog(
        name: dogNameController.text.trim(),
        gender: gender ?? '',
        type: selectedBreed ?? 'unknown',
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
                      child: Icon(Icons.add, size: 40,color: Colors.white,),
                      backgroundColor: Color(0xFFE15C31),
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
                            title: const Text('Delete Dog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            content: Text('Are you sure you want to delete ${dog.name}?'),
                            actions: [
                              TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel', style: TextStyle(color: Color(0xFFE15C31)))),
                              TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete', style: TextStyle(color: Color(0xFFE15C31)))),
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
                const SizedBox(height: 4),
                Text(dog.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  dog.type.isNotEmpty ? dog.type : 'Unknown breed',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
