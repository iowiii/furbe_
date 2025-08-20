import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../services/mlkit_service.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'data_controller.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final MLKitService mlKitService = MLKitService();
  final DataController dataController = Get.find<DataController>();

  CameraController? cameraController;
  List<CameraDescription>? cameras;
  RxBool isCameraInitialized = false.obs;
  RxString resultText = "".obs;

  bool _isProcessing = false;
  bool _hasSaved = false;
  bool autoSave = false;

  Future<void> initCamera({bool saveMode = false}) async {
    autoSave = saveMode;
    _hasSaved = false;

    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      cameraController = CameraController(
        cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

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

  Future<void> processFrame(CameraImage cameraImage) async {
    final rotation = InputImageRotationValue.fromRawValue(
      cameras!.first.sensorOrientation,
    ) ??
        InputImageRotation.rotation0deg;

    final labels =
    await mlKitService.processCameraImage(cameraImage, rotation);

    if (labels.isNotEmpty) {
      final topLabel = labels.reduce(
            (curr, next) => curr.confidence > next.confidence ? curr : next,
      );

      resultText.value =
      "${topLabel.label} (${(topLabel.confidence * 100).toStringAsFixed(1)}%)";

      const allowedMoods = ['happy', 'sad', 'angry', 'scared'];

      if (autoSave && !_hasSaved && allowedMoods.contains(topLabel.label.toLowerCase())) {
        _saveResult(topLabel.label);
        _hasSaved = true;
      }

    } else {
      resultText.value = "No mood detected";
    }
  }

  Future<void> _saveResult(String mood) async {
    final dog = dataController.currentDog.value;
    final userPhone = dataController.currentPhone;
    if (dog == null || userPhone == null) return;

    final dateNow = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(dateNow);
    final saveId = "${dog.id}_$formattedDate";

    final saveData = {
      'dogName': dog.name,
      'mood': mood,
      'dateSave': dateNow.toIso8601String(),
      'info': dog.info,
    };

    await dataController.firebaseService.db
        .child('accounts/$userPhone/saves/${dog.id}/$saveId')
        .set(saveData);

    print("✅ Saved scan: $saveData");
  }

  Future<void> disposeCamera() async {
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
    isCameraInitialized.value = false;
  }

  @override
  void onClose() {
    disposeCamera();
    mlKitService.dispose();
    super.onClose();
  }
}
