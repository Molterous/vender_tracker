import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/common/enums/user_page_type.dart';
import 'package:vender_tracker/common/helpers/method_channel_helper.dart';
import 'package:vender_tracker/common/helpers/pref_helper.dart';
import 'package:vender_tracker/main.dart';
import 'package:vender_tracker/users/cubit/user_state.dart';
import 'package:vender_tracker/users/repo/user_repo.dart';
import '../../common/enums/page_status.dart';
import '../../common/helpers/internet_manager.dart';
import '../../common/models/quotation.dart';

class UserCubit extends Cubit<UserState> {

  final UserRepo _repository;
  final InternetManager _netManager = InternetManager.instance;
  final SharedPreferenceHelper _prefManager = SharedPreferenceHelper.instance;

  UserCubit()  : _repository = UserRepo(), super(UserState());


  void getAllTasksForUser() async {

    emit(state.copyWith(pageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final tasks = await _repository.getAllTasksForUser(globalActiveUser!.userId);

      // final now = DateTime.now();
      // final checkDate = DateTime(now.year, now.month, now.day).toString();
      // final filteredTasks = tasks.where((ele) => ele.dueDate == checkDate).toList();
      final filteredTasks = tasks;

      emit(state.copyWith(
        tasks: tasks,
        todayTasks: filteredTasks,
        pageStatus: PageStatus.success,
      ));

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
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

    emit(state.copyWith(pageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.updateTaskForUser(
        taskId: taskId,
        title: title,
        desc: desc,
        updates: updates,
        status: status,
        workerId: workerId,
        adminId: adminId,
        due: due,
      );

      getAllTasksForUser();
    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void punchIn() async {

    emit(state.copyWith(punchStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.startLocTracking();
      await _repository.markUserAttendance();
      checkPunchedInStatus();
      getLoggedTime();

      emit(state.copyWith(punchStatus: PageStatus.initial));
    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        punchStatus: PageStatus.initial,
        errorMessage: e.toString(),
      ));
    }

  }


  Future<void> punchOut() async {

    emit(state.copyWith(punchStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.stopLocTracking();
      await _repository.updateLoggedTime();
      checkPunchedInStatus();
      getLoggedTime();

      emit(state.copyWith(punchStatus: PageStatus.initial));
    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        punchStatus: PageStatus.initial,
        errorMessage: e.toString(),
      ));
    }

  }


  void getLoggedTime() async {

    emit(state.copyWith(logStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final time = await _repository.getLoggedTime();
      final logged = Duration(minutes: time);

      emit(state.copyWith(
        loggedTime: logged,
        logStatus: PageStatus.initial,
      ));
    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        logStatus: PageStatus.initial,
        errorMessage: e.toString(),
      ));
    }

  }


  void getAttendanceDataForUser(DateTime date) async {

    emit(state.copyWith(attendancePageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final data = await _repository.userMonthlyAttendance(date);

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


  void changePage(UserPageType page) => emit(state.copyWith(currPage: page));


  void checkPunchedInStatus() async {
    final data = await _prefManager.getPunchInStatus();
    emit(state.copyWith(isPunchedIn: data));
  }


  void updateUser({
    required String name,
    required String email,
    required String pass,
    required String designation,
    required int role,
    required String userId,
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
        adminId: globalActiveUser!.creator,
      );

      final newUser = globalActiveUser!.copyWith(
        name: name,
        password: pass,
        email: email,
      );
      globalActiveUser = newUser;

      emit(state.copyWith(pageStatus: PageStatus.success));

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void getAllQuotationsForUser() async {

    emit(state.copyWith(quotationPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final quotations = await _repository.getAllQuotationsByUserId(globalActiveUser!.userId);
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

  void updateQuotation(Quotation quotation) async {

    emit(state.copyWith(quotationPageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      await _repository.updateQuotation(quotation);
      getAllQuotationsForUser();

    } catch (e) {

      emit(state.copyWith(
        quotationPageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void clearFilters() => emit(state.clearFilter());

  Future<bool> logout() async {

    try {

      final helper = MethodChannelHelper.instance;
      await punchOut();
      await helper.stopLocationLogging();
      await helper.clearSaveLoggedTime();
      await helper.logout();

      return true;
    } catch(e) {

      debugPrint("user logout exception: ${e.toString()}");
      return false;
    }

  }
}