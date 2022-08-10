
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppBarDestinationPickerBuilder extends StatelessWidget {

  final MailboxActions? _mailboxAction;
  final VoidCallback? onCloseAction;

  const AppBarDestinationPickerBuilder(
    this._mailboxAction,
    {
      Key? key,
      this.onCloseAction
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    return Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white),
        height: 52,
        child: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.zero),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBackButton(context, imagePaths),
                  Expanded(child: Text(
                      _mailboxAction?.getTitle(context) ?? '',
                      maxLines: 1,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          color: AppColor.colorNameEmail,
                          fontWeight: FontWeight.w700))),
                   _buildCancelButton(context),
                ]
            )
        )
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    if (_mailboxAction == MailboxActions.moveEmail ||
        _mailboxAction == MailboxActions.move ||
        _mailboxAction == MailboxActions.selectForRuleAction ||
        _mailboxAction == MailboxActions.select) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            child: TextButton(
                child: Text(
                    AppLocalizations.of(context).cancel,
                    style: const TextStyle(
                        fontSize: 17,
                        color: AppColor.colorTextButton)),
                onPressed: () => onCloseAction?.call()
            )
        ));
    } else {
      return const SizedBox(width: 40, height: 40);
    }
  }

  Widget _buildBackButton(BuildContext context, ImagePaths imagePaths) {
    if (_mailboxAction == MailboxActions.create) {
      return buildIconWeb(
          icon: SvgPicture.asset(
              imagePaths.icBack,
              color: AppColor.colorTextButton,
              fit: BoxFit.fill),
          onTap: () => onCloseAction?.call());
    } else {
      return const SizedBox(width: 70, height: 40);
    }
  }
}