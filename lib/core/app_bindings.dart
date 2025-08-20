import 'package:get/get.dart';
import '../controllers/data_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/save_controller.dart';
import '../services/mlkit_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MLKitService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(FirebaseService(), permanent: true);
    Get.put(DataController(), permanent: true);
    Get.put(HomeController());
    Get.put(SaveController());
  }
}
