import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../services/mlkit_service.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class HomeController extends GetxController {
  final MLKitService mlKitService = MLKitService();

  CameraController? cameraController;
  List<CameraDescription>? cameras;
  RxBool isCameraInitialized = false.obs;
  RxString resultText = "Initializing...".obs;

  bool _isProcessing = false; // Prevents overlapping frame processing

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  /// Initializes the camera and starts live feed
  Future<void> initCamera() async {
    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      cameraController = CameraController(
        cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

      // Start streaming camera frames to ML Kit
      cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          _isProcessing = true;
          processFrame(image).then((_) {
            _isProcessing = false;
          });
        }
      });
    } else {
      resultText.value = "No camera found";
    }
  }

  /// Processes each camera frame for mood detection
  Future<void> processFrame(CameraImage cameraImage) async {
    final rotation = InputImageRotationValue.fromRawValue(
      cameras!.first.sensorOrientation,
    ) ??
        InputImageRotation.rotation0deg;

    final labels =
    await mlKitService.processCameraImage(cameraImage, rotation);

    if (labels.isNotEmpty) {
      // Pick the highest confidence label
      final topLabel = labels.reduce(
            (curr, next) =>
        curr.confidence > next.confidence ? curr : next,
      );
      resultText.value =
      "${topLabel.label} (${(topLabel.confidence * 100).toStringAsFixed(1)}%)";
    } else {
      resultText.value = "No mood detected";
    }
  }

  @override
  void onClose() {
    cameraController?.stopImageStream();
    cameraController?.dispose();
    mlKitService.dispose();
    super.onClose();
  }
}
