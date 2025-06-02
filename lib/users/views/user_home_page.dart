import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/common/enums/user_page_type.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import 'package:vender_tracker/common/ui/lottie_pages.dart';
import '../../admin/widgets/task_list_view.dart';
import '../../common/enums/task_status_enum.dart';
import '../cubit/user_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserHomePage extends StatelessWidget {

  final List<Tasks> dueTasks;
  final bool isUserPunched;
  final bool isPunchLoading;
  final bool isLogLoading;
  final Duration loggedTime;

  const UserHomePage({
    super.key,
    this.dueTasks = const [],
    this.isUserPunched = false,
    this.isPunchLoading = false,
    this.isLogLoading = false,
    required this.loggedTime,
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // due today heading with see all btn
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${l10n.dueTodayTasks}..",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => context
                    .read<UserCubit>()
                    .changePage(UserPageType.taskManagement),
                child: Text(
                  l10n.seeAllTasks,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),

        // no task text
        if (dueTasks.isEmpty) ...[
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    "${l10n.noDueWork} !!",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Expanded(child: NoDataFoundPage()),
                ],
              ),
            ),
          ),
        ],

        // today due tasks list
        if (dueTasks.isNotEmpty) ...[
          Expanded(
            child: TaskListView(
              tasks: dueTasks,
              onEdit: (_) {},
              showEditOption: false,
              onStatusChange: (task) {
                if (task.status == TaskStatusEnum.completed) return;

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
        Divider(),

        // attendance btn
        Padding(
          padding: const EdgeInsets.all(15),
          child: Wrap(
            children: [
              // attendance heading
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    // title
                    Expanded(
                      child: Text(
                        "${l10n.yourAttendanceStatus}:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    isLogLoading
                        ? CircularProgressIndicator()
                        : GestureDetector(
                            onTap: () => context.read<UserCubit>().getLoggedTime(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${loggedTime.inHours} hr ${loggedTime.inMinutes - (60 * loggedTime.inHours)} min  ${l10n.logged}",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(Icons.refresh),
                              ],
                            ),
                          ),
                  ],
                ),
              ),

              (isPunchLoading)
                  ? Center(child: LinearProgressIndicator())
                  : Row(
                      children: [
                        _btnWidget(
                          isActive: isUserPunched,
                          context: context,
                          text: l10n.punchIn,
                          btnColor: Colors.green,
                          action: () {
                            if (!isUserPunched) {
                              context.read<UserCubit>().punchIn();
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _btnWidget(
                          isActive: !isUserPunched,
                          context: context,
                          text: l10n.punchOut,
                          btnColor: Colors.red,
                          action: () {
                            if (isUserPunched) {
                              context.read<UserCubit>().punchOut();
                            }
                          },
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _btnWidget({
    bool isActive = false,
    required BuildContext context,
    required String text,
    required Color btnColor,
    required VoidCallback action,
  }) {
    final color = isActive ? btnColor : btnColor.withValues(alpha: 0.6);

    return Expanded(
      child: GestureDetector(
        onTap: () => action.call(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
