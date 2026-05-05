// SharedPreferences (core storage used in this file)
// https://pub.dev/packages/shared_preferences

// Flutter official guide: Store key-value data locally
// https://docs.flutter.dev/cookbook/persistence/key-value

// Dart async/await (used for Future, async functions)
// https://dart.dev/codelabs/async-await

// Dart collections (Map, List, .where(), .map(), etc.)
// https://dart.dev/guides/language/language-tour#collections

// Dart DateTime (used for DOB storage + age calculation)
// https://api.dart.dev/stable/dart-core/DateTime-class.html

// Flutter architecture / separation of logic (service pattern idea)
// https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple

import 'package:shared_preferences/shared_preferences.dart';

/// Simple wrapper around SharedPreferences for student settings.
/// Works on web (localStorage), Android (SharedPreferences), iOS (NSUserDefaults).
// Static class / utility class pattern in Dart: https://www.geeksforgeeks.org/dart-classes-and-objects/
class PreferencesService {
  static const _keyDob = 'student_dob';
  static const _keyZip = 'student_zip';
  static const _keyTypes = 'student_types';
  static const _keyCategories = 'student_categories';
  static const _keySetupComplete = 'student_setup_complete';
  static const _keyRestoreStudentOnLaunch = 'restore_student_on_launch';
  static const _keyRestoreOrgOnLaunch = 'restore_org_on_launch';

  static SharedPreferences? _prefs;

  // Null-aware assignment operator (??=): https://www.geeksforgeeks.org/operators-in-dart/
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- Setup status ---

  static Future<bool> isSetupComplete() async {
    final prefs = await _instance;
    return prefs.getBool(_keySetupComplete) ?? false;
  }

  static Future<void> setSetupComplete(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_keySetupComplete, value);
  }

  static Future<void> setRestoreStudentOnLaunch(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_keyRestoreStudentOnLaunch, value);
  }

  static Future<bool> shouldRestoreStudentOnLaunch() async {
    final prefs = await _instance;
    return prefs.getBool(_keyRestoreStudentOnLaunch) ?? false;
  }

  static Future<void> setRestoreOrgOnLaunch(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_keyRestoreOrgOnLaunch, value);
  }

  static Future<bool> shouldRestoreOrgOnLaunch() async {
    final prefs = await _instance;
    return prefs.getBool(_keyRestoreOrgOnLaunch) ?? false;
  }

  // --- Date of birth ---

  static Future<void> saveDob(DateTime dob) async {
    final prefs = await _instance;
    await prefs.setString(_keyDob, dob.toIso8601String());
  }

  static Future<DateTime?> getDob() async {
    final prefs = await _instance;
    final raw = prefs.getString(_keyDob);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Calculate current age from stored DOB.
  static double calculateAge(DateTime? dob) {
    if (dob == null) return 14;
    final now = DateTime.now();
    double age = (now.year - dob.year).toDouble();
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age -= 1;
    }
    return age.clamp(5, 24);
  }

  // --- Zip code ---

  static Future<void> saveZip(String zip) async {
    final prefs = await _instance;
    await prefs.setString(_keyZip, zip);
  }

  static Future<String> getZip() async {
    final prefs = await _instance;
    return prefs.getString(_keyZip) ?? '';
  }

  // --- Types (Club, Event, Volunteering) ---

  static Future<void> saveEnabledTypes(Map<String, bool> types) async {
    final prefs = await _instance;
    final enabled = types.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    await prefs.setStringList(_keyTypes, enabled);
  }

  static Future<Map<String, bool>> getEnabledTypes() async {
    final prefs = await _instance;
    final all = ['Club', 'Event', 'Volunteering'];
    final saved = prefs.getStringList(_keyTypes);
    // Collection-if and spread operators in Dart: https://www.geeksforgeeks.org/dart-collection-if-and-collection-for/
    if (saved == null) return {for (var t in all) t: false};
    return {for (var t in all) t: saved.contains(t)};
  }

  // --- Categories (subjects) ---

  static Future<void> saveEnabledCategories(Map<String, bool> cats) async {
    final prefs = await _instance;
    final enabled = cats.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    await prefs.setStringList(_keyCategories, enabled);
  }

  static Future<Map<String, bool>> getEnabledCategories() async {
    final prefs = await _instance;
    final all = [
      'Robotics', 'Biology', 'Math',
      'Computer Science', 'Engineering', 'Physics',
    ];
    final saved = prefs.getStringList(_keyCategories);
    if (saved == null) return {for (var c in all) c: false};
    return {for (var c in all) c: saved.contains(c)};
  }

  // Get all at once

  static Future<Map<String, dynamic>> getAll() async {
    final setupDone = await isSetupComplete();
    if (!setupDone) return {'setupDone': false};

    final dob = await getDob();
    return {
      'setupDone': true,
      'dob': dob,
      'age': calculateAge(dob),
      'zip': await getZip(),
      'types': await getEnabledTypes(),
      'categories': await getEnabledCategories(),
    };
  }

  //Save all at once

  static Future<void> saveAll({
    required DateTime dob,
    required String zip,
    required Map<String, bool> types,
    required Map<String, bool> categories,
  }) async {
    final prefs = await _instance;
    await prefs.setString(_keyDob, dob.toIso8601String());
    await prefs.setString(_keyZip, zip);

    final enabledTypes = types.entries.where((e) => e.value).map((e) => e.key).toList();
    await prefs.setStringList(_keyTypes, enabledTypes);

    final enabledCats = categories.entries.where((e) => e.value).map((e) => e.key).toList();
    await prefs.setStringList(_keyCategories, enabledCats);

    await prefs.setBool(_keySetupComplete, true);
  }
}
