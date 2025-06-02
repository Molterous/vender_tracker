import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/admin/cubit/admin_cubit.dart';
import 'package:vender_tracker/admin/cubit/admin_state.dart';
import 'package:vender_tracker/admin/views/active_users.dart';
import 'package:vender_tracker/admin/views/attendance_page.dart';
import 'package:vender_tracker/admin/views/tracker_page.dart';
import 'package:vender_tracker/admin/widgets/add_user_screen.dart';
import 'package:vender_tracker/common/enums/page_status.dart';
import 'package:vender_tracker/common/ui/lottie_pages.dart';
import 'package:vender_tracker/common/widgets/language_selector.dart';
import 'package:vender_tracker/login/views/login_page.dart';
import '../../common/enums/admin_page_type.dart';
import '../../main.dart';
import '../../quotation/quotation_panel.dart';
import '../widgets/add_new_task_screen.dart';
import '../widgets/edit_profile_screen.dart';
import 'tasks_management_panel.dart';
import 'user_management_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(context) {
    final l10n = AppLocalizations.of(context)!;
    final menuItems = AdminPageType.values.toList();

    return BlocProvider(
      create: (_) => AdminCubit()
        ..getAllUsers()
        ..getAllTasks()
        ..getAllQuotations()
        ..getAllActiveUsers(),
      child: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          late Widget childWidget;

          if (state.pageStatus.isLoading) {
            childWidget = LoadingPage();

          } else if (state.pageStatus.isSuccess) {

            switch (state.currPage) {
              case AdminPageType.taskManagement:
                childWidget = TaskManagementScreen(
                  isLoading: state.taskPageStatus.isLoading,
                  tasks: state.tasks,
                  users: state.users,
                  userMap: state.usersMap,
                  selectedUser: state.taskSelectedUser,
                );
                break;

              case AdminPageType.userManagement:
                childWidget = UserManagementScreen(users: state.users);
                break;

              case AdminPageType.profileScreen:
                childWidget = EditProfileScreen(
                  name: globalActiveUser!.name,
                  email: globalActiveUser!.email,
                  password: globalActiveUser!.password,
                  designation: globalActiveUser!.designation,
                  rolesEnum: globalActiveUser!.role,
                  action: (value) {

                    if (value.isEmpty)  return;

                    context.read<AdminCubit>().updateUser(
                      name: value["name"],
                      email: value["email"],
                      pass: value["pass"],
                      designation: value["designation"],
                      role: value["role"],
                      userId: globalActiveUser!.userId,
                      creatorId: globalActiveUser!.creator,
                      selfUpdate: true,
                    );

                  },
                );
                break;

              case AdminPageType.attendanceScreen:
                childWidget = AttendancePage(state: state);
                break;

              case AdminPageType.activeUsers:
                childWidget = ActiveUsersPage(state: state);
                break;

              case AdminPageType.locationTracker:
                childWidget = TrackerPage(state: state);
                break;

              default:
                childWidget = QuotationPanel(
                  tasks: state.tasks,
                  quotation: state.quotations,
                  status: state.quotationPageStatus,
                  onRetry: () {
                    context.read<AdminCubit>().getAllQuotations();
                  },
                );
                break;
            }
          } else {
            childWidget = ErrorPage(
              onRetry: () => context.read<AdminCubit>()
                ..getAllUsers()
                ..getAllTasks(),
            );
          }

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(_getDrawerTitle(state.currPage.title, l10n)),
                actions: [ LanguageSelector() ],
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(color: Colors.cyan),
                      child: Text(
                        l10n.adminPanel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),

                    // items
                    ...List.generate(menuItems.length, (index) {
                      final item = menuItems[index];
                      final isSelected = state.currPage == item;

                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected ? Colors.red : null,
                        ),
                        title: Text(
                          _getDrawerTitle(item.title, l10n),
                          style: TextStyle(color: isSelected ? Colors.red : null),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<AdminCubit>()
                            ..clearFilters()
                            ..changePage(item);
                        },
                      );
                    }),

                    // logout
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(_getDrawerTitle("Logout", l10n)),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<AdminCubit>().logout().then((value) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        });
                      },
                    )
                  ],
                ),
              ),
              floatingActionButton: _doNotShowFabList.contains(state.currPage)
                  ? null
                  : FloatingActionButton(
                onPressed: () async {
                  if (state.currPage == AdminPageType.attendanceScreen) {
                    final cubit = context.read<AdminCubit>();

                    if (!state.isDatePickerPage) {
                      cubit.getAllUsersAttendanceForDay(state.focusedDay);
                    }
                    cubit.changeAttendancePageType();
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) {
                      switch (state.currPage) {
                        case AdminPageType.taskManagement:
                          return AddTaskScreen(users: state.users);

                        default:
                          return AddUserScreen();
                      }
                    }),
                  ).then((value) {

                    if (value == null)  return;

                    switch (state.currPage) {
                      case AdminPageType.taskManagement:
                        context.read<AdminCubit>().addTask(
                          title     : value["title"  ],
                          desc      : value["desc"   ],
                          due       : value["dueDate"],
                          workerId  : value["userId" ],
                        );
                        break;

                      default:
                        context.read<AdminCubit>().addUser(
                          name: value["name"],
                          email: value["email"],
                          pass: value["pass"],
                          designation: value["designation"],
                          role: value["role"],
                        );
                        break;
                    }

                  });

                },
                backgroundColor: Colors.cyan,
                child: Icon(
                  state.currPage == AdminPageType.attendanceScreen
                      ? Icons.date_range
                      : Icons.add_circle_outline,
                  color: Colors.white,
                ),
              ),
              body: childWidget,
            ),
          );
        },
      ),
    );
  }

  static const _doNotShowFabList = [
    AdminPageType.locationTracker,
    AdminPageType.quotation,
    AdminPageType.activeUsers,
  ];

  String _getDrawerTitle(String title, AppLocalizations l10n) {

    switch(title) {

      case "Users": return l10n.users;
      case "Tasks": return l10n.tasks;
      case "Tracker": return l10n.tracker;
      case "Quotation": return l10n.quotation;
      case "Attendance": return l10n.attendance;
      case "Active Users": return l10n.activeUsers;
      case "Profile": return l10n.profile;
      default: return l10n.logout;
    }

  }

}
