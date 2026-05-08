// Local persistence for student-side filters and "remember me" flags.
// SharedPreferences package: https://pub.dev/packages/shared_preferences
// Flutter cookbook key-value storage: https://docs.flutter.dev/cookbook/persistence/key-value
// Map operations in Dart: https://www.geeksforgeeks.org/dart/dart-programming-map/

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for student settings.
/// Backed by localStorage on web, SharedPreferences on Android, and
/// NSUserDefaults on iOS.
class PreferencesService {
  static const _keyDob = 'student_dob';
  static const _keyZip = 'student_zip';
  static const _keyTypes = 'student_types';
  static const _keyCategories = 'student_categories';
  static const _keySetupComplete = 'student_setup_complete';
  static const _keyRestoreStudentOnLaunch = 'restore_student_on_launch';
  static const _keyRestoreOrgOnLaunch = 'restore_org_on_launch';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Setup status

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

  // Date of birth

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

  /// Calculates the user's current age from their stored DOB. Falls back to a
  /// reasonable default (14) when no DOB is set, and clamps the result so the
  /// age slider in the UI always stays in a sensible range.
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

  // Zip code

  static Future<void> saveZip(String zip) async {
    final prefs = await _instance;
    await prefs.setString(_keyZip, zip);
  }

  static Future<String> getZip() async {
    final prefs = await _instance;
    return prefs.getString(_keyZip) ?? '';
  }

  // Opportunity types (Club, Event, Volunteering)

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
    if (saved == null) return {for (var t in all) t: false};
    return {for (var t in all) t: saved.contains(t)};
  }

  // Categories (subjects)

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

  // Convenience: read everything the student screen needs in one go.
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

  // Convenience: write everything the onboarding sheet collects in one go.
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
