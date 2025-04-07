import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/download_service.dart';
import '../utils/snackbar_utils.dart';

class DownloadController extends GetxController {
  final DownloadService _service = DownloadService();
  var downloadHistory = <String>[].obs;
  var loading = false.obs;
  var title = ''.obs;
  var thumbnailUrl = ''.obs;
  var duration = ''.obs; // Nova variável para a duração do vídeo
  var channelName = ''.obs; // Nova variável para o nome do canal
  var channelAvatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _createOutputFolders();
    _loadDownloadHistory();
  }

  Future<void> _loadDownloadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList('downloadHistory') ?? [];
    downloadHistory.addAll(savedHistory);
  }

  Future<void> _saveDownloadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('downloadHistory', downloadHistory);
  }

  Future<void> requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  void _createOutputFolders() async {
    await requestPermission();

    Directory baseDir;
    if (Platform.isAndroid) {
      baseDir = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows) {
      baseDir = Directory.current;
    } else {
      throw UnsupportedError('Plataforma não suportada');
    }

    final mp3Dir = Directory('${baseDir.path}/output/mp3');

    if (!(await mp3Dir.exists())) {
      await mp3Dir.create(recursive: true);
    }
  }

  Future<void> fetchInfo(String url) async {
    if (url.trim().isEmpty) {
      SnackbarUtils.showSnackbar(
        'Aviso',
        'Insira um link do YouTube.',
        Icons.warning,
        SnackbarType.warning,
      );
      return;
    }

    try {
      final video = await _service.yt.videos.get(url);

      // Atualiza as informações do vídeo
      title.value = video.title;
      thumbnailUrl.value = video.thumbnails.standardResUrl;
      duration.value =
          video.duration?.toString().split('.').first ?? 'Desconhecida';
      channelName.value = video.author;

      // Como o campo 'authorThumbnails' não existe, você pode omitir a imagem do canal
      channelAvatarUrl.value = ''; // Deixe vazio ou use uma imagem padrão
    } catch (e) {
      print("Erro ao buscar info: $e");
      SnackbarUtils.showSnackbar(
        'Erro!',
        'Não foi possível encontrar o vídeo.',
        Icons.error,
        SnackbarType.danger,
      );
    }
  }

  Future<String> download(String url) async {
    if (url.trim().isEmpty) return '';
    String filePath = '';
    loading.value = true;
    try {
      filePath = await _service.downloadAudio(url);
      downloadHistory.add(filePath);
      await _saveDownloadHistory();

      SnackbarUtils.showSnackbar(
        'Sucesso',
        'Download finalizado!',
        Icons.check,
        SnackbarType.success,
      );
    } catch (e) {
      print("Erro: $e");
      SnackbarUtils.showSnackbar(
        'Erro',
        e.toString(),
        Icons.error,
        SnackbarType.danger,
      );
    } finally {
      loading.value = false;
    }
    return filePath;
  }
}
