import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/save_controller.dart';

class SaveView extends StatelessWidget {
  const SaveView({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SaveController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Saves')),
      body: Obx(() {
        final saves = ctrl.saves;
        if (saves.isEmpty) return const Center(child: Text('No saves yet'));
        return ListView.builder(
          itemCount: saves.length,
          itemBuilder: (context, i) {
            final file = saves[i];
            return ListTile(
              leading: Image.file(File(file.path), width: 64, height: 64, fit: BoxFit.cover),
              title: Text(file.path.split('/').last),
              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => ctrl.deleteSave(file.path)),
            );
          },
        );
      }),
    );
  }
}
