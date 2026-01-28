import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage medical disclaimer display
class DisclaimerService {
  static const String _keyHasSeenDisclaimer = 'has_seen_medical_disclaimer';

  /// Check if user has already seen the disclaimer
  static Future<bool> hasSeenDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenDisclaimer) ?? false;
  }

  /// Mark disclaimer as seen
  static Future<void> markDisclaimerAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenDisclaimer, true);
  }

  /// Reset disclaimer (for testing or if needed)
  static Future<void> resetDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenDisclaimer);
  }
}
