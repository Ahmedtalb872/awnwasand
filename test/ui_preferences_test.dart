import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awnwasand/ui_preferences.dart';

void main() {
  test('reading size survives reload and clamps unsupported stored values', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = UiPreferences();
    var notifications = 0;
    prefs.addListener(() => notifications++);
    await prefs.setScale(1.2);
    expect(notifications, 1);
    final restored = UiPreferences();
    await restored.load();
    expect(restored.fontScale, 1.2);
    await (await SharedPreferences.getInstance()).setDouble('ui.fontScale', 7);
    await restored.load();
    expect(restored.fontScale, 1.2);
    prefs.dispose();
    restored.dispose();
  });
}
