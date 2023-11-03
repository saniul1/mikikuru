import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:mikikuru/models/audio_book_file.dart';
import 'package:mikikuru/states/audio_book_notifier.dart';

import 'states/cover_art_notifier.dart';

class AudioBookPlayer extends InheritedWidget {
  late final AudioPlayer player;

  final List<AudioBookFile> _audioBookFiles = [];

  AudioBookPlayer({super.key, required Widget child})
      : player = AudioPlayer(),
        super(child: child);

  bool get isReadyToPlay => player.source != null;

  void clear() {
    player.release();
    _audioBookFiles.clear();
  }

  Future<void> setPlayerWithFile({
    required List<AudioBookFile> audioBookFiles,
    AudioBookFile? audioBookFile,
    bool play = true,
  }) async {
    if (audioBookFile != null) {
      await player.setSourceDeviceFile(audioBookFile.file.path!);
    }
    if (play && player.source != null) {
      AudioBookNotifier().setAudio(audioBookFile);
      AudioBookCoverNotifier().setCover(audioBookFile?.cover);
      await player.resume();
      player.onPlayerStateChanged
          .listen((PlayerState s) => print('Current player state: $s'));
    }
    return Future.value();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AudioBookPlayer of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AudioBookPlayer>()!;

  static AudioPlayer playerOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AudioBookPlayer>()!.player;
}
