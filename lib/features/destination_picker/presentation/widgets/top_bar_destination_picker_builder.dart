
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TopBarDestinationPickerBuilder extends StatelessWidget {

  final MailboxActions? _mailboxAction;
  final VoidCallback? onCloseAction;

  const TopBarDestinationPickerBuilder(
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
      color: Colors.white,
      height: 52,
      child: Stack(
          children: [
            Center(
              child: Text(
                _mailboxAction?.getTitle(context) ?? '',
                maxLines: 1,
                softWrap: CommonTextStyle.defaultSoftWrap,
                overflow: CommonTextStyle.defaultTextOverFlow,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700))),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: buildIconWeb(
                    iconSize: 24,
                    colorSelected: Colors.white,
                    splashRadius: 15,
                    iconPadding: const EdgeInsets.all(3),
                    icon: SvgPicture.asset(_imagePaths.icComposerClose, fit: BoxFit.fill),
                    tooltip: AppLocalizations.of(context).close,
                    onTap: () => onCloseAction?.call()),
              ),
            ),
          ]
      ),
    );
  }
}