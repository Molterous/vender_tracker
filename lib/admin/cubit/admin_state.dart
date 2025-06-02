import 'package:vender_tracker/common/models/quotation.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import '../../common/enums/admin_page_type.dart';
import '../../common/enums/page_status.dart';
import '../../common/models/user.dart';

class AdminState {

  final PageStatus pageStatus;
  final PageStatus taskPageStatus;
  final PageStatus quotationPageStatus;
  final String errorMessage;
  final List<User> users;
  final Map<String, User> usersMap = Map.of({});
  final List<Tasks> tasks;
  final User? taskSelectedUser;
  final AdminPageType currPage;
  final List<Quotation> quotations;

  // attendance page
  final PageStatus attendancePageStatus;
  final PageStatus activeUserPageStatus;
  late final DateTime focusedDay;
  final Map<DateTime, bool> presentDays;
  final Map<String, bool> presentUsers;
  final List<String> activeUsers;
  final User? attendanceSelectedUser;
  final bool isDatePickerPage;

  // location page
  final PageStatus locPageStatus;
  late final DateTime locFocusedDay;
  final Map<String, Map<String, dynamic>> locData;
  final User? locSelectedUser;

  AdminState({
    this.pageStatus = PageStatus.initial,
    this.taskPageStatus = PageStatus.initial,
    this.attendancePageStatus = PageStatus.initial,
    this.activeUserPageStatus = PageStatus.initial,
    this.quotationPageStatus = PageStatus.initial,
    this.locPageStatus = PageStatus.initial,
    this.currPage = AdminPageType.userManagement,
    this.errorMessage = "Something went wrong",
    this.users = const [],
    this.tasks = const [],
    this.quotations = const [],
    this.activeUsers = const [],
    this.taskSelectedUser,
    this.attendanceSelectedUser,
    this.locSelectedUser,
    this.presentDays = const {},
    this.presentUsers = const {},
    this.locData = const {},
    this.isDatePickerPage = false,
    DateTime? day,
  }) {
    focusedDay = day ?? DateTime.now();
    locFocusedDay = day ?? DateTime.now();
    _generateMap();
  }

  void _generateMap() async {
    for (var element in users) {
      usersMap[element.userId] = element;
    }
  }

  AdminState copyWith({
    PageStatus? pageStatus,
    PageStatus? attendancePageStatus,
    PageStatus? activeUserPageStatus,
    PageStatus? locPageStatus,
    PageStatus? taskPageStatus,
    PageStatus? quotationPageStatus,
    String? errorMessage,
    List<User>? users,
    List<Tasks>? tasks,
    List<Quotation>? quotations,
    AdminPageType? currPage,
    User? taskSelectedUser,
    User? attendanceSelectedUser,
    User? locSelectedUser,
    Map<DateTime, bool>? presentDays,
    Map<String, bool>? presentUsers,
    List<String>? activeUsers,
    Map<String, Map<String, dynamic>>? locData,
    DateTime? focusedDay,
    bool? isDatePickerPage,
  }) {
    return AdminState(
      pageStatus: pageStatus ?? this.pageStatus,
      attendancePageStatus: attendancePageStatus ?? this.attendancePageStatus,
      activeUserPageStatus: activeUserPageStatus ?? this.activeUserPageStatus,
      locPageStatus: locPageStatus ?? this.locPageStatus,
      taskPageStatus: taskPageStatus ?? this.taskPageStatus,
      quotationPageStatus: quotationPageStatus ?? this.quotationPageStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      users: users ?? this.users,
      tasks: tasks ?? this.tasks,
      quotations: quotations ?? this.quotations,
      currPage: currPage ?? this.currPage,
      taskSelectedUser: taskSelectedUser ?? this.taskSelectedUser,
      attendanceSelectedUser: attendanceSelectedUser ?? this.attendanceSelectedUser,
      locSelectedUser: locSelectedUser ?? this.locSelectedUser,
      presentDays: presentDays ?? this.presentDays,
      presentUsers: presentUsers ?? this.presentUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      day: focusedDay ?? this.focusedDay,
      locData: locData ?? this.locData,
      isDatePickerPage: isDatePickerPage ?? this.isDatePickerPage,
    );
  }

  AdminState clearFilter() {
    return AdminState(
      pageStatus: pageStatus,
      attendancePageStatus: attendancePageStatus,
      locPageStatus: locPageStatus,
      taskPageStatus: taskPageStatus,
      quotationPageStatus: quotationPageStatus,
      errorMessage: errorMessage,
      users: users,
      tasks: tasks,
      quotations: quotations,
      currPage: currPage,
      taskSelectedUser: null,
      attendanceSelectedUser: null,
      locSelectedUser: null,
      presentDays: const {},
      presentUsers: const {},
      activeUsers: activeUsers,
      day: null,
      isDatePickerPage: false,
    );
  }
}