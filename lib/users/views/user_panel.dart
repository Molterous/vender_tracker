import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/common/enums/page_status.dart';
import 'package:vender_tracker/common/enums/user_page_type.dart';
import 'package:vender_tracker/common/ui/lottie_pages.dart';
import 'package:vender_tracker/login/views/login_page.dart';
import 'package:vender_tracker/main.dart';
import 'package:vender_tracker/quotation/quotation_panel.dart';
import 'package:vender_tracker/users/cubit/user_cubit.dart';
import 'package:vender_tracker/users/cubit/user_state.dart';
import 'package:vender_tracker/users/views/user_home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../admin/widgets/edit_profile_screen.dart';
import '../../common/widgets/language_selector.dart';
import 'attendance_page.dart';
import 'tasks_display_panel.dart';

class UserPanel extends StatelessWidget {

  const UserPanel({super.key});

  @override
  Widget build(context) {

    final menuItems = UserPageType.values.toList();
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => UserCubit()
        ..getAllTasksForUser()
        ..checkPunchedInStatus()
        ..getLoggedTime()
        ..getAttendanceDataForUser(DateTime.now())
        ..getAllQuotationsForUser(),
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {

          late Widget childWidget;

          if ( state.pageStatus.isLoading) {
            childWidget = LoadingPage();

          } else if (state.pageStatus.isSuccess) {

            switch(state.currPage) {

              case UserPageType.taskManagement:
                childWidget = TasksDisplayPanel(tasks: state.tasks);
                break;

              case UserPageType.attendanceScreen:
                childWidget = AttendancePage(
                  focusedDay: state.focusedDay,
                  presentDays: state.presentDays,
                  isLoading: state.attendancePageStatus.isLoading,
                );
                break;

              case UserPageType.home:
                childWidget = UserHomePage(
                  dueTasks: state.todayTasks,
                  isUserPunched: state.isPunchedIn,
                  isPunchLoading: state.punchStatus.isLoading,
                  isLogLoading: state.logStatus.isLoading,
                  loggedTime: state.loggedTime,
                );
                break;

              case UserPageType.profileScreen:
                childWidget = EditProfileScreen(
                  name: globalActiveUser!.name,
                  email: globalActiveUser!.email,
                  password: globalActiveUser!.password,
                  designation: globalActiveUser!.designation,
                  rolesEnum: globalActiveUser!.role,
                  action: (value) {

                    if (value.isEmpty)  return;

                    context.read<UserCubit>().updateUser(
                      name: value["name"],
                      email: value["email"],
                      pass: value["pass"],
                      designation: value["designation"],
                      role: value["role"],
                      userId: globalActiveUser!.userId,
                    );

                  },
                );
                break;

              case UserPageType.quotationScreen:
                childWidget = QuotationPanel(
                  tasks: state.tasks,
                  status: state.quotationPageStatus,
                  quotation: state.quotations,
                  onRetry: () {
                    context.read<UserCubit>().getAllQuotationsForUser();
                  },
                );
                break;

              default:
                childWidget = Placeholder();
                break;
            }

          } else {

            childWidget = ErrorPage(
              onRetry: () => context.read<UserCubit>()
                ..getAllTasksForUser()
                ..checkPunchedInStatus()
                ..getLoggedTime()
                ..getAttendanceDataForUser(DateTime.now()),
            );

          }

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(_getDrawerTitle(state.currPage.title, l10n)),
                actions: const [ LanguageSelector() ],
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(color: Colors.cyan),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              '${l10n.welcome},',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              globalActiveUser?.name ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // items
                    ...List.generate(menuItems.length, (index) {

                      final item = menuItems[index];

                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: state.currPage == item ? Colors.red : null,
                        ),
                        title: Text(
                          _getDrawerTitle(item.title, l10n),
                          style: TextStyle(
                            color: state.currPage == item ? Colors.red : null,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);

                          final cubit = context.read<UserCubit>();
                          cubit
                              ..clearFilters()
                              ..getLoggedTime()
                              ..changePage(item);

                          if (item == UserPageType.attendanceScreen) {
                            cubit.getAttendanceDataForUser(DateTime.now());
                          }
                        },
                      );
                    }),

                    // logout
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(_getDrawerTitle('logout', l10n)),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<UserCubit>().logout().then((value) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        });
                      },
                    )
                  ],
                ),
              ),
              body: childWidget,
            ),
          );

        },
      ),
    );
  }

  String _getDrawerTitle(String title, AppLocalizations l10n) {

    switch(title) {

      case "Home": return l10n.home;
      case "Tasks": return l10n.tasks;
      case "Quotation": return l10n.quotation;
      case "Attendance": return l10n.attendance;
      case "Profile": return l10n.profile;
      default: return l10n.logout;
    }

  }
}