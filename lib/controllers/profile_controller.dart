import 'package:get/get.dart';
import '../models/user.dart';

class ProfileController extends GetxController {
  final user = UserModel(
    id: '001',
    name: 'FurBe User',
    email: 'user@example.com',
    dogs: [],
  ).obs;

  void updateName(String newName) {
    user.update((val) {
      val?.name = newName;
    });
  }

  void addDog(Map<String, dynamic> dog) {
    user.update((val) {
      val?.dogs.add(dog);
    });
  }
}
