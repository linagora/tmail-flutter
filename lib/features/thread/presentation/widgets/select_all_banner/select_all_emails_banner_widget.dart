import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SelectAllEmailBannerWidget extends StatelessWidget {
  final int limitEmailsInPage;
  final String? folderName;

  const SelectAllEmailBannerWidget({
    Key? key,
    required this.limitEmailsInPage,
    this.folderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColor.colorBgDesktop,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: AppLocalizations.of(context).all,
            ),
            TextSpan(
              text: ' $limitEmailsInPage ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: AppLocalizations.of(context).mailsOnThisPageAreSelected,
            ),
            TextSpan(
              text: AppLocalizations.of(context).selectAllMailInMailbox(
                limitEmailsInPage,
                folderName ?? AppLocalizations.of(context).folder.toLowerCase(),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {}
            )
          ]
        )
      ),
    );
  }
}
