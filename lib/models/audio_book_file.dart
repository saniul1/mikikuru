import 'dart:io';

class AudioBookFile {
  final File file;
  final File? cover;

  AudioBookFile({
    required this.file,
    this.cover,
  });
}
