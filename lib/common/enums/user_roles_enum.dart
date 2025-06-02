
enum UserRolesEnum {

  user(1),
  admin(0);

  final int id;
  const UserRolesEnum(this.id);
}

UserRolesEnum roleMap(int role) {
  switch(role) {
    case 0: return UserRolesEnum.admin;
    default: return UserRolesEnum.user;
  }
}