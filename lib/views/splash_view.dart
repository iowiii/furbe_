import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  int pawCount = 0;
  final int totalPaws = 7;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (pawCount < totalPaws) {
        setState(() {
          pawCount++;
        });
      } else {
        timer.cancel();
        _navigateToLogin(); // Now goes to login
      }
    });
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE0D1),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              pawCount < 6
                  ? 'assets/images/logo_bare.png'
                  : 'assets/images/logo_main.png',
              width: 150,
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final positions = [
                  const Offset(0.48, 0.90),
                  const Offset(0.55, 0.82),
                  const Offset(0.62, 0.75),
                  const Offset(0.70, 0.65),
                  const Offset(0.78, 0.55),
                  const Offset(0.86, 0.45),
                  const Offset(0.94, 0.35),
                ];

                return Stack(
                  children: List.generate(pawCount, (index) {
                    return Positioned(
                      left: positions[index].dx * constraints.maxWidth,
                      top: positions[index].dy * constraints.maxHeight,
                      child: Image.asset(
                        'assets/images/paw.png',
                        width: 40,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
