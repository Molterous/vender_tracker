import 'package:flutter/material.dart';
import 'package:vender_tracker/common/enums/user_roles_enum.dart';
import 'package:vender_tracker/common/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserListView extends StatelessWidget {

  final List<User> users;
  final void Function(User user) onEdit;
  final void Function(User user) onDelete;

  const UserListView({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          color: user.role == UserRolesEnum.user
              ? Colors.red
              : Colors.lightGreen,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            margin: EdgeInsets.only(left: 5),
            child: ListTile(
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.email}: ${user.email}'),
                  Text('${l10n.password}: ${user.password}'),
                  Text('${l10n.roleID}: ${user.role.name}'),
                  Text('${l10n.id}: ${user.userId}'),
                ],
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit(user),
                    tooltip: l10n.edit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete(user),
                    tooltip: l10n.delete,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
