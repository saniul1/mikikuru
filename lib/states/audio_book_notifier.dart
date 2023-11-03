import 'package:flutter/widgets.dart';

import '../models/audio_book_file.dart';

class AudioBookNotifier extends ValueNotifier<AudioBookFile?> {
  static final AudioBookNotifier _shared = AudioBookNotifier._sharedInstance();
  factory AudioBookNotifier() => _shared;
  AudioBookNotifier._sharedInstance() : super(null);

  void setAudio(AudioBookFile? audio) {
    if (audio?.file.path != null) {
      value = audio;
    } else {
      value = null;
    }
  }
}
