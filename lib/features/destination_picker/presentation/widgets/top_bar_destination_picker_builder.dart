
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
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700))),
            if (_destinationScreenType == DestinationScreenType.destinationPicker)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
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
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
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
                            colorFilter: AppColor.primaryColor.asFilter(),
                            fit: BoxFit.fill),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context).back,
                            maxLines: 1,
                            softWrap: CommonTextStyle.defaultSoftWrap,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                            textAlign: TextAlign.center,
                            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                              fontSize: 15,
                              color: AppColor.colorTextButton,
                              fontWeight: FontWeight.normal))
                        ]),
                      ),
                    ),
                  ),
                ),
              )
          ]
      ),
    );
  }
}