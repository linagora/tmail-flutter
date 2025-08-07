import 'dart:math';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectRecipientCallbackAction = Function(RecipientForward recipientForward);
typedef OnDeleteRecipientCallbackAction = Function(RecipientForward recipientForward);

class EmailForwardItemWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final RecipientForward recipientForward;
  final SelectMode selectionMode;
  final String internalDomain;
  final double maxWidth;
  final OnSelectRecipientCallbackAction? onSelectRecipientCallback;
  final OnDeleteRecipientCallbackAction? onDeleteRecipientCallback;

  const EmailForwardItemWidget({
    Key? key,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.recipientForward,
    required this.internalDomain,
    required this.maxWidth,
    this.selectionMode = SelectMode.INACTIVE,
    this.onSelectRecipientCallback,
    this.onDeleteRecipientCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isScreenWithShortestSide = responsiveUtils
        .isScreenWithShortestSide(context);

    final isSameDomain = EmailUtils.isSameDomain(
      emailAddress: recipientForward.emailAddress.emailAddress,
      internalDomain: internalDomain,
    );

    final bodyWidget = Padding(
      padding: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onLongPress: PlatformInfo.isMobile
          ? () => onSelectRecipientCallback?.call(recipientForward)
          : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          width: isScreenWithShortestSide
              ? double.infinity
              : min(maxWidth, 597),
          height: 72,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: _buildAvatarIcon(imagePaths),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  recipientForward.emailAddress.asString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ThemeUtils.textStyleBodyBody2(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TMailButtonWidget.fromIcon(
                                icon: isSameDomain
                                  ? imagePaths.icCheck
                                  : imagePaths.icInfoCircleOutline,
                                iconColor: AppColor.primaryLinShare,
                                iconSize: 20,
                                margin: const EdgeInsetsDirectional.only(
                                  start: 4,
                                ),
                                backgroundColor: Colors.transparent,
                                padding: const EdgeInsets.all(2),
                                tooltipMessage: isSameDomain
                                    ? null
                                    : AppLocalizations.of(context).externalDomain,
                              )
                            ],
                          ),
                          if (recipientForward.emailAddress.displayName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                recipientForward.emailAddress.email ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ThemeUtils.textStyleBodyBody2(
                                  color: AppColor.gray424244.withValues(
                                    alpha: 0.64,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (selectionMode == SelectMode.INACTIVE)
                TMailButtonWidget.fromIcon(
                  icon: imagePaths.icDeleteComposer,
                  iconSize: 20,
                  iconColor: AppColor.steelGrayA540,
                  backgroundColor: Colors.transparent,
                  margin: EdgeInsetsDirectional.only(
                    start: 12,
                    end: isScreenWithShortestSide ? 0 : 12,
                  ),
                  onTapActionCallback: () =>
                      onDeleteRecipientCallback?.call(recipientForward),
                ),
            ],
          ),
        ),
      ),
    );

    if (isScreenWithShortestSide) {
      return bodyWidget;
    } else {
      return Row(
        children: [
          bodyWidget,
          const Spacer(),
        ],
      );
    }
  }

  Color _getBackgroundColor() {
    if (recipientForward.selectMode == SelectMode.ACTIVE) {
      return AppColor.colorItemRecipientSelected;
    } else {
      return AppColor.lightGrayF9FAFB;
    }
  }

  Widget _buildAvatarIcon(ImagePaths imagePaths) {
    if (recipientForward.selectMode == SelectMode.ACTIVE) {
      return InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onSelectRecipientCallback?.call(recipientForward),
        child: Container(
          width: 32,
          height: 32,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            imagePaths.icSelectedRecipient,
            width: 32,
            height: 32,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return (AvatarBuilder()
            ..text(
                recipientForward.emailAddress.asString().firstLetterToUpperCase)
            ..size(32)
            ..addTextStyle(ThemeUtils.textStyleM3TitleMedium)
            ..avatarColor(recipientForward.emailAddress.avatarColors)
            ..addOnTapActionClick(
                () => onSelectRecipientCallback?.call(recipientForward)))
          .build();
    }
  }
}
