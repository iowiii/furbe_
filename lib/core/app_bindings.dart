import 'package:get/get.dart';
import '../controllers/data_controller.dart';
import '../controllers/home_controller.dart';
import '../services/tf_service.dart';
import '../services/firebase_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(TFLiteService(), permanent: true);
    Get.put(FirebaseService(), permanent: true);
    Get.put(DataController(), permanent: true);
    Get.put(HomeController());
  }
}
