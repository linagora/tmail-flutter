import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NumberOfRecipientWidget extends StatelessWidget {
  final int numberOfRecipient;

  const NumberOfRecipientWidget({super.key, required this.numberOfRecipient});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 36),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              appLocalizations.forwardTo,
              style: ThemeUtils.textStyleInter600().copyWith(
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0.25,
                color: AppColor.gray424244,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.gray49454F.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            margin: const EdgeInsetsDirectional.only(start: 16),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: Text(
              '$numberOfRecipient ${appLocalizations.recipient.toLowerCase()}',
              style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
