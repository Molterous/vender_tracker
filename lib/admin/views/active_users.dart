import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/admin/cubit/admin_cubit.dart';
import 'package:vender_tracker/admin/cubit/admin_state.dart';
import 'package:vender_tracker/common/enums/page_status.dart';
import 'package:vender_tracker/users/views/attendance_page.dart';
import '../../common/models/user.dart';
import '../../common/ui/lottie_pages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActiveUsersPage extends StatelessWidget {

  final AdminState state;

  const ActiveUsersPage({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {

    if (state.attendancePageStatus.isLoading) {
      return const LoadingPage();
    }

    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (state.activeUsers.isNotEmpty) ...[
            // list view
            Expanded(
              child: ListView.builder(
                itemCount: state.activeUsers.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {

                  final user = state.usersMap[state.activeUsers[index]];

                  if (user == null) return const SizedBox();

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                      margin: EdgeInsets.only(left: 5),
                      child: ListTile(
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${l10n.roleID}: ${user.userId}: (${user.role.name})'),
                        trailing: Icon(
                          Icons.circle,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );

                },
              ),
            ),
          ],

          if (state.activeUsers.isEmpty) ...[
            const Expanded(child: Center(child: NoDataFoundPage())),
          ],
        ],
      ),
    );
  }

}