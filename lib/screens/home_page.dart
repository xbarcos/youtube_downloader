import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_downloader/screens/download_history_page.dart';
import 'package:youtube_downloader/widgets/custom_button.dart';
import '../../controllers/download_controller.dart';
import '../../controllers/theme_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DownloadController controller = Get.put(DownloadController());
  final TextEditingController urlController = TextEditingController();
  final ThemeController themeController = Get.find();

  @override
  void initState() {
    super.initState();
    urlController.addListener(() {
      if (urlController.text.isEmpty) {
        controller.title.value = '';
        controller.thumbnailUrl.value = '';
      }
    });
  }

  @override
  void dispose() {
    urlController.removeListener(() {});
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(
                  () => Switch(
                    value: themeController.isDarkMode.value,
                    activeColor: Colors.pink,
                    onChanged: (value) => themeController.toggleTheme(),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Icon(
                    themeController.isDarkMode.value
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent[400]),
              child: Image.asset('assets/icon.png'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico de Downloads'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DownloadHistoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    color: Colors.black12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'YouTube Mp3 Downloader',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      labelText: 'Link do YouTube',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          title: 'Buscar',
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed:
                              () => controller.fetchInfo(
                                urlController.text.trim(),
                              ),
                          type: ButtonType.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (controller.title.value.isEmpty ||
                        controller.thumbnailUrl.value.isEmpty) {
                      return const SizedBox();
                    }
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            controller.thumbnailUrl.value,
                            width: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.title.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [                            
                            const SizedBox(width: 8),
                            Text(
                              controller.channelName.value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Duração: ${controller.duration.value}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => PrimaryButton(
                            title:
                                controller.loading.value
                                    ? 'Baixando...'
                                    : 'Download',
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            onPressed:
                                controller.loading.value
                                    ? null
                                    : () async {
                                      var res = await controller.download(
                                        urlController.text.trim(),
                                      );
                                      if (res != '') {
                                        setState(() {
                                          controller.title.value = '';
                                          controller.thumbnailUrl.value = '';
                                          controller.duration.value = '';
                                          controller.channelName.value = '';
                                          controller.channelAvatarUrl.value =
                                              '';
                                          urlController.clear();
                                        });
                                      }
                                    },
                            width: 200,
                            type: ButtonType.primary,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
