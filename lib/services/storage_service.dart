import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class StorageService {
  Future<Directory> _savesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'saves'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> saveImageBytes(List<int> bytes, {String? namePrefix}) async {
    final dir = await _savesDir();
    final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = '${namePrefix ?? 'furbe'}_$ts.jpg';
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<List<File>> listSavedImages() async {
    final dir = await _savesDir();
    final files = dir.listSync().whereType<File>().toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  Future<void> deleteSaved(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }
}
