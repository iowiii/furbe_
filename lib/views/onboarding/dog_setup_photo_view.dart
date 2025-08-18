import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_routes.dart';
import '../../controllers/auth_controller.dart';

class DogSetupPhotoView extends StatefulWidget {
  final String dogName;
  final String dogGender;
  const DogSetupPhotoView({super.key, required this.dogName, required this.dogGender});

  @override
  State<DogSetupPhotoView> createState() => _DogSetupPhotoViewState();
}

class _DogSetupPhotoViewState extends State<DogSetupPhotoView> {
  File? _dogImage;
  final ImagePicker _picker = ImagePicker();
  final auth = Get.find<AuthController>();

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _dogImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _dogImage = File(pickedFile.path);
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _dogImage = null;
    });
  }

  Future<void> _finishSetup() async {
    await auth.addDog(
      name: widget.dogName,
      gender: widget.dogGender,
      type: 'unknown',
      info: '',
      photo: _dogImage?.path ?? '', // save path or convert to base64 if needed
    );
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Photo'),
        leading: BackButton(onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Upload your dog\'s profile picture', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),

            // Image preview
            if (_dogImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(
                    _dogImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removePhoto,
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: _takePhoto, child: const Text('Take Picture')),
                  const SizedBox(width: 16),
                  ElevatedButton(onPressed: _uploadPhoto, child: const Text('Upload Image')),
                ],
              ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _finishSetup,
              child: Text(_dogImage != null ? 'Finish' : 'Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
