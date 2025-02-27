import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/select_all_banner/message_select_all_email_in_search_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/select_all_banner/message_select_email_on_page_in_search_widget.dart';

class SelectAllEmailInSearchBanner extends StatefulWidget {
  final int limitEmailsInPage;
  final VoidCallback onSelectAllEmailAction;
  final VoidCallback onClearSelection;

  const SelectAllEmailInSearchBanner({
    Key? key,
    required this.limitEmailsInPage,
    required this.onSelectAllEmailAction,
    required this.onClearSelection,
  }) : super(key: key);

  @override
  State<SelectAllEmailInSearchBanner> createState() => _SelectAllEmailInSearchBannerState();
}

class _SelectAllEmailInSearchBannerState extends State<SelectAllEmailInSearchBanner> {

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
      child: _isSelectAllEmailsEnabled
        ? MessageSelectAllEmailInSearchWidget(onClearSelection: widget.onClearSelection)
        : MessageSelectEmailOnPageInSearchWidget(
            limitEmailsInPage: widget.limitEmailsInPage,
            onSelectAllEmailAction: () {
              widget.onSelectAllEmailAction();
              setState(() => _isSelectAllEmailsEnabled = true);
            })
    );
  }
}
