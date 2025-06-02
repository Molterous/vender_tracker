import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vender_tracker/common/models/pair.dart';

class PermissionHelper {

  static const String _classTag = ' Permission Helper ';

  // static Future<bool> requestNotificationPermissions() async {
  //   debugPrint(" $_classTag requestNotificationPermissions called");
  //
  //   final req = await Permission.notification.request();
  //   return req.isGranted;
  // }
  //
  // static Future<bool> requestLocationPermissions() async {
  //   debugPrint(" $_classTag requestLocationPermissions called");
  //
  //   final req = await Permission.locationAlways.request();
  //   return req.isGranted;
  // }
  //
  // static Future<bool> requestBatteryOptPermissions() async {
  //   debugPrint(" $_classTag requestBatteryOptPermissions called");
  //
  //   final req = await Permission.ignoreBatteryOptimizations.request();
  //   return req.isGranted;
  // }
  //
  // static Future<bool> requestAlarmPermissions() async {
  //   debugPrint(" $_classTag requestAlarmOptPermissions called");
  //
  //   final req = await Permission.scheduleExactAlarm.request();
  //   return req.isGranted;
  // }

  static Future<Pair<String, Permission>?> getNextPermissionInfo() async {

    if (!await Permission.notification.isGranted) {
      return Pair('Notification', Permission.notification);
    } else if (!await Permission.location.isGranted) {
      return Pair('Location', Permission.location);
    } else if (!await Permission.locationAlways.isGranted) {
      return Pair('Location Always', Permission.locationAlways);
    } else if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      return Pair('Ignore Optimization', Permission.ignoreBatteryOptimizations);
    } else if (!await Permission.scheduleExactAlarm.isGranted) {
      return Pair('Schedule Alarm', Permission.scheduleExactAlarm);
    }

    return null;
  }

  // static Future<bool> requestAllPermissions() async {
  //
  //   debugPrint(" $_classTag requestAllPermissions called");
  //
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.notification,
  //     Permission.location,
  //     Permission.locationAlways,
  //     Permission.locationWhenInUse,
  //     Permission.ignoreBatteryOptimizations,
  //     Permission.scheduleExactAlarm,
  //   ].request();
  //
  //   return statuses.values.every((status) => status.isGranted);
  // }

  static Future<bool> checkAllPermissions() async {

    debugPrint(" $_classTag checkAllPermissions called");

    return
      await Permission.notification.isGranted &&
      await Permission.location.isGranted &&
      await Permission.locationAlways.isGranted &&
      await Permission.locationWhenInUse.isGranted &&
      await Permission.ignoreBatteryOptimizations.isGranted &&
      await Permission.scheduleExactAlarm.isGranted;
  }
}