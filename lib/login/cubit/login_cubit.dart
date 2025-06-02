import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vender_tracker/common/helpers/permission_helper.dart';
import 'package:vender_tracker/login/cubit/login_state.dart';
import 'package:vender_tracker/login/repo/login_repo.dart';

import '../../common/enums/page_status.dart';
import '../../common/helpers/internet_manager.dart';
import '../../main.dart';

class LoginCubit extends Cubit<LoginState> {

  final LoginRepo _repository;
  final InternetManager _netManager = InternetManager.instance;

  LoginCubit()  : _repository = LoginRepo(), super(LoginState());

  void loginInit() => emit(state.copyWith(pageStatus: PageStatus.initial));

  void loginUser(String email, String password) async {

    emit(state.copyWith(
      pageStatus: PageStatus.loading,
      errorMessage: "",
    ));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final user = await _repository.checkLogin(email, password);

      if (user == null) {
        emit(state.copyWith(
          pageStatus: PageStatus.initial,
          errorMessage: 'Invalid credentials',
        ));
        return;
      }

      await _repository.saveActiveUser(user.name, user.userId);
      globalActiveUser = user;
      emit(state.copyWith(activeUser: user, pageStatus: PageStatus.success));

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void getActiveUser() async {

    emit(state.copyWith(pageStatus: PageStatus.loading));

    try {

      if (await _netManager.getNetworkStatus() == false) {
        throw(Exception("No internet Connection"));
      }

      final user = await _repository.getActiveUser();
      globalActiveUser = user;

      emit(state.copyWith(activeUser: user, pageStatus: PageStatus.success));

    } catch (e) {

      emit(state.copyWith(
        pageStatus: PageStatus.failure,
        errorMessage: e.toString(),
      ));
    }

  }


  void checkForPermissions() async {

    emit(state.copyWith(pageStatus: PageStatus.loading));
    final req = await PermissionHelper.checkAllPermissions();

    if (!req) {

      final data = await PermissionHelper.getNextPermissionInfo();
      emit(state.copyWith(
        permissionType: data!.first,
        pageStatus: PageStatus.initial,
      ));

    } else {
      getActiveUser();
    }
  }


  void askReqPermissions() async {
    emit(state.copyWith(pageStatus: PageStatus.loading));

    final data = await PermissionHelper.getNextPermissionInfo();

    if (data != null) { await data.second.request(); }

    checkForPermissions();
  }
}