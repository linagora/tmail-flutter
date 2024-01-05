import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/styles/app_bar_sending_queue_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppBarSendingQueueWidget extends StatelessWidget {

  final VoidCallback? onBackAction;
  final VoidCallback? onOpenMailboxMenu;
  final SelectMode selectMode;
  final List<SendingEmail> listSendingEmailSelected;

  final _imagePaths = Get.find<ImagePaths>();

  AppBarSendingQueueWidget({
    super.key,
    required this.listSendingEmailSelected,
    this.onBackAction,
    this.onOpenMailboxMenu,
    this.selectMode = SelectMode.INACTIVE
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: AppBarSendingQueueWidgetStyle.height,
        color: AppBarSendingQueueWidgetStyle.backgroundColor,
        padding: AppBarSendingQueueWidgetStyle.getPaddingAppBarByResponsiveSize(constraints.maxWidth),
        child: Row(
          children: [
            if (selectMode == SelectMode.INACTIVE)
              TMailButtonWidget.fromIcon(
                icon: _imagePaths.icMailboxMenu,
                backgroundColor: Colors.transparent,
                iconColor: AppBarSendingQueueWidgetStyle.iconColor,
                tooltipMessage: AppLocalizations.of(context).openFolderMenu,
                onTapActionCallback: onOpenMailboxMenu
              )
            else
              Padding(
                padding: AppBarSendingQueueWidgetStyle.leadingPadding,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(AppBarSendingQueueWidgetStyle.leadingRadius)),
                  child: InkWell(
                    onTap: onBackAction,
                    borderRadius: const BorderRadius.all(Radius.circular(AppBarSendingQueueWidgetStyle.leadingRadius)),
                    child: Padding(
                      padding: AppBarSendingQueueWidgetStyle.selectIconPadding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            DirectionUtils.isDirectionRTLByLanguage(context)
                              ? _imagePaths.icCollapseFolder
                              : _imagePaths.icBack,
                            colorFilter: AppBarSendingQueueWidgetStyle.iconColor.asFilter(),
                            fit: BoxFit.fill
                          ),
                          const SizedBox(width: AppBarSendingQueueWidgetStyle.space),
                          Text(
                            listSendingEmailSelected.length.toString(),
                            maxLines: 1,
                            overflow: CommonTextStyle.defaultTextOverFlow,
                            softWrap: CommonTextStyle.defaultSoftWrap,
                            style: AppBarSendingQueueWidgetStyle.countStyle
                          )
                        ]
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(child: Text(
              AppLocalizations.of(context).sendingQueue,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: CommonTextStyle.defaultTextOverFlow,
              softWrap: CommonTextStyle.defaultSoftWrap,
              style: AppBarSendingQueueWidgetStyle.labelStyle
            )),
            const SizedBox(width: AppBarSendingQueueWidgetStyle.trailingSize)
          ],
        ),
      );
    });
  }
}