import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadService {
  final YoutubeExplode yt = YoutubeExplode();

  Future<String> downloadAudio(String url) async {
    final video = await yt.videos.get(url);
    final manifest = await yt.videos.streamsClient.getManifest(video.id);
    final audio = manifest.audioOnly;

    if (audio.isEmpty) {
      throw Exception('Este vídeo não possui streams de áudio disponíveis.');
    }

    final audioStreamInfo = audio.withHighestBitrate();
    final stream = yt.videos.streamsClient.get(audioStreamInfo);

    Directory baseDir;
    if (Platform.isAndroid) {
      baseDir = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows) {
      baseDir = Directory.current;
    } else {
      throw UnsupportedError('Plataforma não suportada');
    }

    final filePath =
        '${baseDir.path}/output/mp3/${_sanitizeFileName(video.title)}.mp3';

    final file = File(filePath);
    await file.create(recursive: true);
    final fileStream = file.openWrite();

    await stream.pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();

    return filePath;
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
  }
}