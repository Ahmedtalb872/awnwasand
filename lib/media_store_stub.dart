import 'dart:typed_data';
import 'package:video_player/video_player.dart';

class MediaStore {
  Future<void> put(String id, Uint8List bytes) => throw UnsupportedError('التخزين غير متاح');
  Future<Uint8List> read(String id) => throw UnsupportedError('التخزين غير متاح');
  Future<void> remove(String id) => throw UnsupportedError('التخزين غير متاح');
  Future<String> videoUrl(String id, String mime) => throw UnsupportedError('الفيديو غير متاح');
  Future<void> open(String id, String name, String mime) => throw UnsupportedError('فتح الملفات غير متاح');
  void release(String url) {}
}
VideoPlayerController localVideoController(String url) => VideoPlayerController.networkUrl(Uri.parse(url));
