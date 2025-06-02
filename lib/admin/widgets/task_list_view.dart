import 'package:flutter/material.dart';
import 'package:vender_tracker/admin/widgets/task_viewing_screen.dart';
import 'package:vender_tracker/common/enums/task_status_enum.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import 'package:vender_tracker/common/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskListView extends StatelessWidget {

  final List<Tasks> tasks;
  final Map<String, User> userMap;
  final void Function(Tasks tasks) onEdit;
  final void Function(Tasks tasks) onStatusChange;
  final bool showEditOption;

  const TaskListView({
    super.key,
    required this.tasks,
    this.userMap = const {},
    required this.onEdit,
    required this.onStatusChange,
    this.showEditOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) => TaskCardWidget(
        task            : tasks[index],
        userName        : userMap[tasks[index].worker]?.name,
        showEditOption  : showEditOption,
        onStatusChange  : () => onStatusChange(tasks[index]),
        onEdit          : () => onEdit(tasks[index]),
      ),
    );
  }
}


class TaskCardWidget extends StatelessWidget {
  final Tasks task;
  final String? userName;
  final bool showEditOption;
  final VoidCallback onStatusChange, onEdit;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onStatusChange,
    required this.onEdit,
    this.showEditOption = true,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskViewingScreen(
            task: task,
            userName: userName == null ? null : '$userName (${task.worker})',
          )),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        color: _getColor(task),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          margin: EdgeInsets.only(left: 5),
          child: ListTile(
            title: Text(task.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(task.desc),
                const SizedBox(height: 4),
                Text('${l10n.dueOn}: ${task.dueDate.split(" ").first}'),

                if (userName != null) ...[
                  const SizedBox(height: 2),
                  Text('${l10n.assignedTo}: ${(userName ?? '')} (${task.worker})'),
                ],

                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => onStatusChange.call(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: _getColor(task),
                    ),
                    child: Text(
                      _getLocalisedTaskTitle(task.status.title, l10n),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            trailing: showEditOption
                ? IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit.call(),
                    tooltip: 'Edit',
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Color _getColor(Tasks task) {
    return task.status == TaskStatusEnum.idle
        ? Colors.red
        : (task.status == TaskStatusEnum.working
            ? Colors.orange
            : Colors.green);
  }

  String _getLocalisedTaskTitle(String title, AppLocalizations l10n) {

    switch(title) {
      case "In-Progress": return l10n.inProgress;
      case "Completed": return l10n.completed;
      default: return l10n.idle;
    }
  }
}
