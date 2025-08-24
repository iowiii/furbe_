import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_routes.dart';
import '../../controllers/data_controller.dart';
import '../../services/inference_service.dart';

class DogSetupPhotoView extends StatefulWidget {
  final String dogName;
  final String dogGender;
  final String dogBreed;

  const DogSetupPhotoView({
    super.key,
    required this.dogName,
    required this.dogGender,
    required this.dogBreed,
  });

  @override
  State<DogSetupPhotoView> createState() => _DogSetupPhotoViewState();
}


class _DogSetupPhotoViewState extends State<DogSetupPhotoView> {
  File? _dogImage;
  final ImagePicker _picker = ImagePicker();
  final auth = Get.find<DataController>();
  bool _isDetecting = false;
  String? _detectedBreed;

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _dogImage = File(pickedFile.path);
      });
      await _detectBreed();
    }
  }

  Future<void> _uploadPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _dogImage = File(pickedFile.path);
      });
      await _detectBreed();
    }
  }
  
  Future<void> _detectBreed() async {
    if (_dogImage == null) return;
    
    setState(() {
      _isDetecting = true;
    });
    
    try {
      final result = await InferenceService.detectBreed(_dogImage!.path);
      setState(() {
        _detectedBreed = result['label'];
        _isDetecting = false;
      });
      
      if (_detectedBreed != null && _detectedBreed != 'Unknown') {
        Get.snackbar(
          'Breed Detected', 
          'Detected: $_detectedBreed\nYou can override this if incorrect.',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() {
        _isDetecting = false;
      });
      Get.snackbar('Error', 'Failed to detect breed: $e');
    }
  }

  void _removePhoto() {
    setState(() {
      _dogImage = null;
      _detectedBreed = null;
    });
  }

  Future<void> _finishSetup() async {
    if (_dogImage == null) {
      Get.snackbar('Error', 'Please select a dog image');
      return;
    }

    // Show loading dialog
    Get.dialog(
      Center(
        child: CircularProgressIndicator(
          color: Colors.grey.shade100, // spinner color matches your theme
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Use detected breed if available, otherwise use manually selected breed
      final finalBreed = _detectedBreed ?? widget.dogBreed;

      await auth.addDog(
        name: widget.dogName,
        gender: widget.dogGender,
        type: finalBreed,
        info: '',
        photoPath: _dogImage?.path ?? '',
      );

      if (auth.currentPhone != null) {
        await auth.loadAppUser(auth.currentPhone!);
      }

      Get.back(); // close loading dialog
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Get.back(); // close loading dialog
      Get.snackbar('Error', 'Failed to add dog: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Upload your dog\'s\nprofile picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            if (_dogImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _dogImage!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_isDetecting)
                    const Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: LinearProgressIndicator(),
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
                  _imageButton(Icons.camera_alt, 'Take picture', _takePhoto),
                  const SizedBox(width: 16),
                  _imageButton(Icons.upload, 'Upload image', _uploadPhoto),
                ],
              ),

            if (_detectedBreed != null && _detectedBreed != 'Unknown')
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Detected Breed: $_detectedBreed',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'This will override your manual selection',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE15C31),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _finishSetup,
                child: Text(
                  _dogImage != null ? 'Finish' : 'Skip',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE15C31),
        side: const BorderSide(color: Color(0xFFE15C31)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
