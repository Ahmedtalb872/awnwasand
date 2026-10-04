import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final uiPreferences = UiPreferences();
class UiPreferences extends ChangeNotifier {
  double fontScale = 1;
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    fontScale = (prefs.getDouble('ui.fontScale') ?? 1).clamp(.9, 1.2).toDouble();
    notifyListeners();
  }
  Future<void> setScale(double value) async {
    fontScale = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setDouble('ui.fontScale', value);
  }
}
