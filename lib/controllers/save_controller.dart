import 'dart:io';
import 'package:get/get.dart';
import '../services/storage_service.dart';

class SaveController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  RxList<File> saves = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSaves();
  }

  Future<void> loadSaves() async {
    final files = await _storage.listSavedImages();
    saves.assignAll(files);
  }

  Future<void> deleteSave(String path) async {
    await _storage.deleteSaved(path);
    await loadSaves();
  }
}
