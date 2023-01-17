
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_button.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailReceiverBuilder extends StatelessWidget {

  static const double _maxSizeFullDisplayEmailAddressArrowDownButton = 30.0;

  final PresentationEmail emailSelected;
  final SingleEmailController controller;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final double maxWidth;

  const EmailReceiverBuilder({
    Key? key,
    required this.emailSelected,
    required this.controller,
    required this.responsiveUtils,
    required this.imagePaths,
    this.maxWidth = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildEmailAddressOfReceiver(
          context,
          emailSelected,
          controller.isDisplayFullEmailAddress,
          maxWidth
        )),
        if (controller.isDisplayFullEmailAddress)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MaterialTextButton(
              onTap: controller.collapseEmailAddress,
              label: AppLocalizations.of(context).hide,
            )
          )
      ]
    ));
  }

  Widget _buildEmailAddressOfReceiver(
    BuildContext context,
    PresentationEmail presentationEmail,
    bool isDisplayFull,
    double maxWidth
  ) {
    if (!isDisplayFull && presentationEmail.numberOfAllEmailAddress() > 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            color: Colors.white,
            constraints: BoxConstraints(maxWidth: _getMaxWidthEmailAddressDisplayed(context, maxWidth)),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                if (presentationEmail.to.numberEmailAddress() > 0)
                  _buildEmailAddressByPrefix(
                    context,
                    presentationEmail,
                    PrefixEmailAddress.to,
                    isDisplayFull
                  ),
                if (presentationEmail.cc.numberEmailAddress() > 0)
                  _buildEmailAddressByPrefix(
                    context,
                    presentationEmail,
                    PrefixEmailAddress.cc,
                    isDisplayFull
                  ),
                if (presentationEmail.bcc.numberEmailAddress() > 0)
                  _buildEmailAddressByPrefix(
                    context,
                    presentationEmail,
                    PrefixEmailAddress.bcc,
                    isDisplayFull
                  ),
              ]
            ),
          ),
          _buildArrowDownButton()
        ]
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (presentationEmail.to.numberEmailAddress() > 0)
            _buildEmailAddressByPrefix(
              context,
              presentationEmail,
              PrefixEmailAddress.to,
              isDisplayFull
            ),
          if (presentationEmail.cc.numberEmailAddress() > 0)
            _buildEmailAddressByPrefix(
              context,
              presentationEmail,
              PrefixEmailAddress.cc,
              isDisplayFull
            ),
          if (presentationEmail.bcc.numberEmailAddress() > 0)
            _buildEmailAddressByPrefix(
              context,
              presentationEmail,
              PrefixEmailAddress.bcc,
              isDisplayFull
            ),
        ],
      );
    }
  }

  Widget _buildEmailAddressByPrefix(
    BuildContext context,
    PresentationEmail presentationEmail,
    PrefixEmailAddress prefixEmailAddress,
    bool isDisplayFull
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '${prefixEmailAddress.asName(context)}:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColor.colorEmailAddressFull
              )
            ),
          ),
          if (!isDisplayFull && presentationEmail.numberOfAllEmailAddress() > 1)
            _buildListEmailAddressWidget(
              context,
              prefixEmailAddress.listEmailAddress(presentationEmail),
              isDisplayFull
            )
          else
            Expanded(child: _buildListEmailAddressWidget(
              context,
              prefixEmailAddress.listEmailAddress(presentationEmail),
              isDisplayFull
            ))
        ]
      ),
    );
  }

  Widget _buildListEmailAddressWidget(
    BuildContext context,
    List<EmailAddress> listEmailAddress,
    bool isDisplayFull
  ) {
    final lastEmailAddress = listEmailAddress.last;
    final emailAddressWidgets = listEmailAddress.map((emailAddress) {
      return MaterialTextButton(
        label: lastEmailAddress == emailAddress
          ? emailAddress.asString()
          : '${emailAddress.asString()},',
        onTap: () => controller.openEmailAddressDialog(context, emailAddress),
        borderRadius: 8,
        labelColor: Colors.black,
        labelSize: 16,
        softWrap: CommonTextStyle.defaultSoftWrap,
        overflow: CommonTextStyle.defaultTextOverFlow,
      );
    }).toList();

    if (isDisplayFull) {
      return Wrap(children: emailAddressWidgets);
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          crossAxisAlignment:CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: emailAddressWidgets
        ),
      );
    }
  }

  double _getMaxWidthEmailAddressDisplayed(BuildContext context, double maxWidth) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return maxWidth - _maxSizeFullDisplayEmailAddressArrowDownButton;
    } else if (responsiveUtils.isWebDesktop(context)) {
      return maxWidth / 2;
    } else {
      return maxWidth * 3/4;
    }
  }

  Widget _buildArrowDownButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.expandEmailAddress,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(5),
          color: Colors.transparent,
          constraints: const BoxConstraints(
            maxHeight: _maxSizeFullDisplayEmailAddressArrowDownButton,
            maxWidth: _maxSizeFullDisplayEmailAddressArrowDownButton
          ),
          child: SvgPicture.asset(
            imagePaths.icChevronDown,
            width: 16,
            height: 16,
            fit: BoxFit.fill
          ),
        ),
      ),
    );
  }
}