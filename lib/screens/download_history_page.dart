import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_downloader/utils/snackbar_utils.dart';
import '../controllers/download_controller.dart';

class DownloadHistoryPage extends StatelessWidget {
  final DownloadController controller = Get.find();

  DownloadHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Limpar Histórico'),
                  content: const Text('Tem certeza de que deseja limpar o histórico?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                controller.downloadHistory.clear();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('downloadHistory');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.downloadHistory.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum download realizado ainda.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.downloadHistory.length,
          itemBuilder: (context, index) {
            final filePath = controller.downloadHistory[index];
            final fileName = filePath.split(Platform.pathSeparator).last;

            return ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(fileName),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () async {
                  final result = await OpenFile.open(filePath);
                  if (result.type != ResultType.done) {
                    SnackbarUtils.showSnackbar('Erro ao abrir o arquivo',
                                              result.message, Icons.error,
                                              SnackbarType.danger);                    
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }
}