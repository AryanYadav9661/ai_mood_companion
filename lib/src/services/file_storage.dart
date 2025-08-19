import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<File> _file(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '\${dir.path}/\$name';
    final f = File(path);
    if (!await f.exists()) {
      await f.create(recursive: true);
      await f.writeAsString(jsonEncode({'items': []}));
    }
    return f;
  }

  static Future<List<Map<String,dynamic>>> readItems(String filename) async {
    final f = await _file(filename);
    final txt = await f.readAsString();
    final json = jsonDecode(txt) as Map<String,dynamic>;
    final items = (json['items'] as List).cast<Map<String,dynamic>>();
    return items;
  }

  static Future<void> writeItems(String filename, List<Map<String,dynamic>> items) async {
    final f = await _file(filename);
    await f.writeAsString(jsonEncode({'items': items}));
  }
}
