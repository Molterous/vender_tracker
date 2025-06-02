import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vender_tracker/common/helpers/method_channel_helper.dart';
import 'package:vender_tracker/common/helpers/pref_helper.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import 'package:vender_tracker/main.dart';

import '../../common/models/quotation.dart';

class UserRepo {

  final _helper = MethodChannelHelper.instance;

  UserRepo();


  Future<void> startLocTracking() async {

    try {
      await _helper.startLocationLogging();
    } catch (e) {

      debugPrint("startLocTracking error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }

  Future<void> stopLocTracking() async {

    try {
      await _helper.stopLocationLogging();
    } catch (e) {

      debugPrint("stopLocTracking error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }


  Future<List<Tasks>> getAllTasksForUser(String userId) async {

    try {
      final tasksMap = await _helper.getTasksByUserId(userId);

      final tasks = tasksMap.entries.map<Tasks>((entry) {
        final Map<String, String> userMap = Map<String, String>.from(entry.value);
        return Tasks.fromMap(userMap);
      }).toList();

      return tasks;

    } catch (e) {

      debugPrint("getAllTasksForUser error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<void> updateTaskForUser({
    required String taskId,
    required String title,
    required String desc,
    required String due,
    required int status,
    required Map<String, dynamic> updates,
    required String adminId,
    required String workerId,
  }) async {

    updates[status.toString()] = DateTime.now().toString();

    try {
      await _helper.updateTask(
        id: taskId,
        title: title,
        desc: desc,
        dueDate: due,
        updates: jsonEncode(updates),
        status: status,
        worker: workerId,
        creator: adminId,
      );
    } catch (e) {

      debugPrint("updateTaskForUser error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<void> markUserAttendance() async {

    try {
      final preTime = await _helper.getLoggedTimeOrZero();

      if(preTime > 0) {
        SharedPreferenceHelper.instance.savePunchInStatus();
        return;
      }

      await _helper.logAttendance();
    } catch (e) {

      debugPrint("markUserAttendance error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }


  Future<void> updateLoggedTime() async {

    try {
      final preTime = await _helper.getLoggedTimeOrZero();
      await _helper.updateLoggedTime(preTime.toString());

    } catch (e) {

      debugPrint("updateLoggedTime error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }


  Future<int> getLoggedTime() async {

    try {
      return await _helper.getLoggedTimeOrZero();

    } catch (e) {

      debugPrint("getLoggedTime error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }


  Future<void> updateUser({
    required String id,
    required String name,
    required String email,
    required String pass,
    required String designation,
    required int role,
    required String adminId,
    String fcm = '',
  }) async {

    try {
      await _helper.updateUser(
        id: id,
        role: role,
        name: name,
        email: email,
        password: pass,
        designation: designation,
        creator: adminId,
        fcm: fcm,
      );
    } catch (e) {

      debugPrint("updateUser error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<Map<DateTime, bool>> userMonthlyAttendance(DateTime date) async {

    try {
      final data = await _helper.getUserAttendanceForMonth(
        globalActiveUser!.userId,
        "${date.year}-${date.month.toString().padLeft(2,"0")}",
      );

      final Map<DateTime, bool> presentMap = {};

      data.forEach((dateStr, record) {
        final date = DateTime.parse(dateStr);
        final logged = int.tryParse(record["logged"] ?? '-1') ?? -1;
        presentMap[DateTime(date.year, date.month, date.day)] = logged > 0;
      });

      return presentMap;

    } catch (e) {

      debugPrint("userMonthlyAttendance error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }



  Future<Quotation> updateQuotation(Quotation quotation) async {

    try {

      await _helper.updateQuotation(quotation.toMap());
      return quotation;

    } catch (e) {

      debugPrint("updateQuotation error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<List<Quotation>> getAllQuotationsByUserId(String userId) async {

    try {
      final quotationMap = await _helper.getQuotationsByUserId({"worker" : userId});

      final quotations = quotationMap.entries.map<Quotation>((entry) {
        final Map<String, String> dataMap = Map<String, String>.from(entry.value);
        return Quotation.fromMap(dataMap);
      }).toList();

      return quotations;

    } catch (e) {

      debugPrint("getAllQuotationsByUserId error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }

}