import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:video_player/video_player.dart';

class MediaStore {
  Future<File> file(String id) async {
    // IDs are generated internally; never use user-supplied file names as paths.
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(id)) throw ArgumentError('معرّف غير صالح');
    final root = await getApplicationDocumentsDirectory();
    final directory = await Directory('${root.path}/course_media').create(recursive: true);
    return File('${directory.path}/$id');
  }
  Future<void> put(String id, Uint8List bytes) async { await (await file(id)).writeAsBytes(bytes, flush: true); }
  Future<Uint8List> read(String id) async => (await file(id)).readAsBytes();
  Future<void> remove(String id) async { final target = await file(id); if (await target.exists()) await target.delete(); }
  Future<String> videoUrl(String id, String mime) async => (await file(id)).path;
  Future<void> open(String id, String name, String mime) async {
    final extension = name.split('.').last.replaceAll(RegExp('[^a-zA-Z0-9]'), '');
    final temporary = await getTemporaryDirectory();
    final target = File('${temporary.path}/$id.$extension');
    await target.writeAsBytes(await read(id), flush: true);
    final result = await OpenFilex.open(target.path, type: mime);
    if (result.type != ResultType.done) throw StateError('لا يوجد تطبيق لفتح الملف');
  }
  void release(String url) {}
}
VideoPlayerController localVideoController(String url) => url.startsWith('https://')
  ? VideoPlayerController.networkUrl(Uri.parse(url))
  : VideoPlayerController.file(File(url));
