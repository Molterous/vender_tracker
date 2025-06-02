import 'package:flutter/material.dart';
import 'package:vender_tracker/common/enums/user_roles_enum.dart';
import 'package:vender_tracker/common/models/quotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vender_tracker/common/ui/lottie_pages.dart';
import 'package:vender_tracker/main.dart';

class QuotationListView extends StatelessWidget {
  final List<Quotation> quotations;
  final void Function(Quotation quotation)? onDelete;
  final void Function(Quotation quotation) onTap;

  const QuotationListView({
    super.key,
    required this.quotations,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    if (quotations.isEmpty) return const NoDataFoundPage();


    final l10n = AppLocalizations.of(context)!;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 25),
      itemCount: quotations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {

        final quotation = quotations[index];
        final time = DateTime.parse(quotation.modifiedDate)
            .toLocal()
            .toString()
            .split(' ')[0];

        return InkWell(
          onTap: () => onTap.call(quotation),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: ListTile(
                title: Text(quotation.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l10n.info}: ${quotation.info}', maxLines: 5),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.lastModifiedOn}: $time',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: globalActiveUser!.role == UserRolesEnum.user
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete?.call(quotation),
                        tooltip: l10n.delete,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
