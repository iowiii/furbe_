import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxString theme = 'light'.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void changeTheme(String newTheme) {
    theme.value = newTheme;
  }
}
