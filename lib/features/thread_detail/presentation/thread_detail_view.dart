import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/non_scroll_email_view.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_thread_detail_email_action_type.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_collapsed_email.dart';

class ThreadDetailView extends StatefulWidget {
  const ThreadDetailView({super.key});

  @override
  State<ThreadDetailView> createState() => _ThreadDetailViewState();
}

class _ThreadDetailViewState extends State<ThreadDetailView> {
  final controller = Get.find<ThreadDetailController>();

  @override
  void dispose() {
    Get.delete<ThreadDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final children = controller.emailIdsPresentation.entries.map((entry) {
        final emailId = entry.key;
        final presentationEmail = entry.value;
        if (presentationEmail == null) return const SizedBox.shrink();

        if (controller.emailIdsStatus[emailId] == EmailInThreadStatus.collapsed) {
          return ThreadDetailCollapsedEmail(
            presentationEmail: presentationEmail,
            mailboxContain: presentationEmail.mailboxContain,
            emailActionClick: controller.handleThreadDetailEmailActionType,
          );
        }

        return NonScrollEmailView(presentationEmail: presentationEmail);
      }).toList();

      return Column(children: children);
    });
  }
}