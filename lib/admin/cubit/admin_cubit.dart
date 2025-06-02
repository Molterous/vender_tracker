import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/admin/cubit/admin_state.dart';
import 'package:vender_tracker/admin/repo/admin_repo.dart';
import 'package:vender_tracker/common/enums/admin_page_type.dart';
import 'package:vender_tracker/common/helpers/method_channel_helper.dart';
import 'package:vender_tracker/common/models/quotation.dart';
import 'package:vender_tracker/main.dart';
import '../../common/enums/page_status.dart';
import '../../common/enums/user_roles_enum.dart';
import '../../common/helpers/internet_manager.dart';
import '../../common/models/user.dart';

class AdminCubit extends Cubit<AdminState> {

  late final AdminRepo _repository;
  final InternetManager _netManager = InternetManager.instance;

  AdminCubit() : _repository = AdminRepo(), super(AdminState());


  void addUser({
    required String name,
    required String email,
    required String pass,
    required String designation,
    required int role,
  }) async {

    emit(state.copyWith(pageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final user = await _repository.addNewUser(
        name: name,
        email: email,
        pass: pass,
        designation: designation,
        role: role,
        adminId: globalActiveUser!.userId,
      );

      final newList = List.of(state.users, growable: true)..add(user);

      emit(state.copyWith(users: newList, pageStatus: PageStatus.success));

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void updateUser({
    required String name,
    required String email,
    required String pass,
    required String designation,
    required int role,
    required String userId,
    required String creatorId,
    bool selfUpdate = false,
  }) async {

    emit(state.copyWith(pageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.updateUser(
        id: userId,
        name: name,
        email: email,
        pass: pass,
        designation: designation,
        role: role,
        adminId: creatorId,
      );

      if (selfUpdate) {

        final newUser = globalActiveUser!.copyWith(
          name: name,
          password: pass,
          email: email,
        );
        globalActiveUser = newUser;
        emit(state.copyWith(pageStatus: PageStatus.success));

      } else {

        getAllUsers();
      }

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void deleteUser({ required String userId }) async {

    emit(state.copyWith(pageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.deleteUser(userId);

      getAllUsers();
    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void getAllUsers() async {

    emit(state.copyWith(pageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final users = await _repository.getAllUsers();

      users.removeWhere((element) {
        return element.userId == '6829c017002d6125d5a5' ||    // super admin id
            element.userId == globalActiveUser!.userId;      // curr admin id
      });
      emit(state.copyWith(users: users, pageStatus: PageStatus.success));
    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void getAllTasks() async {

    emit(state.copyWith(taskPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final tasks = await _repository.getAllTasks();

      emit(state.copyWith(tasks: tasks, taskPageStatus: PageStatus.success));
    } catch (e) {

      emit(state.copyWith(
        taskPageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void addTask({
    required String title,
    required String desc,
    required String workerId,
    required String due,
  }) async {

    emit(state.copyWith(taskPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final task = await _repository.addNewTask(
        title: title,
        desc: desc,
        workerId: workerId,
        adminId: "1000",
        due: due,
      );

      final newList = List.of(state.tasks, growable: true)..add(task);

      emit(state.copyWith(tasks: newList, taskPageStatus: PageStatus.success));

    } catch (e) {

      emit(state.copyWith(
        taskPageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void updateTask({
    required String taskId,
    required String title,
    required String desc,
    required Map<String, dynamic> updates,
    required String workerId,
    required String adminId,
    required String due,
    required int status,
  }) async {

    emit(state.copyWith(taskPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.updateTask(
        taskId: taskId,
        title: title,
        desc: desc,
        updates: updates,
        status: status,
        workerId: workerId,
        adminId: adminId,
        due: due,
      );

      getAllTasks();
    } catch (e) {

      emit(state.copyWith(
        taskPageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void getAttendanceDataForUser(String userId, DateTime date) async {

    emit(state.copyWith(attendancePageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final data = await _repository.userMonthlyAttendance(userId, date);

      emit(state.copyWith(
        attendancePageStatus: PageStatus.initial,
        presentDays: data,
        focusedDay: date,
      ));

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        attendancePageStatus: PageStatus.initial,
        errorMessage: e.toString(),
      ));
    }

  }


  void getAllUsersAttendanceForDay(DateTime date) async {

    emit(state.copyWith(attendancePageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final data = await _repository.userDailyAttendance(date);

      emit(state.copyWith(
        attendancePageStatus: PageStatus.initial,
        presentUsers: data,
        focusedDay: date,
      ));

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        attendancePageStatus: PageStatus.initial,
        errorMessage: e.toString(),
      ));
    }

  }


  void getAllActiveUsers() {
    Timer.periodic(const Duration(minutes: 5), (t) => _getActiveUserUtil(t));
    _getActiveUserUtil();
  }

  Future<void> _getActiveUserUtil([Timer? timer]) async {

    if (globalActiveUser?.role != UserRolesEnum.admin) {
      timer?.cancel();
      return;
    }

    emit(state.copyWith(activeUserPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final data = await _repository.getAllActiveUsers();

      emit(state.copyWith(
        activeUserPageStatus: PageStatus.initial,
        activeUsers: data,
      ));

    } catch (e) {

      emit(state.copyWith(
        activeUserPageStatus: PageStatus.initial,
        errorMessage: e.toString(),
      ));
      rethrow;
    }
  }


  void getLocDataForUser(String userId, DateTime date) async {

    emit(state.copyWith(locPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final data = await _repository.getLocDataByUserId(userId, date);

      emit(state.copyWith(
        locPageStatus: PageStatus.initial,
        locData: data,
        focusedDay: date,
      ));

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        locPageStatus: PageStatus.initial,
        errorMessage: e.toString(),
      ));
    }

  }


  void getAllQuotations() async {

    emit(state.copyWith(quotationPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final quotations = await _repository.getAllQuotations();
      emit(state.copyWith(
        quotations: quotations,
        quotationPageStatus: PageStatus.success,
      ));

    } catch (e) {

      emit(state.copyWith(
        quotationPageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }

  void addQuotation(Quotation quotation) async {

    emit(state.copyWith(quotationPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final newQuotation = await _repository.addNewQuotation(quotation);

      final newList = List.of(state.quotations, growable: true)..add(newQuotation);

      emit(state.copyWith(
        quotations: newList,
        quotationPageStatus: PageStatus.success,
      ));

    } catch (e) {

      emit(state.copyWith(
        quotationPageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }

  void updateQuotation(Quotation quotation) async {

    emit(state.copyWith(quotationPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.updateQuotation(quotation);
      getAllQuotations();

    } catch (e) {

      emit(state.copyWith(
        quotationPageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }

  void deleteQuotation(Quotation quotation) async {

    emit(state.copyWith(quotationPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.deleteQuotation(quotation);
      getAllQuotations();

    } catch (e) {

      emit(state.copyWith(
        quotationPageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void changePage(AdminPageType page) => emit(state.copyWith(currPage: page));


  void changeTaskSelectedUser(User user) => emit(state.copyWith(taskSelectedUser: user));


  void changeAttendanceSelectedUser(User user) => emit(state.copyWith(attendanceSelectedUser: user));

  void changeLocSelectedUser(User user) => emit(state.copyWith(locSelectedUser: user));


  void changeAttendancePageType() => emit(state.copyWith(isDatePickerPage: !state.isDatePickerPage));


  void clearFilters() => emit(state.clearFilter());


  Future<bool> logout() async {

    try {

      final helper = MethodChannelHelper.instance;
      await helper.logout();
      await helper.clearSaveLoggedTime();

      return true;
    } catch(e) {

      debugPrint("logout exception: ${e.toString()}");
      return false;
    }

  }
}