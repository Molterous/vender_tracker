import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/common/enums/page_status.dart';
import 'package:vender_tracker/login/views/login_page.dart';
import '../../admin/views/admin_panel.dart';
import '../../common/enums/user_roles_enum.dart';
import '../../users/views/user_panel.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit()..checkForPermissions(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.pageStatus.isSuccess && state.activeUser != null) {
            if (state.activeUser!.role == UserRolesEnum.user) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => UserPanel()),
              );
            } else {

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdminPanel()),
              );
            }
          }

          if (state.pageStatus.isSuccess && state.activeUser == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          }
        },
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) => _Splash(
            status: state.pageStatus,
            permissionType: state.permissionType,
          ),
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {

  final String? permissionType;
  final PageStatus status;

  const _Splash({
    this.permissionType,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // app icon
            Icon(Icons.wrong_location, size: 150, color: Colors.white),

            // loader and Req btn
            !status.isLoading
                ? _askPermissionBtn(context)
                : CircularProgressIndicator(color: Colors.white)
          ],
        ),
      ),
    );
  }

  Widget _askPermissionBtn(BuildContext context) {

    if ((permissionType ?? '').isEmpty) { return const SizedBox(); }

    return InkWell(
      onTap: () {
        if (status.isFailure) {
          context.read<LoginCubit>().getActiveUser();
        } else {
          context.read<LoginCubit>().askReqPermissions();
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Text(
          status.isFailure
              ? "Retry"
              : "Allow $permissionType Permissions and Proceed",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
