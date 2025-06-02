import 'package:flutter/cupertino.dart';
import 'package:vender_tracker/common/helpers/pref_helper.dart';
import 'package:vender_tracker/common/models/user.dart';
import '../../common/helpers/method_channel_helper.dart';

class LoginRepo {

  final _helper = MethodChannelHelper.instance;

  LoginRepo();

  Future<void> saveActiveUser(String name, String id) async {

    try {
      await _helper.saveUserInfo(name, id);
    } catch (e) {

      debugPrint("addNewUser error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<User?> checkLogin(String email, String password) async {
    try {

      final userMap = await _helper.getUserByEmail(email);

      if (userMap != null) {
        final user = User.fromMap(userMap);

        if (user.password == password) { return user; }
      }

      return null;
    } catch (e) {

      debugPrint("addNewUser error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }


  Future<User?> getActiveUser() async {

    try {
      final userId = await _helper.getSavedUserInfo();

      if ((userId ?? "").isEmpty) { return null; }

      final userMap = await _helper.getUserById(userId!);

      final user = User.fromMap(userMap);

      if (await SharedPreferenceHelper.instance.getPunchInStatus()) {
        await _helper.startLocationLogging();
      }

      return user;
    } catch (e) {

      debugPrint("addNewUser error: ${e.toString()}");
      throw(Exception("Something went Wrong"));
    }
  }

}