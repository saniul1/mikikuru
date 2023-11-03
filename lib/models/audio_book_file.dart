import 'package:file_picker/file_picker.dart';

class AudioBookFile {
  final PlatformFile file;
  final PlatformFile? cover;

  AudioBookFile({
    required this.file,
    this.cover,
  });
}
