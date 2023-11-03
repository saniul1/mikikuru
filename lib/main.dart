import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mikikuru/states/cover_art_notifier.dart';

import 'audio_book_player.dart';
import 'components/player.dart';
import 'models/audio_book_file.dart';

void main() {
  runApp(
    const App(),
  );
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return AudioBookPlayer(
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AudioBookFile> audioSources = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp3', 'm4b', 'jpg', 'png'],
                allowMultiple: true,
              );
              final audioFiles = result?.files
                      .where((e) =>
                          e.path != null &&
                          (e.path!.endsWith('.mp3') ||
                              e.path!.endsWith('.m4b')))
                      .toList() ??
                  [];
              final coverFiles = result?.files
                      .where((e) =>
                          e.path != null &&
                          (e.path!.endsWith('.jpg') ||
                              e.path!.endsWith('.png')))
                      .toList() ??
                  [];
              final files = audioFiles
                ..sort((a, b) => a.name.compareTo(b.name));

              setState(() {
                audioSources = files
                    .map((file) => AudioBookFile(
                          file: file,
                          cover: coverFiles.firstOrNull,
                        ))
                    .toList();
              });
            },
            icon: const Icon(Icons.create_new_folder_outlined),
          )
        ],
      ),
      body: Stack(
        children: [
          // Column(
          //   children: [
          //     ListView.builder(
          //       shrinkWrap: true,
          //       itemCount: audioSources.length,
          //       itemBuilder: (_, i) {
          //         final audio = audioSources[i];
          //         return ListTile(
          //           title: Text(audio.file.name),
          //           onTap: () async {
          //             if (audio.file.path != null) {
          //               await AudioBookPlayer.of(context).setPlayerWithFile(
          //                 audioBookFiles: audioSources,
          //                 audioBookFile: audio,
          //               );
          //             }
          //           },
          //         );
          //       },
          //     )
          //   ],
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width ~/ 180,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 16,
              itemBuilder: (_, i) {
                final image =
                    AssetImage('assets/images/default_cover_${i + 1}.jpeg');
                return InkWell(
                  onTap: () {
                    AudioBookCoverNotifier().value = image;
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Image(
                      image: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: PlayerWidget(),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    AudioBookPlayer.of(context).clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }
}
