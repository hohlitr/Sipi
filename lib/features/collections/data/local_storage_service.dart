import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const collectionsKey = 'sipi.collections';
  static const cardsKey = 'sipi.cards';
  static const groupsKey = 'sipi.groups';
  static const achievementsKey = 'sipi.achievements';
  static const studyPlansKey = 'sipi.studyPlans';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String?> read(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> write(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }
}
