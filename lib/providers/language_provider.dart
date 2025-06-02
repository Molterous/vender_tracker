import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  late SharedPreferences _prefs;
  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  LanguageProvider() {
    _initialize();
  }

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedLanguage();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadSavedLanguage() async {
    final String? languageCode = _prefs.getString(_languageKey);
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode != languageCode) {
      _currentLocale = Locale(languageCode);
      await _prefs.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }
} 