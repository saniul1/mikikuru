import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mikikuru/player.dart';

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
  final AudioSource source;

  AudioFile({required this.file, required this.source});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AudioFile> audioSources = [];

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
                allowedExtensions: ['mp3', 'm4b'],
                allowMultiple: true,
              );
              final files = (result?.files ?? [])..sort((a, b) => a.name.compareTo(b.name));
              setState(() {
                audioSources = files
                    .map((file) => AudioFile(file: file, source: AudioSource.file(file.path ?? '')))
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
              final file = audioSources[i];
              return ListTile(
                title: Text(file.file.name),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => AppAudioPlayer(
                      audioSource: file.source,
                    ),
                  ),
                ),
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
