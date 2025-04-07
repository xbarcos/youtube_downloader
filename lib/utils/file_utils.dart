import 'dart:io';

class FileUtils {
  static Future<String> getFilePath(String title, String format) async {
    String safeTitle = title.replaceAll(RegExp(r'[\\\\/:*?"<>|]'), '_');
    String dir = 'output/$format';

    Directory(dir).createSync(recursive: true);
    return '$dir/$safeTitle.$format';
  }
}
