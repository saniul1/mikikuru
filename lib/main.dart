import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const App(),
  );
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class AudioFile {
  final PlatformFile file;
  final PlatformFile? cover;

  AudioFile({
    required this.file,
    this.cover,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AudioFile> audioSources = [];
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
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
                          e.path != null && (e.path!.endsWith('.mp3') || e.path!.endsWith('.m4b')))
                      .toList() ??
                  [];
              final coverFiles = result?.files
                      .where((e) =>
                          e.path != null && (e.path!.endsWith('.jpg') || e.path!.endsWith('.png')))
                      .toList() ??
                  [];
              final files = audioFiles..sort((a, b) => a.name.compareTo(b.name));

              setState(() {
                audioSources = files
                    .map((file) => AudioFile(
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
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: audioSources.length,
            itemBuilder: (_, i) {
              final audio = audioSources[i];
              return ListTile(
                title: Text(audio.file.name),
                onTap: () async {
                  if (audio.file.path != null) {
                    await player.play(DeviceFileSource(audio.file.path!));
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
