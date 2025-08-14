import 'package:get/get.dart';

class TipsController extends GetxController {
  final RxList<String> tips = <String>[
    'Spend at least 30 minutes playing with your dog daily.',
    'Provide fresh water and healthy food.',
    'Watch for changes in behavior to detect mood shifts.',
    'Regular vet checkups keep your dog healthy.'
  ].obs;

  String getRandomTip() {
    tips.shuffle();
    return tips.first;
  }
}
