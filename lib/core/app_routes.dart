import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/analysis/analysis_view.dart';
import '../views/tips/tips_view.dart';
import '../views/settings/settings_view.dart';
import '../views/auth/otp_view.dart';
import '../views/onboarding/otp_verified_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/onboarding/dog_setup_name_view.dart';
import '../views/onboarding/dog_setup_gender_view.dart';
import '../views/onboarding/dog_setup_breed_view.dart';
import '../views/onboarding/dog_setup_photo_view.dart';
import '../views/main_view.dart';
import '../views/settings/register_dogs_view.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const otpVerified = '/otp-verified';
  static const onboarding = '/onboarding';
  static const dogSetupName = '/dog-setup-name';
  static const dogSetupGender = '/dog-setup-gender';
  static const dogSetupBreed = '/dog-setup-breed';
  static const dogSetupPhoto = '/dog-setup-photo';
  static const settings = '/settings';
  static const main = '/main';
  static const analysis = '/analysis';
  static const tips = '/tips';
  static const registerDogs = '/register-dogs';

  static final routes = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(name: login, page: () => const LoginView()),
    GetPage(name: register, page: () => const RegisterView()),
    GetPage(name: otp, page: () => const OtpVerificationView()),
    GetPage(name: otpVerified, page: () => const OtpVerifiedView()),
    GetPage(name: onboarding, page: () => const OnboardingView()),
    GetPage(name: dogSetupName, page: () => const DogSetupNameView()),
    GetPage(name: dogSetupGender, page: () => const DogSetupGenderView(dogName: '')),
    GetPage(name: dogSetupBreed, page: () => const DogSetupBreedView(dogName: '', dogGender: '')),
    GetPage(name: dogSetupPhoto, page: () => const DogSetupPhotoView(dogName: '', dogGender: '', dogBreed: '',)),
    GetPage(name: main, page: () => const MainView()),
    GetPage(name: analysis, page: () => const AnalysisView()),
    GetPage(name: tips, page: () => TipsView()),
    GetPage(name: settings, page: () => const SettingsView()),
    GetPage(name: registerDogs, page: () => const RegisteredDogsView()),
  ];
}
