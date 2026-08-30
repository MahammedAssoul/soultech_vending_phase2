import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme controller.
///
/// Persists the selected theme (light/dark) with `shared_preferences` and
/// exposes a [ChangeNotifier] so the whole app rebuilds when toggled.
/// Light theme is the default.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const _prefKey = 'theme_mode';
  static const _light = 'light';
  static const _dark = 'dark';

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  /// Loads the persisted theme (falls back to light).
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    _mode = saved == _dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDark(bool dark) async {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, dark ? _dark : _light);
    notifyListeners();
  }

  Future<void> toggle() async {
    await setDark(!isDark);
  }
}
