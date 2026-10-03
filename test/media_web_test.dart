import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awnwasand/media_store.dart';

void main() {
  test('browser stores course files in IndexedDB and reads them after reopening', () async {
    final first = MediaStore();
    final id = 'test-${DateTime.now().microsecondsSinceEpoch}';
    final bytes = Uint8List.fromList([37,80,68,70,45,49,46,55]);
    await first.put(id, bytes);
    final reopened = MediaStore();
    expect(await reopened.read(id), orderedEquals(bytes));
    final url = await reopened.videoUrl(id, 'application/pdf');
    expect(url.startsWith('blob:'), isTrue);
    reopened.release(url);
    await reopened.remove(id);
    await expectLater(reopened.read(id), throwsStateError);
  }, skip: !kIsWeb);
}
