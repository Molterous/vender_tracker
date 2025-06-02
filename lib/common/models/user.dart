
import 'package:vender_tracker/common/enums/user_roles_enum.dart';

class User {

  final String userId, name, email, password, designation, creator, fcm;
  final UserRolesEnum role;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.designation,
    required this.creator,
    this.role = UserRolesEnum.user,
    this.fcm = '',
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
    userId:       map["id"],
    name:         map["name"],
    email:        map["email"],
    password:     map["password"],
    designation:  map["designation"],
    creator:      map["creator"],
    fcm:          map["fcm"] ?? "",
    role:         roleMap(int.parse(map["role"])),
  );

  User copyWith({
    String? name,
    String? email,
    String? password,
  }) => User(
    userId:       userId,
    name:         name ?? this.name,
    email:        email ?? this.email,
    password:     password ?? this.password,
    designation:  designation,
    creator:      creator,
    fcm:          fcm,
    role:         role,
  );

  static User dummyUser() => User(
    userId: "",
    name: "",
    email: "",
    password: "",
    designation: "",
    creator: "",
    fcm: '',
    role: UserRolesEnum.user,
  );
}