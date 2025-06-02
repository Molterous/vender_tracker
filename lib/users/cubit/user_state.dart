import 'package:vender_tracker/common/models/quotation.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import '../../common/enums/page_status.dart';
import '../../common/enums/user_page_type.dart';

class UserState {

  final PageStatus pageStatus;
  final PageStatus punchStatus;
  final PageStatus logStatus;
  final PageStatus quotationPageStatus;
  final String errorMessage;
  final List<Tasks> tasks;
  final List<Tasks> todayTasks;
  final List<Quotation> quotations;
  final UserPageType currPage;
  final bool isPunchedIn;
  final Duration loggedTime;

  // attendance page
  final PageStatus attendancePageStatus;
  late final DateTime focusedDay;
  final Map<DateTime, bool> presentDays;

  UserState({
    this.pageStatus = PageStatus.initial,
    this.punchStatus = PageStatus.initial,
    this.logStatus = PageStatus.initial,
    this.attendancePageStatus = PageStatus.initial,
    this.quotationPageStatus = PageStatus.initial,
    this.currPage = UserPageType.home,
    this.errorMessage = "Something went wrong",
    this.tasks = const [],
    this.todayTasks = const [],
    this.quotations = const [],
    this.isPunchedIn = false,
    this.loggedTime = Duration.zero,
    this.presentDays = const {},
    DateTime? day,
  }) : focusedDay = day ?? DateTime.now();

  UserState copyWith({
    PageStatus? pageStatus,
    PageStatus? punchStatus,
    PageStatus? logStatus,
    PageStatus? attendancePageStatus,
    PageStatus? quotationPageStatus,
    String? errorMessage,
    List<Tasks>? tasks,
    List<Tasks>? todayTasks,
    List<Quotation>? quotations,
    UserPageType? currPage,
    bool? isPunchedIn,
    Duration? loggedTime,
    DateTime? focusedDay,
    Map<DateTime, bool>? presentDays,
  }) {
    return UserState(
      pageStatus: pageStatus ?? this.pageStatus,
      punchStatus: punchStatus ?? this.punchStatus,
      logStatus: logStatus ?? this.logStatus,
      attendancePageStatus: attendancePageStatus ?? this.attendancePageStatus,
      quotationPageStatus: quotationPageStatus ?? this.quotationPageStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      tasks: tasks ?? this.tasks,
      todayTasks: todayTasks ?? this.todayTasks,
      quotations: quotations ?? this.quotations,
      currPage: currPage ?? this.currPage,
      isPunchedIn: isPunchedIn ?? this.isPunchedIn,
      loggedTime: loggedTime ?? this.loggedTime,
      day: focusedDay ?? this.focusedDay,
      presentDays: presentDays ?? this.presentDays,
    );
  }

  UserState clearFilter() {
    return UserState(
      pageStatus: pageStatus,
      punchStatus: punchStatus,
      logStatus: logStatus,
      attendancePageStatus: attendancePageStatus,
      quotationPageStatus: quotationPageStatus,
      errorMessage: errorMessage,
      tasks: tasks,
      todayTasks: todayTasks,
      quotations: quotations,
      currPage: currPage,
      isPunchedIn: isPunchedIn,
      loggedTime: loggedTime,
      day: focusedDay,
      presentDays: presentDays,
    );
  }
}