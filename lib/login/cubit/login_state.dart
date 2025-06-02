import '../../common/enums/page_status.dart';
import '../../common/models/user.dart';

class LoginState {

  final User? activeUser;
  final PageStatus pageStatus;
  final String errorMessage;
  final String permissionType;

  const LoginState({
    this.activeUser,
    this.pageStatus = PageStatus.loading,
    this.errorMessage = "",
    this.permissionType = "",
  });

  LoginState copyWith({
    User? activeUser,
    PageStatus? pageStatus,
    String? errorMessage,
    String? permissionType,
  }) {

    return LoginState(
      activeUser: activeUser ?? this.activeUser,
      pageStatus: pageStatus ?? this.pageStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      permissionType: permissionType ?? this.permissionType,
    );
  }

  LoginState logout() => LoginState(
    activeUser: null,
    pageStatus: pageStatus,
    errorMessage: errorMessage,
    permissionType: permissionType,
  );

}