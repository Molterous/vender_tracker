import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vender_tracker/admin/widgets/update_info_tile.dart';
import 'package:vender_tracker/common/models/tasks.dart';

class TaskViewingScreen extends StatelessWidget {
  final Tasks task;
  final String? userName;

  const TaskViewingScreen({
    super.key,
    required this.task,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.taskDetails,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.assignment, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.desc,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Due date
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text(
                  "${l10n.dueBy}: ${task.dueDate.split(" ").first}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Assigned to
            if (userName != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${l10n.assignedTo}: $userName",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // divider
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),

            // updates heading
            Text(
              l10n.updates,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            // updates list
            Expanded(
              child: SingleChildScrollView(
                child: _buildUpdatesList(task.updates, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatesList(Map<String, dynamic> events, AppLocalizations l10n) {

    final keys = events.keys.toList();
    final val = events.values.toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(keys.length, (index) {

        final time = val[index];

        if (keys[index] == "created") {

          return UpdateInfoTile(
            title: l10n.taskCreated,
            timestamp: time,
          );

        } else if (keys[index] == "1") {

          return UpdateInfoTile(
            title: l10n.movedToInProgress,
            timestamp: time,
          );

        }  else if (keys[index] == "2") {

          return UpdateInfoTile(
            title: l10n.movedToCompleted,
            timestamp: time,
          );

        } else if (keys[index].contains("moved from")) {

          return UpdateInfoTile(
            title: keys[index],
            timestamp: time,
          );

        }

        return const SizedBox();

      }),
    );

  }
}
