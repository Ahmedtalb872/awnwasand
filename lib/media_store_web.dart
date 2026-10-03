// Browser-only persistence: binary files are in IndexedDB, not localStorage.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:idb_shim/idb_browser.dart';
import 'package:video_player/video_player.dart';

class MediaStore {
  Future<Database>? _database;
  Future<Database> get database => _database ??= idbFactoryBrowser.open('awnwasand_media_v1', version: 1, onUpgradeNeeded: (event) { event.database.createObjectStore('files'); });
  Future<void> put(String id, Uint8List bytes) async {
    final db = await database;
    final txn = db.transaction('files', idbModeReadWrite);
    await txn.objectStore('files').put(bytes, id);
    await txn.completed;
  }
  Future<Uint8List> read(String id) async {
    final db = await database;
    final txn = db.transaction('files', idbModeReadOnly);
    final value = await txn.objectStore('files').getObject(id);
    await txn.completed;
    if (value == null) throw StateError('الملف غير موجود على هذا الجهاز');
    return value is Uint8List ? value : Uint8List.fromList(List<int>.from(value as List));
  }
  Future<void> remove(String id) async {
    final db = await database;
    final txn = db.transaction('files', idbModeReadWrite);
    await txn.objectStore('files').delete(id);
    await txn.completed;
  }
  Future<String> videoUrl(String id, String mime) async => html.Url.createObjectUrlFromBlob(html.Blob([await read(id)], mime));
  Future<void> open(String id, String name, String mime) async {
    final url = await videoUrl(id, mime);
    final anchor = html.AnchorElement(href: url)..download = name;
    anchor.click();
    Future<void>.delayed(const Duration(seconds: 30), () => release(url));
  }
  void release(String url) { if (url.startsWith('blob:')) html.Url.revokeObjectUrl(url); }
}
VideoPlayerController localVideoController(String url) => VideoPlayerController.networkUrl(Uri.parse(url));
