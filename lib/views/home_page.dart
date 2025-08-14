import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../controller/model_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  CameraController? _cameraController;
  final ModelController _modelController = ModelController();

  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  String _breed = "no dog";
  String _mood = "no dog";
  String? _gifPath = 'assets/images/nice.gif';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController?.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }

      // Auto-detect every 2 seconds
      Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!mounted || !_isCameraInitialized || _isProcessing) return;

        _isProcessing = true;
        await _processImage();
        _isProcessing = false;
      });
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _processImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();

      final result = await _modelController.classify(bytes);
      debugPrint('Classification result: $result');

      if (result.isNotEmpty && result.contains('_')) {
        final parts = result.split('_');

        if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
          final moodGif = 'assets/images/${parts[1]}.gif';
          try {
            await DefaultAssetBundle.of(context).load(moodGif);
            setState(() {
              _breed = parts[0];
              _mood = parts[1];
              _gifPath = moodGif;
            });
            return;
          } catch (_) {
            debugPrint('❗ GIF not found, fallback to nice.gif');
          }
        }
      }

      _fallbackToNiceGif();
    } catch (e) {
      debugPrint('Classification error: $e');
      _fallbackToNiceGif();
    }
  }

  void _fallbackToNiceGif() {
    setState(() {
      _breed = 'no dog';
      _mood = 'no dog';
      _gifPath = 'assets/images/nice.gif';
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double cameraWidth = 350;
    const double cameraHeight = 350;
    const double cameraTopPadding = 30;
    const double resultBoxMargin = 30;
    const double resultBoxPadding = 16;
    const double gifSize = 100;
    const double resultBoxSpacing = 30;

    return Container(
      color: const Color(0xFFEAE0D1),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: cameraTopPadding),
          child: Column(
            children: [
              _isCameraInitialized
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: cameraWidth,
                  height: cameraHeight,
                  child: CameraPreview(_cameraController!),
                ),
              )
                  : const CircularProgressIndicator(),
              const SizedBox(height: resultBoxSpacing),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: resultBoxMargin),
                padding: const EdgeInsets.all(resultBoxPadding),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF914D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _gifPath ?? 'assets/images/nice.gif',
                        width: gifSize,
                        height: gifSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dog Type: ${_breed.isEmpty ? 'NO DOG' : _breed.toUpperCase()}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Dog Mood: ${_mood.isEmpty ? 'NO DOG' : _mood.toUpperCase()}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
