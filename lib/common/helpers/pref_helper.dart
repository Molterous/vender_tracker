import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {

  /// singleton class instance
  static final SharedPreferenceHelper _inst = SharedPreferenceHelper._privateConstructor();
  static SharedPreferenceHelper get instance => _inst;
  late final SharedPreferences prefs;

  /// private constructor
  SharedPreferenceHelper._privateConstructor() {
    initPref();
  }

  void initPref() async {
    prefs = await SharedPreferences.getInstance();
  }


  /// functions
  // save Punch In Status
  Future<void> savePunchInStatus() async {
    try {
      await prefs.setString(prefLoggedInKey, DateTime.now().toString());
    } catch (e) {
      debugPrint('$_classTag savePunchInStatus exception: ${e.toString()}');
    }
  }

  Future<void> punchOut() async {
    try {
      await prefs.remove(prefLoggedInKey);
    } catch (e) {
      debugPrint('$_classTag punchOut exception: ${e.toString()}');
    }
  }

  Future<bool> getPunchInStatus() async {
    try {

      final loggedIn = prefs.getString(prefLoggedInKey);
      return (loggedIn ?? "").isNotEmpty;
    } catch (e) {
      debugPrint('$_classTag getPunchInStatus exception: ${e.toString()}');
      return false;
    }
  }

  Future<int> getLoggedTimeInMin() async {
    try {

      final loggedIn = prefs.getString(prefLoggedInKey);
      if (loggedIn == null) return 0;

      final inTime = DateTime.parse(loggedIn);
      final timeDiff = DateTime.now().difference(inTime);

      return timeDiff.inMinutes;

    } catch (e) {
      debugPrint('$_classTag getLoggedTimeInMin exception: ${e.toString()}');
      return 0;
    }
  }

  /// constants
  static const String _classTag = " SharedPreferenceHelper ";
  static const String prefLoggedInKey = "loggedIn";
}
