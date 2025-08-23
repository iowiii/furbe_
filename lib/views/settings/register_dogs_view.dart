import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../services/inference_service.dart';
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

    // Show image source selection dialog
    final imageSource = await Get.dialog<ImageSource>(
      AlertDialog(
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
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFFE15C31)),
              title: const Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE15C31),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
              ),
              onPressed: () =>
                  Get.back(result: null), // return null when cancel
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (imageSource == null) return;

    _picking = true;
    var pickedFile = await _picker.pickImage(source: imageSource);
    _picking = false;
    if (pickedFile == null) return;

    await _showDogDialog(pickedFile);
  }

  Future<void> _showDogDialog(XFile initialFile) async {
    var pickedFile = initialFile;
    final dogNameController = TextEditingController();
    String? gender;
    String? selectedBreed;
    String detectedBreed = "Detecting...";

    final breeds = ["Shih Tzu", "Pug", "Pomeranian"];

    // Detect breed using AI
    try {
      final result = await InferenceService.detectBreed(pickedFile.path);
      detectedBreed =
          '${result['label']} (${(result['confidence'] * 100).toStringAsFixed(1)}%)';
      selectedBreed = result['label'];
    } catch (e) {
      detectedBreed = "Detection failed";
      // Don't auto-set selectedBreed, let user choose
    }

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
                StatefulBuilder(
                  builder: (context, setDialogState) => GestureDetector(
                    onTap: () async {
                      final newSource = await Get.dialog<ImageSource>(
                        AlertDialog(
                          title: const Text('Change Photo'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Camera'),
                                onTap: () =>
                                    Get.back(result: ImageSource.camera),
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Gallery'),
                                onTap: () =>
                                    Get.back(result: ImageSource.gallery),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (newSource != null) {
                        final newFile =
                            await _picker.pickImage(source: newSource);
                        if (newFile != null) {
                          pickedFile = newFile;
                          try {
                            final result = await InferenceService.detectBreed(
                                pickedFile.path);
                            detectedBreed =
                                '${result['label']} (${(result['confidence'] * 100).toStringAsFixed(1)}%)';
                            selectedBreed = result['label'];
                          } catch (e) {
                            detectedBreed = "Detection failed";
                          }
                          setDialogState(() {});
                        }
                      }
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(File(pickedFile.path)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE15C31),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setTextState) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Detected: $detectedBreed',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE15C31),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dogNameController,
                  decoration: InputDecoration(
                    labelText: 'Dog Name',
                    // label when not focused
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    // label when focused
                    floatingLabelStyle: const TextStyle(
                      color: Color(0xFFE15C31),
                      fontWeight: FontWeight.bold,
                    ),
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
                    // label when not focused
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    // label when focused
                    floatingLabelStyle: const TextStyle(
                      color: Color(0xFFE15C31),
                      fontWeight: FontWeight.bold,
                    ),
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
                StatefulBuilder(
                  builder: (context, setState) =>
                      DropdownButtonFormField<String>(
                    value: selectedBreed,
                    decoration: InputDecoration(
                      labelText: 'Breed (AI Detected)',
                      // label when not focused
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      // label when focused
                      floatingLabelStyle: const TextStyle(
                        color: Color(0xFFE15C31),
                        fontWeight: FontWeight.bold,
                      ),
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
                      setState(() {
                        selectedBreed = val;
                      });
                    },
                  ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Add',
                          style: TextStyle(color: Colors.white)),
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
        type: selectedBreed ?? breeds.first,
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
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.white,
                      ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              'Delete Dog',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              'Are you sure you want to delete ${dog.name}?',
                              style: const TextStyle(fontSize: 16),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Cancel Button
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFE15C31),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12), // spacing between buttons
                                  // Delete Button
                                  TextButton(
                                    onPressed: () => Get.back(result: true),
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFE15C31),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await auth.deleteDog(dog.id);
                            Get.snackbar(
                                'Deleted', '${dog.name} removed successfully');
                          } catch (e) {
                            Get.snackbar('Error', 'Failed to delete: $e');
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dog.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                Text(
                  dog.type.isNotEmpty ? dog.type : 'Unknown breed',
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
