import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/admin/widgets/task_list_view.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import 'package:vender_tracker/common/ui/lottie_pages.dart';
import '../../common/models/user.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/add_new_task_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskManagementScreen extends StatelessWidget {

  final List<Tasks> tasks;
  final List<User> users;
  final Map<String, User> userMap;
  final User? selectedUser;
  final bool isLoading;

  const TaskManagementScreen({
    super.key,
    this.tasks = const [],
    this.users = const [],
    this.userMap = const {},
    this.isLoading = true,
    this.selectedUser,
  });

  @override
  Widget build(BuildContext context) {

    if (isLoading)  return LoadingPage();

    if (tasks.isEmpty) return NoDataFoundPage();

    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<User>(
              value: selectedUser,
              decoration: InputDecoration(
                labelText: l10n.filterByUser,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: [
                DropdownMenuItem<User>(
                  value: null,
                  child: Text(l10n.allUsers),
                ),
                ...users.map((user) => DropdownMenuItem(
                  value: user,
                  child: Text('${user.name} (${user.userId})'),
                ))
              ],
              onChanged: (user) {
                final cubit = context.read<AdminCubit>();

                if (user == null) {
                  cubit.clearFilters();
                } else {
                  cubit.changeTaskSelectedUser(user);
                }
              },
            ),
          ),
          const SizedBox(height: 4),

          // task list
          Expanded(
            child: TaskListView(
              userMap: userMap,
              tasks: selectedUser == null
                  ? tasks
                  : tasks.where((ele) => ele.worker == selectedUser!.userId).toList(),
              onEdit: (task) {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTaskScreen(
                    users: users,
                    title: task.title,
                    desc: task.desc,
                    worker: userMap[task.worker],
                    dueDate: task.dueDate,
                    updates: task.updates,
                  )),
                ).then((value) {

                  if (value == null)  return;

                  context.read<AdminCubit>().updateTask(
                    taskId: task.taskId,
                    title: value["title"],
                    desc: value["desc"],
                    due: value["dueDate"],
                    workerId: value["userId"],
                    updates: value["updates"],
                    status: task.status.id,
                    adminId: task.creator,
                  );

                });
              },
              onStatusChange: (_) { },
            ),
          ),

        ],
      ),
    );
  }
}
