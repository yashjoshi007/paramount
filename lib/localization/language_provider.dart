import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class LanguageProvider extends ChangeNotifier {
  late Locale _locale;
  late Map<String, String> _localizedStrings;

  LanguageProvider() {
    _locale = Locale('en', 'US'); // Default to English
    _localizedStrings = {};
    _loadTranslations();
  }

  Locale get locale => _locale;

  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    _loadTranslations();
    notifyListeners();
  }

  void _loadTranslations() async {
    String jsonString = await rootBundle.loadString('assets/languages/${_locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
