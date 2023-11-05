import 'package:flutter/cupertino.dart';
import 'package:mikikuru/states/audio_book_notifier.dart';

class PlayerVolumeNotifier extends ValueNotifier<double> {
  static final PlayerVolumeNotifier _shared = PlayerVolumeNotifier._sharedInstance();
  factory PlayerVolumeNotifier() => _shared;
  PlayerVolumeNotifier._sharedInstance() : super(0.5);

  /// between 0-1
  void set(double volume) {
    value = volume;
    AudioBookNotifier().setVolume(volume);
  }
}
