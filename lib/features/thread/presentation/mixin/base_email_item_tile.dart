
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/text/rich_text_builder.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnPressEmailActionClick = void Function(EmailActionType, PresentationEmail);
typedef OnMoreActionClick = void Function(PresentationEmail, RelativeRect?);

mixin BaseEmailItemTile {

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  Widget buildMailboxContain(
    bool isSearchEmailRunning,
    PresentationEmail email
  ) {
    if (hasMailboxLabel(isSearchEmailRunning, email)) {
      return Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3),
          constraints: const BoxConstraints(maxWidth: 100),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.backgroundCounterMailboxColor),
          child: TextOverflowBuilder(
            email.mailboxName,
            style: const TextStyle(
                fontSize: 10,
                color: AppColor.mailboxTextColor,
                fontWeight: FontWeight.bold),
          )
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isSearchEnabled(bool isSearchEmailRunning, SearchQuery? query) {
    return isSearchEmailRunning && query?.value.isNotEmpty == true;
  }

  FontWeight buildFontForReadEmail(PresentationEmail email) =>
      !email.hasRead ? FontWeight.w600 : FontWeight.normal;

  Color buildTextColorForReadEmail(PresentationEmail email) =>
      email.hasRead ? AppColor.colorContentEmail : AppColor.colorNameEmail;

  bool hasMailboxLabel(bool isSearchEmailRunning, PresentationEmail email) {
    return isSearchEmailRunning && email.mailboxName.isNotEmpty;
  }

  String informationSender(PresentationEmail email, PresentationMailbox? mailbox) {
    if (mailbox?.isSent == true || mailbox?.isDrafts == true || mailbox?.isOutbox == true) {
      return email.recipientsName();
    } else {
      return email.getSenderName();
    }
  }

  Widget buildInformationSender(
      PresentationEmail email,
      PresentationMailbox? mailbox,
      bool isSearchEmailRunning,
      SearchQuery? query
  ) {
    if (isSearchEnabled(isSearchEmailRunning, query)) {
      return RichTextBuilder(
          informationSender(email, mailbox).overflow,
          query?.value ?? '',
          TextStyle(
              fontSize: 15,
              color: buildTextColorForReadEmail(email),
              fontWeight: buildFontForReadEmail(email)),
          TextStyle(
              fontSize: 15,
              color: buildTextColorForReadEmail(email),
              backgroundColor: AppColor.bgWordSearch,
              fontWeight: buildFontForReadEmail(email))
      ).build();
    } else {
      return TextOverflowBuilder(
        informationSender(email, mailbox),
        style: TextStyle(
          fontSize: 15,
          overflow: CommonTextStyle.defaultTextOverFlow,
          color: buildTextColorForReadEmail(email),
          fontWeight: buildFontForReadEmail(email))
      );
    }
  }

  Widget buildEmailTitle(
    PresentationEmail email,
    bool isSearchEmailRunning,
    SearchQuery? query
  ) {
    if (isSearchEnabled(isSearchEmailRunning, query)) {
      return RichTextBuilder(
          email.getEmailTitle().overflow,
          query?.value ?? '',
          TextStyle(
              fontSize: 13,
              color: buildTextColorForReadEmail(email),
              fontWeight: buildFontForReadEmail(email)),
          TextStyle(
              fontSize: 13,
              backgroundColor: AppColor.bgWordSearch,
              color: buildTextColorForReadEmail(email),
              fontWeight: buildFontForReadEmail(email))
      ).build();
    } else {
      return TextOverflowBuilder(
        email.getEmailTitle(),
        style: TextStyle(
          fontSize: 13,
          color: buildTextColorForReadEmail(email),
          fontWeight: buildFontForReadEmail(email))
      );
    }
  }

  Widget buildEmailPartialContent(
    PresentationEmail email,
    bool isSearchEmailRunning,
    SearchQuery? query
  ) {
    if (isSearchEnabled(isSearchEmailRunning, query)) {
      return RichTextBuilder(
          email.getPartialContent().overflow,
          query?.value ?? '',
          const TextStyle(
              fontSize: 13,
              color: AppColor.colorContentEmail,
              fontWeight: FontWeight.normal),
          const TextStyle(
              fontSize: 13,
              color: AppColor.colorContentEmail,
              backgroundColor: AppColor.bgWordSearch)
      ).build();
    } else {
      return TextOverflowBuilder(
        email.getPartialContent(),
        style: const TextStyle(
          fontSize: 13,
          color: AppColor.colorContentEmail,
          fontWeight: FontWeight.normal)
      );
    }
  }

  Widget buildDateTime(BuildContext context, PresentationEmail email) {
    return Text(
        email.getReceivedAt(Localizations.localeOf(context).toLanguageTag()),
        maxLines: 1,
        softWrap: CommonTextStyle.defaultSoftWrap,
        overflow: CommonTextStyle.defaultTextOverFlow,
        style:  TextStyle(
            fontSize: 13,
            color: buildTextColorForReadEmail(email),
            fontWeight: buildFontForReadEmail(email))
    );
  }

  Widget buildIconChevron() {
    return SvgPicture.asset(
        imagePaths.icChevron,
        width: 16,
        height: 16,
        fit: BoxFit.fill);
  }

  Widget buildIconAttachment() {
    return SvgPicture.asset(
        imagePaths.icAttachment,
        width: 16,
        height: 16,
        fit: BoxFit.fill);
  }

  Widget buildIconStar() {
    return SvgPicture.asset(
        imagePaths.icStar,
        width: 15,
        height: 15,
        fit: BoxFit.fill);
  }

  Widget buildIconAvatarText(PresentationEmail email, {
    double? iconSize,
    TextStyle? textStyle
  }) {
    return Container(
        width: iconSize ?? 56,
        height: iconSize ?? 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((iconSize ?? 56) * 0.5),
            border: Border.all(color: Colors.transparent),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 1.0],
                colors: email.avatarColors),
            color: AppColor.avatarColor
        ),
        child: Text(
            email.getAvatarText(),
            style: textStyle ?? const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500)
        )
    );
  }

  Widget buildIconAvatarSelection(
      BuildContext context,
      PresentationEmail email,
      {
        double? iconSize,
        TextStyle? textStyle
      }
  ) {
    if (PlatformInfo.isWeb) {
      return Container(
        color: Colors.transparent,
        width: iconSize ?? 48,
        height: iconSize ?? 48,
        alignment: Alignment.center,
        padding: responsiveUtils.isDesktop(context)
            ? const EdgeInsets.symmetric(horizontal: 4)
            : const EdgeInsets.all(12),
        child: SvgPicture.asset(
            email.selectMode == SelectMode.ACTIVE
                ? imagePaths.icSelected
                : imagePaths.icUnSelected,
            fit: BoxFit.fill),
      );
    } else {
      return Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          child: SvgPicture.asset(
              email.selectMode == SelectMode.ACTIVE
                  ? imagePaths.icSelected
                  : imagePaths.icUnSelected,
              width: 24, height: 24));
    }
  }

  Widget buildIconAnsweredOrForwarded({
    required PresentationEmail presentationEmail,
    double? width,
    double? height
  }) {
    if (presentationEmail.isAnsweredAndForwarded) {
      return _iconAnsweredOrForwardedWidget(
        iconPath:  imagePaths.icReplyAndForward,
        width: width,
        height: height
      );
    } else if (presentationEmail.isAnswered) {
      return _iconAnsweredOrForwardedWidget(
        iconPath: imagePaths.icReply,
        width: width,
        height: height
      );
    } else if (presentationEmail.isForwarded) {
      return _iconAnsweredOrForwardedWidget(
        iconPath: imagePaths.icForwarded,
        width: width,
        height: height
      );
    } else {
      return const SizedBox(width: 16, height: 16);
    }
  }

  Widget _iconAnsweredOrForwardedWidget({
    required String iconPath,
    double? width,
    double? height
  }) {
    return SvgPicture.asset(
      iconPath,
      width: width ?? 20,
      height: height ?? 20,
      colorFilter: AppColor.colorAttachmentIcon.asFilter(),
      fit: BoxFit.fill);
  }

  String? messageToolTipForAnsweredOrForwarded(BuildContext context, PresentationEmail presentationEmail) {
    if (presentationEmail.isAnsweredAndForwarded) {
      return AppLocalizations.of(context).repliedAndForwardedMessage;
    } else if (presentationEmail.isAnswered) {
      return AppLocalizations.of(context).repliedMessage;
    } else if (presentationEmail.isForwarded){
      return AppLocalizations.of(context).forwardedMessage;
    } else {
      return null;
    }
  }
}