import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/admin/widgets/task_list_view.dart';
import 'package:vender_tracker/common/enums/task_status_enum.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import 'package:vender_tracker/common/ui/lottie_pages.dart';
import 'package:vender_tracker/users/cubit/user_cubit.dart';

class TasksDisplayPanel extends StatelessWidget {

  final List<Tasks> tasks;

  const TasksDisplayPanel({
    super.key,
    this.tasks = const [],
  });

  @override
  Widget build(BuildContext context) {

    if (tasks.isEmpty) return NoDataFoundPage();

    return Column(
      children: [

        Expanded(
          child: TaskListView(
            tasks: tasks,
            onEdit: (_) {},
            showEditOption: false,
            onStatusChange: (task) {

              if (task.status == TaskStatusEnum.completed)  return;

              context.read<UserCubit>().updateTask(
                taskId: task.taskId,
                title: task.title,
                desc: task.desc,
                due: task.dueDate,
                workerId: task.worker,
                updates: task.updates,
                status: task.status.id == 0 ? 1 : 2,
                adminId: task.creator,
              );
            },
          ),
        ),

      ],
    );
  }
}
