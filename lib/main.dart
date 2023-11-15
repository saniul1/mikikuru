import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikikuru/states/player_notifier.dart';
import 'package:mikikuru/utils/routes.dart';

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
    return MaterialApp(
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
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    PlayerNotifier().player.dispose();
    super.dispose();
  }

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
                          e.path != null && (e.path!.endsWith('.mp3') || e.path!.endsWith('.m4b')))
                      .toList() ??
                  [];
              final coverFiles = result?.files
                      .where((e) =>
                          e.path != null && (e.path!.endsWith('.jpg') || e.path!.endsWith('.png')))
                      .toList() ??
                  [];
              final files = audioFiles..sort((a, b) => a.name.compareTo(b.name));

              print(files.first.path);

              setState(() {
                audioSources = files
                    .map((file) => AudioBookFile(
                          file: File(file.path!),
                          // cover: coverFiles.firstOrNull,
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
                final image = AssetImage('assets/images/default_cover_${i + 1}.jpeg');
                return BookCover(image: image, i: i);
              },
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: PlayerWidget(),
            ),
          )
        ],
      ),
    );
  }
}

class BookCover extends StatefulWidget {
  const BookCover({
    super.key,
    required this.image,
    required this.i,
  });

  final AssetImage image;
  final int i;

  @override
  _BookCoverState createState() => _BookCoverState();
}

class _BookCoverState extends State<BookCover> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool isHover = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (hover) {
        hover ? _controller.forward() : _controller.reverse();
        setState(() {
          isHover = hover;
        });
      },
      onTap: () {
        Navigator.push(
          context,
          getDetailViewRoute('cover-${widget.i}', widget.image),
        );
        // AudioBookCoverNotifier().value = widget.image;
        // const path = 'intro.mp3';
        // PlayerNotifier().setSource(AssetSource(path));
        // AudioBookPlayer.of(context).setPlayerWithFile(audioBookFiles: [
        //   AudioBookFile(file: file),
        // ], audioBookFile: AudioBookFile(file: file));
      },
      child: Stack(
        children: [
          Hero(
            tag: 'cover-${widget.i}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: Image(
                      image: widget.image,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
          if (isHover)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sit amet do dolore dolor Duis labore nulla reprehenderit anim.',
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        Text(
                          '- Author',
                          overflow: TextOverflow.fade,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '03:44:32',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                            child: Row(
                              children: [
                                Icon(
                                  widget.i != 3
                                      ? CupertinoIcons.play_arrow_solid
                                      : CupertinoIcons.pause_solid,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.i == 3
                                      ? 'Playing'
                                      : [0, 2, 8, 9].contains(widget.i)
                                          ? 'Continue'
                                          : 'Play Now',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
