
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_screen_type.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCreateNewMailboxAction = Function();
typedef OnOpenCreateNewMailboxScreenAction = Function();
typedef OnSelectedMailboxDestinationAction = Function();

class TopBarDestinationPickerBuilder extends StatelessWidget {

  final _imagePaths = Get.find<ImagePaths>();

  final MailboxActions? _mailboxAction;
  final VoidCallback? onCloseAction;
  final VoidCallback? onBackToAction;
  final OnCreateNewMailboxAction? onCreateNewMailboxAction;
  final OnOpenCreateNewMailboxScreenAction? onOpenCreateNewMailboxScreenAction;
  final OnSelectedMailboxDestinationAction? onSelectedMailboxDestinationAction;
  final DestinationScreenType _destinationScreenType;
  final MailboxId? mailboxIdDestination;
  final bool isCreateMailboxValidated;

  TopBarDestinationPickerBuilder(
    this._mailboxAction,
    this._destinationScreenType,
    {
      Key? key,
      this.mailboxIdDestination,
      this.isCreateMailboxValidated = false,
      this.onCloseAction,
      this.onBackToAction,
      this.onCreateNewMailboxAction,
      this.onOpenCreateNewMailboxScreenAction,
      this.onSelectedMailboxDestinationAction,
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 52,
      child: Stack(
          children: [
            Center(
              child: Text(
                _destinationScreenType.getTitle(context, _mailboxAction?.getTitle(context) ?? ''),
                maxLines: 1,
                softWrap: CommonTextStyle.defaultSoftWrap,
                overflow: CommonTextStyle.defaultTextOverFlow,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700))),
            if (_destinationScreenType == DestinationScreenType.destinationPicker)
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
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBackToAction,
                      customBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          SvgPicture.asset(
                            _imagePaths.icBack,
                            width: 14,
                            height: 14,
                            color: AppColor.primaryColor,
                            fit: BoxFit.fill),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context).back,
                            maxLines: 1,
                            softWrap: CommonTextStyle.defaultSoftWrap,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColor.colorTextButton,
                              fontWeight: FontWeight.normal))
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_destinationScreenType == DestinationScreenType.destinationPicker &&
                    _mailboxAction != MailboxActions.create)
                  _buildIconCreateButton(context),
                if (_destinationScreenType == DestinationScreenType.destinationPicker)
                  _buildDoneButton(context)
                else
                  _buildSaveButton(context),
                const SizedBox(width: 8)
              ]),
            )
          ]
      ),
    );
  }

  Widget _buildIconCreateButton(BuildContext context) {
    return buildIconWeb(
      iconSize: 24,
      colorSelected: Colors.white,
      splashRadius: 15,
      iconPadding: const EdgeInsets.all(3),
      icon: SvgPicture.asset(
        _imagePaths.icCreateNewFolder,
        color: mailboxIdDestination != null
          ? AppColor.colorTextButton
          : AppColor.colorDisableMailboxCreateButton,
        fit: BoxFit.fill),
      tooltip: AppLocalizations.of(context).create,
      onTap: onOpenCreateNewMailboxScreenAction
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8),
          child: Text(
            AppLocalizations.of(context).done,
            style: TextStyle(
              fontSize: 15,
              color: mailboxIdDestination != null
                ? AppColor.colorTextButton
                : AppColor.colorDisableMailboxCreateButton))),
        onTap: onSelectedMailboxDestinationAction
      )
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8),
          child: Text(
            AppLocalizations.of(context).save,
            style: TextStyle(
              fontSize: 15,
              color: isCreateMailboxValidated
                ? AppColor.colorTextButton
                : AppColor.colorDisableMailboxCreateButton)
          )
        ),
        onTap: isCreateMailboxValidated ? onCreateNewMailboxAction : null
      )
    );
  }
}