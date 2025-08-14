import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/app_routes.dart';
import 'core/app_bindings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FurBeApp());
}

class FurBeApp extends StatelessWidget {
  const FurBeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FurBe',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      initialBinding: AppBindings(),
      getPages: AppRoutes.routes,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
    );
  }
}
