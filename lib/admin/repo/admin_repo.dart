import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vender_tracker/common/enums/task_status_enum.dart';
import 'package:vender_tracker/common/helpers/method_channel_helper.dart';
import 'package:vender_tracker/common/models/quotation.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import 'package:vender_tracker/common/models/user.dart';
import 'package:vender_tracker/main.dart';

class AdminRepo {

  final _helper = MethodChannelHelper.instance;

  AdminRepo();

  /// user management functions
  Future<User> addNewUser({
    required String name,
    required String email,
    required String pass,
    required String designation,
    required int role,
    required String adminId,
    String fcm = '',
  }) async {

    try {
      final userId = await _helper.createUser(
        role: role,
        name: name,
        email: email,
        password: pass,
        designation: designation,
        creator: adminId,
        fcm: fcm,
      );

      final user = User.fromMap({
        "id": userId,
        "role": role.toString(),
        "name": name,
        "email": email,
        "password": pass,
        "designation": designation,
        "creator": adminId.toString(),
        "fcm": fcm,
      });

      return user;

    } catch (e) {

      debugPrint("addNewUser error: ${e.toString()}");
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


  Future<void> deleteUser( String id ) async {

    try {
      await _helper.deleteUser(id);
    } catch (e) {

      debugPrint("deleteUser error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<List<User>> getAllUsers() async {

    try {
      final usersMap = await _helper.getUsers();

      final users = usersMap.entries.map<User>((entry) {
        final Map<String, String> userMap = Map<String, String>.from(entry.value);
        return User.fromMap(userMap);
      }).toList();

      return users;

    } catch (e) {

      debugPrint("getAllUsers error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  /// tasks methods
  Future<List<Tasks>> getAllTasks() async {

    try {
      final tasksMap = await _helper.getAllTasks();

      final tasks = tasksMap.entries.map<Tasks>((entry) {
        final Map<String, String> userMap = Map<String, String>.from(entry.value);
        return Tasks.fromMap(userMap);
      }).toList();

      return tasks;

    } catch (e) {

      debugPrint("getAllTasks error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<Tasks> addNewTask({
    required String title,
    required String desc,
    required String adminId,
    required String workerId,
    required String due,
  }) async {

    final updates = {"created": DateTime.now().toString()};

    try {
      final taskId = await _helper.createTask(
        title: title,
        desc: desc,
        dueDate: due,
        updates: jsonEncode(updates),
        status: TaskStatusEnum.idle.id,
        worker: workerId,
        creator: adminId,
      );

      final task = Tasks(
        taskId: (taskId ?? '').toString(),
        title: title,
        desc: desc,
        dueDate: due,
        worker: workerId,
        creator: adminId,
        status: TaskStatusEnum.idle,
        updates: updates,
      );

      return task;

    } catch (e) {

      debugPrint("addNewTask error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<void> updateTask({
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

      debugPrint("updateTask error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<Map<DateTime, bool>> userMonthlyAttendance(String userId, DateTime date) async {

    try {
      final data = await _helper.getUserAttendanceForMonth(
        userId,
        "${date.year}-${date.month.toString().padLeft(2,"0")}",
      );

      final Map<DateTime, bool> presentMap = {};

      data.forEach((dateStr, record) {
        final date = DateTime.parse(dateStr);
        final logged = int.tryParse(record["logged"] ?? '0') ?? 0;
        presentMap[DateTime(date.year, date.month, date.day)] = logged > 0;
      });

      return presentMap;

    } catch (e) {

      debugPrint("admin userMonthlyAttendance error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }

  Future<Map<String, bool>> userDailyAttendance(DateTime date) async {

    try {
      final data = await _helper.getAllAttendanceForDay(
        "${date.year}-"
        "${date.month.toString().padLeft(2,"0")}-"
        "${date.day.toString().padLeft(2,"0")}",
      );

      final Map<String, bool> presentMap = {};

      data.forEach((dateStr, record) {
        final key = record["worker"];
        final logged = int.tryParse(record["logged"] ?? '0') ?? 0;
        presentMap[key] = logged > 0;
      });

      return presentMap;

    } catch (e) {

      debugPrint("admin userDailyAttendance error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }

  Future<List<String>> getAllActiveUsers() async {

    try {
      final data = await _helper.getAllActiveUsers();

      final List<String> presentList = [];

      data?.forEach((dateStr, record) {
        final key = record["worker"];
        presentList.add(key);
      });

      return presentList;

    } catch (e) {

      debugPrint("admin getAllActiveUsers error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }


  Future<Map<String, Map<String, dynamic>>> getLocDataByUserId(String userId, DateTime date) async {

    try {
      final data = await _helper.getLocDataByUserId(
        userId,
        "${date.year}-"
        "${date.month.toString().padLeft(2,"0")}-"
        "${date.day.toString().padLeft(2,"0")}",
      );

      final Map<String, Map<String, dynamic>> locMap = {};

      data.forEach((dateStr, record) {
        locMap[dateStr] = {
          "latitude"      : record["latitude"]      ?? '',
          "longitude"     : record["longitude"]     ?? '',
          "timestamp"     : record["timestamp"]     ?? '',
          "taskId"        : record["taskId"]        ?? '',
          "batteryLevel"  : record["batteryLevel"]  ?? '',
          "event"         : record["event"]         ?? '',
        };
      });

      return locMap;
    } catch (e) {

      debugPrint("admin getLocDataByUserId error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }

  }


  /// quotation methods

  Future<Quotation> addNewQuotation(Quotation quotation) async {

    try {
      final quotationId = await _helper.createQuotation(quotation.toMap());

      if (quotationId == null) throw Exception();

      final res = quotation.copyWith(quotationId);

      return res;

    } catch (e) {

      debugPrint("addNewQuotation error: ${e.toString()}");
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

  Future<void> deleteQuotation(Quotation quotation) async {

    try {

      await _helper.deleteQuotation(quotation.toMap());
      return;

    } catch (e) {

      debugPrint("deleteQuotation error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }

  Future<List<Quotation>> getAllQuotations() async {

    try {
      final quotationMap = await _helper.getAllQuotations();

      final quotations = quotationMap.entries.map<Quotation>((entry) {
        final Map<String, String> dataMap = Map<String, String>.from(entry.value);
        return Quotation.fromMap(dataMap);
      }).toList();

      return quotations;

    } catch (e) {

      debugPrint("getAllQuotations error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }

  Future<List<Quotation>> getAllQuotationsByUserId(Quotation quotation) async {

    try {
      final quotationMap = await _helper.getQuotationsByUserId(quotation.toMap());

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

  Future<List<Quotation>> getAllQuotationsByTaskId(Quotation quotation) async {

    try {
      final quotationMap = await _helper.getQuotationsByTaskId(quotation.toMap());

      final quotations = quotationMap.entries.map<Quotation>((entry) {
        final Map<String, String> dataMap = Map<String, String>.from(entry.value);
        return Quotation.fromMap(dataMap);
      }).toList();

      return quotations;

    } catch (e) {

      debugPrint("getAllQuotationsByTaskId error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }
}