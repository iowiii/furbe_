import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/home_view.dart';
import '../views/save/save_view.dart';
import '../views/profile/profile_view.dart';
import '../views/settings/settings_view.dart';
import '../views/analysis/analysis_view.dart';
import '../views/tips/tips_view.dart';
import '../views/auth/otp_view.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const save = '/save';
  static const profile = '/profile';
  static const settings = '/settings';
  static const analysis = '/analysis';
  static const tips = '/tips';
  static const otp = '/otp';

  static final routes = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(name: login, page: () => const LoginView()),
    GetPage(name: register, page: () => const RegisterView()),
    GetPage(name: home, page: () => const HomeView()),
    GetPage(name: save, page: () => const SaveView()),
    GetPage(name: profile, page: () => const ProfileView()),
    GetPage(name: settings, page: () => const SettingsView()),
    GetPage(name: analysis, page: () => const AnalysisView()),
    GetPage(name: tips, page: () => const TipsView()),
  ];
}
