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
      'head': 'How does it work',
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
      body: Column(
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(page['head']!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text(page['text']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                        if (index == pages.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ElevatedButton(
                              onPressed: () => Get.off(() => const DogSetupNameView()),
                              child: const Text('Get Started'),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentPage ? Colors.orange : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
