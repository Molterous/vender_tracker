import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vender_tracker/common/helpers/pref_helper.dart';
import 'package:vender_tracker/main.dart';

class MethodChannelHelper {
  /// singleton class instance
  static final MethodChannelHelper _inst = MethodChannelHelper._privateConstructor();
  static MethodChannelHelper get instance => _inst;

  /// private constructor
  MethodChannelHelper._privateConstructor();

  /// platform
  final platform = const MethodChannel(_methodChannelKey);
  final _prefHelper = SharedPreferenceHelper.instance;


  /// functions

  /// login methods
  // Save user info (basic)
  Future<void> saveUserInfo(String userName, String userId) async {
    try {
      await platform.invokeMethod(_saveUserData, {
        _nameKey: userName,
        _empIdKey: userId,
      });
      debugPrint('$_classTag saveUserData completed successfully');
    } on PlatformException catch (e, _) {
      debugPrint('$_classTag saveUserData exception: ${e.message}');
    } catch (e) {
      debugPrint('$_classTag saveUserData exception: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await platform.invokeMethod(_saveUserData, {
        _nameKey: "",
        _empIdKey: "",
      });
      globalActiveUser = null;
      debugPrint('$_classTag saveUserData completed successfully');
    } on PlatformException catch (e, _) {
      debugPrint('$_classTag saveUserData exception: ${e.message}');
    } catch (e) {
      debugPrint('$_classTag saveUserData exception: ${e.toString()}');
    }
  }

  // Save user info (basic)
  Future<String?> getSavedUserInfo() async {
    try {
      final id = await platform.invokeMethod(_getSavedUserData, {});
      debugPrint('$_classTag getSavedUserInfo completed successfully');

      return id;
    } on PlatformException catch (e, _) {
      debugPrint('$_classTag getSavedUserInfo exception: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('$_classTag getSavedUserInfo exception: ${e.toString()}');
      return null;
    }
  }


  Future<void> clearSaveLoggedTime() async {
    try {
      final id = await platform.invokeMethod(_clearSaveLoggedTime);
      debugPrint('$_classTag clearSaveLoggedTime completed successfully');

      return id;
    } on PlatformException catch (e, _) {
      debugPrint('$_classTag clearSaveLoggedTime exception: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('$_classTag clearSaveLoggedTime exception: ${e.toString()}');
      return null;
    }
  }


  /// Location methods
  // Start location logging
  Future<void> startLocationLogging() async {
    try {

      final date = DateTime.now();
      final dateStr = "${date.year}-"
          "${date.month.toString().padLeft(2,"0")}-"
          "${date.day.toString().padLeft(2,"0")}";

      await platform.invokeMethod(_startLoggingMethod, {
        "id": globalActiveUser!.userId.toString(),
        "date": dateStr,
      });
      debugPrint('$_classTag startLocationLogging completed successfully');
    } on PlatformException catch (e, _) {
      debugPrint('$_classTag startLocationLogging exception: ${e.message}');
    } catch (e) {
      debugPrint('$_classTag startLocationLogging exception: ${e.toString()}');
    }
  }

  // Stop location logging
  Future<void> stopLocationLogging() async {
    try {

      final date = DateTime.now();
      final dateStr = "${date.year}-"
          "${date.month.toString().padLeft(2,"0")}-"
          "${date.day.toString().padLeft(2,"0")}";

      await platform.invokeMethod(_stopLoggingMethod, {
        "id": globalActiveUser!.userId.toString(),
        "date": dateStr,
      });

      debugPrint('$_classTag stopLocationLogging completed successfully');
    } on PlatformException catch (e, _) {
      debugPrint('$_classTag stopLocationLogging exception: ${e.message}');
    } catch (e) {
      debugPrint('$_classTag stopLocationLogging exception: ${e.toString()}');
    }
  }


  /// user management methods
  // Create user
  Future<String?> createUser({
    required int role,
    required String name,
    required String email,
    required String password,
    required String designation,
    required String creator,
    String? fcm,
  }) async {
    try {
      final userId = await platform.invokeMethod<String>(_createUserMethod, {
        'role': role,
        'name': name,
        'email': email,
        'password': password,
        'designation': designation,
        'creator': creator,
        'fcm': fcm,
      });
      debugPrint('$_classTag createUser success: $userId');
      return userId;
    } catch (e) {
      debugPrint('$_classTag createUser exception: ${e.toString()}');
      return null;
    }
  }

  // Update user
  Future<void> updateUser({
    required String id,
    required int role,
    required String name,
    required String email,
    required String password,
    required String designation,
    required String creator,
    String? fcm,
  }) async {
    try {
      await platform.invokeMethod(_updateUserMethod, {
        'id': id,
        'role': role,
        'name': name,
        'email': email,
        'password': password,
        'designation': designation,
        'creator': creator,
        'fcm': fcm,
      });
      debugPrint('$_classTag updateUser success');
    } catch (e) {
      debugPrint('$_classTag updateUser exception: ${e.toString()}');
    }
  }

  // Delete user
  Future<void> deleteUser(String id) async {
    try {
      await platform.invokeMethod(_deleteUserMethod, {
        'id': id,
      });
      debugPrint('$_classTag deleteUser success');
    } catch (e) {
      debugPrint('$_classTag deleteUser exception: ${e.toString()}');
    }
  }

  // Get user by email
  Future<dynamic> getUserByEmail(String email) async {
    try {
      final user = await platform.invokeMethod(_getUserByEmailMethod, {
        'email': email,
      });
      debugPrint('$_classTag getUserByEmail success: $user');
      return (user as Map?)?.map<String, dynamic>((key, value) {
        return MapEntry(key.toString(), value.toString());
      });
    } catch (e) {
      debugPrint('$_classTag getUserByEmail exception: ${e.toString()}');
      return null;
    }
  }

  // Get user by id
  Future<dynamic> getUserById(String id) async {
    try {
      final user = await platform.invokeMethod(_getUserByIdMethod, {
        'id': id,
      });
      debugPrint('$_classTag getUserByEmail success: $user');
      return (user as Map?)?.map<String, dynamic>((key, value) {
        return MapEntry(key.toString(), value.toString());
      });
    } catch (e) {
      debugPrint('$_classTag getUserByEmail exception: ${e.toString()}');
      return null;
    }
  }

  // Get user by email
  Future<dynamic> getUsers() async {
    try {
      final users = await platform.invokeMethod(_getUsersMethod, {});
      debugPrint('$_classTag getUsers success: $users');
      return users;
    } catch (e) {
      debugPrint('$_classTag getUsers exception: ${e.toString()}');
      return null;
    }
  }


  /// tasks management methods
  // Create Task
  Future<String?> createTask({
    required int status,
    required String title,
    required String desc,
    required String dueDate,
    required String updates,
    required String worker,
    required String creator,
  }) async {
    try {
      final taskId = await platform.invokeMethod<String>(_createTaskMethod, {
        'status': status,
        'title': title,
        'desc': desc,
        'dueDate': dueDate,
        'updates': updates,
        'worker': worker,
        'creator': creator,
      });
      debugPrint('$_classTag createTask success: $taskId');
      return taskId;
    } catch (e) {
      debugPrint('$_classTag createTask exception: ${e.toString()}');
      return null;
    }
  }

  // Update Task
  Future<void> updateTask({
    required String id,
    required int status,
    required String title,
    required String desc,
    required String dueDate,
    required String updates,
    required String worker,
    required String creator,
  }) async {
    try {
      await platform.invokeMethod(_updateTaskMethod, {
        'id': id,
        'status': status,
        'title': title,
        'desc': desc,
        'dueDate': dueDate,
        'updates': updates,
        'worker': worker,
        'creator': creator,
      });
      debugPrint('$_classTag updateTask success');
    } catch (e) {
      debugPrint('$_classTag updateTask exception: ${e.toString()}');
    }
  }

  // Delete Task
  Future<void> deleteTask(String id) async {
    try {
      await platform.invokeMethod(_deleteTaskMethod, {
        'id': id,
      });
      debugPrint('$_classTag deleteTask success');
    } catch (e) {
      debugPrint('$_classTag deleteTask exception: ${e.toString()}');
    }
  }

  // Get Task by ID
  Future<dynamic> getTaskById(String id) async {
    try {
      final task = await platform.invokeMethod(_getTaskByIdMethod, {
        'id': id,
      });
      debugPrint('$_classTag getTaskById success: $task');
      return task;
    } catch (e) {
      debugPrint('$_classTag getTaskById exception: ${e.toString()}');
      return null;
    }
  }

  // Get Tasks by User
  Future<dynamic> getTasksByUserId(String userId) async {
    try {
      final tasks = await platform.invokeMethod(_getTasksByUserMethod, {
        'userId': userId,
      });
      debugPrint('$_classTag getTasksByUserId success: $tasks');
      return tasks;
    } catch (e) {
      debugPrint('$_classTag getTasksByUserId exception: ${e.toString()}');
      return null;
    }
  }

  // Get All Tasks
  Future<dynamic> getAllTasks() async {
    try {
      final tasks = await platform.invokeMethod(_getAllTasksMethod, {});
      debugPrint('$_classTag getAllTasks success: $tasks');
      return tasks;
    } catch (e) {
      debugPrint('$_classTag getAllTasks exception: ${e.toString()}');
      return null;
    }
  }


  /// attendance methods
  Future<void> logAttendance() async {

    try {

      final now = DateTime.now();
      final entryDate = "${now.year}-"
          "${now.month.toString().padLeft(2,"0")}-"
          "${now.day.toString().padLeft(2,"0")}";  // "2025-05-17",

      final entryTime = "${now.hour.toString().padLeft(2,"0")}:"
          "${now.minute.toString().padLeft(2,"0")}";            // "09:05",

      await _prefHelper.savePunchInStatus();

      await platform.invokeMethod(_logAttendance, {
        "userId": globalActiveUser!.userId,
        "date": entryDate,
        "loginTime": entryTime,
      });
      debugPrint('$_classTag logAttendance success');
    } catch (e) {
      debugPrint('$_classTag logAttendance exception: ${e.toString()}');
      rethrow;
    }
  }

  Future<int> getLoggedTimeOrZero() async {

    try {

      final now = DateTime.now();
      final entryDate = "${now.year}-"
          "${now.month.toString().padLeft(2,"0")}-"
          "${now.day.toString().padLeft(2,"0")}";  // "2025-05-17",

      final time = await platform.invokeMethod(_getLoggedTimeOrZero, {
        "userId": globalActiveUser!.userId,
        "date": entryDate,
      });

      var loggedTime = await _prefHelper.getLoggedTimeInMin(); // "120",
      loggedTime += int.parse(time ?? "0");

      debugPrint('$_classTag getLoggedTimeOrZero success: $time');
      return loggedTime;

    } catch (e) {
      debugPrint('$_classTag getLoggedTimeOrZero exception: ${e.toString()}');
      return 0;
    }
  }

  Future<void> updateLoggedTime(String loggedTime) async {

    try {

      final now = DateTime.now();
      final entryDate = "${now.year}-"
          "${now.month.toString().padLeft(2,"0")}-"
          "${now.day.toString().padLeft(2,"0")}";  // "2025-05-17",

      await platform.invokeMethod(_updateLoggedTime, {
        "userId": globalActiveUser!.userId,
        "date": entryDate,
        "loggedTime": loggedTime.toString(),
      });
      _prefHelper.punchOut();

      debugPrint('$_classTag updateLoggedTime success');

    } catch (e) {
      debugPrint('$_classTag updateLoggedTime exception: ${e.toString()}');
      rethrow;
    }
  }

  Future<dynamic> getUserAttendanceForMonth(String userId, String month) async {

    try {

      final attendances = await platform.invokeMethod(_getUserAttendanceForMonth, {
        "userId": userId,
        "month": month,
      });
      debugPrint('$_classTag getUserAttendanceForMonth success: $attendances');

      return Map<String, Map<String, dynamic>>.from(
        (attendances as Map).map((key, value) => MapEntry(
          key.toString(),
          Map<String, dynamic>.from(value),
        )),
      );
    } catch (e) {
      debugPrint('$_classTag getUserAttendanceForMonth exception: ${e.toString()}');
      return null;
    }
  }

  Future<dynamic> getAllAttendanceForDay(String date) async {

    try {

      final tasks = await platform.invokeMethod(_getAllAttendanceForDay, {
        "date": date,
      });
      debugPrint('$_classTag getAllAttendanceForDay success: $tasks');
      return tasks;

    } catch (e) {
      debugPrint('$_classTag getAllAttendanceForDay exception: ${e.toString()}');
      return null;
    }
  }

  Future<dynamic> getAllActiveUsers() async {

    try {

      final date = DateTime.now();
      final dateStr = "${date.year}-"
          "${date.month.toString().padLeft(2,"0")}-"
          "${date.day.toString().padLeft(2,"0")}";

      final tasks = await platform.invokeMethod(_getAllActiveUsers, {
        "date": dateStr,
      });
      debugPrint('$_classTag getAllActiveUsers success: $tasks');
      return tasks;

    } catch (e) {
      debugPrint('$_classTag getAllActiveUsers exception: ${e.toString()}');
      return null;
    }
  }

  /// location
  Future<dynamic> getLocDataByUserId(String userId, String date) async {

    try {

      final attendances = await platform.invokeMethod(_getLocDataByUserId, {
        "id": userId,
        "date": date, // YYYY-MM-DD
      });
      debugPrint('$_classTag getLocDataByUserId success: $attendances');

      return Map<String, Map<String, dynamic>>.from(
        (attendances as Map).map((key, value) => MapEntry(
          key.toString(),
          Map<String, dynamic>.from(value),
        )),
      );
    } catch (e) {
      debugPrint('$_classTag getLocDataByUserId exception: ${e.toString()}');
      return null;
    }
  }


  /// quotation methods
  Future<String?> createQuotation(Map<String, String> dataMap) async {
    try {
      final quotationsId = await platform.invokeMethod<String>(_addQuotation, dataMap);
      debugPrint('$_classTag createQuotation success: $quotationsId');
      return quotationsId;
    } catch (e) {
      debugPrint('$_classTag createQuotation exception: ${e.toString()}');
      return null;
    }
  }

  Future<void> updateQuotation(Map<String, String> dataMap) async {
    try {
      await platform.invokeMethod(_updateQuotation, dataMap);
      debugPrint('$_classTag updateQuotation success');
      return;
    } catch (e) {
      debugPrint('$_classTag updateQuotation exception: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteQuotation(Map<String, String> dataMap) async {
    try {
      await platform.invokeMethod(_deleteQuotation, dataMap);
      debugPrint('$_classTag deleteQuotation success');
      return;
    } catch (e) {
      debugPrint('$_classTag deleteQuotation exception: ${e.toString()}');
      rethrow;
    }
  }

  Future<dynamic> getQuotationsByUserId(Map<String, String> dataMap) async {
    try {
      final quotationsId = await platform.invokeMethod(_getQuotationsByWorker, dataMap);
      debugPrint('$_classTag getQuotationsByUserId success: $quotationsId');
      return quotationsId;
    } catch (e) {
      debugPrint('$_classTag getQuotationsByUserId exception: ${e.toString()}');
      return null;
    }
  }

  Future<dynamic> getQuotationsByTaskId(Map<String, String> dataMap) async {
    try {
      final quotationsId = await platform.invokeMethod(_getQuotationsByWorker, dataMap);
      debugPrint('$_classTag getQuotationsByTaskId success: $quotationsId');
      return quotationsId;
    } catch (e) {
      debugPrint('$_classTag getQuotationsByTaskId exception: ${e.toString()}');
      return null;
    }
  }

  Future<dynamic> getAllQuotations() async {
    try {
      final quotations = await platform.invokeMethod(_getAllQuotation);
      debugPrint('$_classTag getAllQuotations success');
      return quotations;
    } catch (e) {
      debugPrint('$_classTag getAllQuotations exception: ${e.toString()}');
      return null;
    }
  }


  /// constants
  static const String _classTag = " MethodChannelHelper ";
  static const String _methodChannelKey = "app.channel/native";
  static const String _nameKey = "name";
  static const String _empIdKey = "id";

  /// method names
  // user management
  static const String _saveUserData = "saveUserData";
  static const String _getSavedUserData = "getSavedUserData";
  static const String _createUserMethod = "createUser";
  static const String _updateUserMethod = "updateUser";
  static const String _deleteUserMethod = "deleteUser";
  static const String _getUserByIdMethod = "getUserById";
  static const String _getUserByEmailMethod = "getUserByEmail";
  static const String _getUsersMethod = "getUsers";

  // tasks management
  static const String _createTaskMethod = "createTask";
  static const String _updateTaskMethod = "updateTask";
  static const String _deleteTaskMethod = "deleteTask";
  static const String _getTaskByIdMethod = "getTaskById";
  static const String _getTasksByUserMethod = "getTasksByUserId";
  static const String _getAllTasksMethod = "getAllTasks";

  // location
  static const String _startLoggingMethod = "startLoggingMethod";
  static const String _stopLoggingMethod = "stopLoggingMethod";
  static const String _getLocDataByUserId = "getLocDataByUserId";

  // attendance
  static const String _logAttendance              = "logAttendance";
  static const String _clearSaveLoggedTime        = "clearSaveLoggedTime";
  static const String _updateLoggedTime           = "updateLoggedTime";
  static const String _getUserAttendanceForMonth  = "getUserAttendanceForMonth";
  static const String _getAllAttendanceForDay     = "getAllAttendanceForDay";
  static const String _getAllActiveUsers          = "getAllActiveUsers";
  static const String _getLoggedTimeOrZero        = "getLoggedTimeOrZero";

  // quotation
  static const String _addQuotation               = "addQuotation";
  static const String _updateQuotation            = "updateQuotation";
  static const String _deleteQuotation            = "deleteQuotation";
  static const String _getQuotationsByWorker      = "getQuotationsByWorker";
  // static const String _getQuotationsByTask        = "getQuotationsByTask";
  static const String _getAllQuotation            = "getAllQuotation";
}
