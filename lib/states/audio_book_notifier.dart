import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:mikikuru/states/player_volume_notifier.dart';

class AudioBookNotifier extends ChangeNotifier {
  static final AudioBookNotifier _shared = AudioBookNotifier._sharedInstance();
  factory AudioBookNotifier() => _shared;
  AudioBookNotifier._sharedInstance()
      : player = AudioPlayer(),
        super();
  late final AudioPlayer player;

  Future<void> setSource(Source source, [bool play = true]) async {
    if (player.state == PlayerState.playing) await player.stop();
    await player.setVolume(PlayerVolumeNotifier().value);
    await player.setSource(source);
    if (play) {
      player.setPlaybackRate(1);
      await player.resume();
    }
    notifyListeners();
    return Future.value();
  }

  Future<void> playOrPause() async {
    player.state == PlayerState.playing ? await player.pause() : await player.resume();
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    assert(volume >= 0 && volume <= 1);
    player.setVolume(volume);
    notifyListeners();
  }

  Future<void> setPlaySpeed(double rate) async {
    assert(rate >= 0 && rate <= 2);
    player.setPlaybackRate(rate);
    notifyListeners();
  }
}

class AudioBookNotifierWidget extends InheritedNotifier<AudioBookNotifier> {
  const AudioBookNotifierWidget({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AudioBookNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AudioBookNotifierWidget>()!.notifier!;

  static AudioPlayer playerOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AudioBookNotifierWidget>()!.notifier!.player;
}
