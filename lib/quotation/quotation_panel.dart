import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/admin/cubit/admin_cubit.dart';
import 'package:vender_tracker/common/enums/page_status.dart';
import 'package:vender_tracker/common/enums/user_roles_enum.dart';
import 'package:vender_tracker/common/models/quotation.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import 'package:vender_tracker/common/ui/lottie_pages.dart';
import 'package:vender_tracker/main.dart';
import 'package:vender_tracker/quotation/new_quotation_page.dart';
import 'package:vender_tracker/quotation/quotation_list_view.dart';
import 'package:vender_tracker/users/cubit/user_cubit.dart';

class QuotationPanel extends StatelessWidget {
  final List<Tasks> tasks;
  final List<Quotation> quotation;
  final PageStatus status;
  final VoidCallback? onRetry;

  const QuotationPanel({
    super.key,
    this.tasks = const [],
    this.quotation = const [],
    this.status = PageStatus.initial,
    this.onRetry,
  });

  @override
  Widget build(context) {

    if (status.isLoading) return const LoadingPage();

    if (status.isFailure || status.isNetworkError) {
      return ErrorPage(onRetry: onRetry);
    }

    final isUser = globalActiveUser!.role == UserRolesEnum.user;

    return Scaffold(
      floatingActionButton: isUser
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewQuotationScreen(tasks: tasks),
                    )).then((value) {
                  if (value != null) {
                    context.read<AdminCubit>().addQuotation(value);
                  }
                });
              },
              backgroundColor: Colors.cyan,
              child: const Icon(Icons.add_circle_outline, color: Colors.white),
            ),
      body: QuotationListView(
        quotations: quotation,
        onTap: (quotation) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewQuotationScreen(tasks: tasks, quotation: quotation),
              )).then((value) {
            if (value != null) {
              isUser
                  ? context.read<UserCubit>().updateQuotation(value)
                  : context.read<AdminCubit>().updateQuotation(value);
            }
          });
        },
        onDelete: (quotation) {
          context.read<AdminCubit>().deleteQuotation(quotation);
        },
      ),
    );
  }
}
