import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dog_setup_name_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      'head': 'Welcome to FurBe',
      'text': 'Helping you understand your dog\'s mood with AI is our goal here in FurBe.'
    },
    {
      'head': 'How does it work?',
      'text': 'You can detect your dog\'s mood by placing your dog within the camera frame.'
    },
    {
      'head': 'What else?',
      'text': '• Track your dog\'s mood through historical data\n'
          '• Quick scan to detect another dog\'s mood\n'
          '• Get insights on what to do depending on your dog\'s mood'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (_, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          page['head']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page['text']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            height: 1.6,
                          ),
                        ),
                        if (index == pages.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 48.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE15C31),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () => Get.off(() => const DogSetupNameView()),
                                child: const Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == currentPage ? const Color(0xFFE15C31) : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
