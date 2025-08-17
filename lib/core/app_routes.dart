import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/analysis/analysis_view.dart';
import '../views/tips/tips_view.dart';
import '../views/auth/otp_view.dart';
import '../views/main_view.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';
  static const analysis = '/analysis';
  static const tips = '/tips';
  static const otp = '/otp';

  static final routes = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(name: login, page: () => const LoginView()),
    GetPage(name: register, page: () => const RegisterView()),
    GetPage(name: main, page: () => const MainView()),
    GetPage(name: analysis, page: () => const AnalysisView()),
    GetPage(name: tips, page: () => const TipsView()),
    GetPage(name: otp, page: () => const OtpVerificationView()),
  ];
}
