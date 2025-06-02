import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vender_tracker/users/cubit/user_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../common/ui/lottie_pages.dart';

class AttendancePage extends StatelessWidget {

  final bool isLoading;
  final DateTime focusedDay;
  final Map<DateTime, bool> presentDays;

  const AttendancePage({
    super.key,
    required this.focusedDay,
    this.isLoading    = false,
    this.presentDays  = const {}
  });

  @override
  Widget build(BuildContext context) {

    if (isLoading)  return LoadingPage();

    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AttendanceCalendar(
          presentDays: presentDays,
          focusedDay: focusedDay,
          lastDay: DateTime(now.year, now.month + 1, 0), // end of current month
          firstDay: DateTime(now.year - 1, now.month, 1), // start of month, 1 year ago
          onPageChange: (newDate) => context
              .read<UserCubit>()
              .getAttendanceDataForUser(newDate),
        ),
        const SizedBox(height: 10),

        // info
        _buildInfoField(l10n.absent, Colors.red),
        _buildInfoField(l10n.present, Colors.green),

        const Spacer(),
        _buildInfoField(
          l10n.attendanceNote,
          Colors.purple,
        ),
      ],
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
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceCalendar extends StatelessWidget {

  final Map<DateTime, bool> presentDays;
  final DateTime focusedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final Function(DateTime newDate) onPageChange;

  const AttendanceCalendar({
    super.key,
    required this.presentDays,
    required this.focusedDay,
    required this.firstDay,
    required this.lastDay,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {

    return TableCalendar(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: focusedDay,
      availableCalendarFormats: const { CalendarFormat.month: 'Month' },
      headerStyle: const HeaderStyle(formatButtonVisible: false),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          return _buildDayCell(day);
        },
        todayBuilder: (context, day, _) {
          return _buildDayCell(day);
        },
      ),
      onPageChanged: (focusedDay) => onPageChange.call(focusedDay),
    );
  }

  Widget _buildDayCell(DateTime day) {

    final normalizedDay = DateTime(day.year, day.month, day.day);
    final isPresent = presentDays[normalizedDay];

    if (isPresent != null) {
      return Container(
        decoration: BoxDecoration(
          color: isPresent ? Colors.green : Colors.red,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: day.isAfter(DateTime.now()) ? Colors.grey : null),
        ),
      );
    }
  }
}