import 'dart:io';

import 'package:flutter/cupertino.dart';

const _defaultCover = AssetImage('assets/images/default_cover_1.jpeg');

class AudioBookCoverNotifier extends ValueNotifier<ImageProvider> {
  static final AudioBookCoverNotifier _shared = AudioBookCoverNotifier._sharedInstance();
  factory AudioBookCoverNotifier() => _shared;
  AudioBookCoverNotifier._sharedInstance() : super(_defaultCover);

  void setCover(File? cover) {
    if (cover != null) {
      value = FileImage(cover);
    } else {
      value = _defaultCover;
    }
  }
}
