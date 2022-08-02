
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TopBarDestinationPickerWebBuilder extends StatelessWidget {

  final MailboxActions? _mailboxAction;
  final VoidCallback? onCloseAction;

  const TopBarDestinationPickerWebBuilder(
      this._mailboxAction,
      {
        Key? key,
        this.onCloseAction,
      }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _imagePaths = Get.find<ImagePaths>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: Colors.white,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 40),
            Expanded(
              child: Text(
                _mailboxAction?.getTitle(context) ?? '',
                maxLines: 1,
                overflow: CommonTextStyle.defaultTextOverFlow,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700))),
            buildIconWeb(
                iconSize: 32,
                colorSelected: Colors.white,
                splashRadius: 20,
                iconPadding: const EdgeInsets.all(5),
                icon: SvgPicture.asset(_imagePaths.icCloseMailbox, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).close,
                onTap: () => onCloseAction?.call()),
          ]
      ),
    );
  }
}