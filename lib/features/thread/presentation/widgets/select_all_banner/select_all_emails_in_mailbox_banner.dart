import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/select_all_banner/message_select_all_email_in_mailbox_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/select_all_banner/message_select_email_in_page_widget.dart';

class SelectAllEmailInMailboxBanner extends StatefulWidget {
  final int limitEmailsInPage;
  final int totalEmails;
  final String folderName;
  final VoidCallback onSelectAllEmailAction;
  final VoidCallback onClearSelection;

  const SelectAllEmailInMailboxBanner({
    Key? key,
    required this.limitEmailsInPage,
    required this.totalEmails,
    required this.folderName,
    required this.onSelectAllEmailAction,
    required this.onClearSelection,
  }) : super(key: key);

  @override
  State<SelectAllEmailInMailboxBanner> createState() => _SelectAllEmailInMailboxBannerState();
}

class _SelectAllEmailInMailboxBannerState extends State<SelectAllEmailInMailboxBanner> {

  bool _isSelectAllEmailsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColor.colorBgDesktop,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      alignment: AlignmentDirectional.centerStart,
      child: _isSelectAllEmailsEnabled
        ? MessageSelectAllEmailInMailboxWidget(
            totalEmails: widget.totalEmails,
            folderName: widget.folderName,
            onClearSelection: widget.onClearSelection,
          )
        : MessageSelectEmailInPageWidget(
            limitEmailsInPage: widget.limitEmailsInPage,
            totalEmails: widget.totalEmails,
            folderName: widget.folderName,
            onSelectAllEmailAction: () {
              widget.onSelectAllEmailAction();
              setState(() => _isSelectAllEmailsEnabled = true);
            },
          )
    );
  }
}
