import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/models/user.dart';
import '../../common/ui/lottie_pages.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/add_user_screen.dart';
import '../widgets/confirm_delete_pop_up.dart';
import '../widgets/user_list_view.dart';

class UserManagementScreen extends StatelessWidget {

  final List<User> users;
  const UserManagementScreen({super.key, this.users = const []});

  @override
  Widget build(BuildContext context) {

    if (users.isEmpty) { return NoDataFoundPage(); }

    return Column(
      children: [

        Expanded(
          child: UserListView(
            users: users,
            onEdit: (user) {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddUserScreen(
                  name: user.name,
                  email: user.email,
                  password: user.password,
                  designation: user.designation,
                  rolesEnum: user.role,
                )),
              ).then((value) {

                if (value == null)  return;

                context.read<AdminCubit>().updateUser(
                  name: value["name"],
                  email: value["email"],
                  pass: value["pass"],
                  designation: value["designation"],
                  role: value["role"],
                  userId: user.userId,
                  creatorId: user.creator,
                );

              });
            },
            onDelete: (user) {
              showConfirmDeleteDialog(
                  context: context,
                  onConfirm: () {
                    context.read<AdminCubit>().deleteUser(
                      userId: user.userId,
                    );
                  }
              );
            },
          ),
        ),

      ],
    );
  }
}
