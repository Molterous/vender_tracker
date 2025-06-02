import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/admin/cubit/admin_cubit.dart';
import 'package:vender_tracker/admin/cubit/admin_state.dart';
import 'package:vender_tracker/common/enums/page_status.dart';
import 'package:vender_tracker/users/views/attendance_page.dart';
import '../../common/models/user.dart';
import '../../common/ui/lottie_pages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class AttendancePage extends StatelessWidget {

  final AdminState state;

  const AttendancePage({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {

    if (state.attendancePageStatus.isLoading) {
      return LoadingPage();
    }

    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (!state.isDatePickerPage) ...[

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<User>(
              value: state.attendanceSelectedUser,
              decoration: InputDecoration(
                labelText: l10n.filterByUser,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: state.users.map((user) => DropdownMenuItem(
                value: user,
                child: Text('${user.name} (${user.userId})'),
              )).toList(),
              onChanged: (user) {
                final cubit = context.read<AdminCubit>();

                if (user == null) {
                  cubit.clearFilters();
                } else {
                  cubit.changeAttendanceSelectedUser(user);
                  cubit.getAttendanceDataForUser(
                    user.userId,
                    DateTime.now(),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 4),
        ],

        if (state.attendanceSelectedUser != null && !state.isDatePickerPage) ...[
          AttendanceCalendar(
            presentDays: state.presentDays,
            focusedDay: state.focusedDay,
            lastDay: DateTime(now.year, now.month + 1, 0), // end of current month
            firstDay: DateTime(now.year - 1, now.month, 1), // start of month, 1 year ago
            onPageChange: (newDate) => context
                .read<AdminCubit>()
                .getAttendanceDataForUser(
                  state.attendanceSelectedUser!.userId,
                  newDate,
                ),
          ),
          const SizedBox(height: 15),

          // export btn
          _exportBtn(context, l10n),
          const SizedBox(height: 10),

          // info
          _buildInfoField(l10n.absent, Colors.red),
          _buildInfoField(l10n.present, Colors.green),
        ],

        if (state.isDatePickerPage) ...[

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text("${l10n.selectedDate}: ${state.focusedDay.toLocal().toString().split(' ')[0]}"),
                ),
                const SizedBox(width: 5),

                // date picker
                GestureDetector(
                  onTap: () async {

                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now.subtract(const Duration(days: 365)),
                      lastDate: now,
                      currentDate: state.focusedDay,
                    );

                    if (picked != null && context.mounted) {
                      context
                          .read<AdminCubit>()
                          .getAllUsersAttendanceForDay(picked);
                    }
                  },
                  child: Icon(Icons.date_range),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),

          // list view
          Expanded(
            child: ListView.builder(
              itemCount: state.users.length,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemBuilder: (context, index) {

                final user = state.users[index];
                final isActive = state.presentUsers[user.userId] ?? false;

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
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );

              },
            ),
          ),
        ],

        if (state.attendanceSelectedUser == null && !state.isDatePickerPage) ...[
          Expanded(child: Center(
            child: Text(
              l10n.pleaseSelectAUserFirst,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _exportBtn(BuildContext context, AppLocalizations l10n) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ElevatedButton(
        onPressed: () {

          List<String> header = [];
          header.add('S.No.');
          header.add('Date');
          header.add('Attendance');

          List<List<String>> listOfLists = [];

          final eventDates = state.presentDays.keys.toList();
          final activeList = state.presentDays.values.toList();

          for (var i=0; i< eventDates.length; i++) {
            final date = eventDates[i].toLocal().toString().split(' ')[0];
            List<String> data = ['${i+1}', date, activeList[i] ? l10n.present : l10n.absent ];
            listOfLists.add(data);
          }

          exportCSV.myCSV(header, listOfLists);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          l10n.export,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoField(String title, Color color) {

    return Padding(
      padding: const EdgeInsets.all(15),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 20,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}