
import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/prefix_recipient_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EmailReceiverWidget extends StatefulWidget {

  final PresentationEmail emailSelected;
  final double maxWidth;
  final double? maxHeight;
  final OnOpenEmailAddressDetailAction? openEmailAddressDetailAction;

  const EmailReceiverWidget({
    Key? key,
    required this.emailSelected,
    this.maxWidth = 200,
    this.maxHeight,
    this.openEmailAddressDetailAction,
  }) : super(key: key);

  @override
  State<EmailReceiverWidget> createState() => _EmailReceiverWidgetState();
}

class _EmailReceiverWidgetState extends State<EmailReceiverWidget> {

  static const double _maxSizeFullDisplayEmailAddressArrowDownButton = 50.0;
  static const double _offsetTop = 100.0;

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  bool _isDisplayAll = false;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (_isDisplayAll) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxHeight: _maxHeight),
                child: ListView(
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    if (widget.emailSelected.to.numberEmailAddress() > 0)
                      _buildRecipientsWidgetToDisplayFull(
                        context: context,
                        prefixEmailAddress: PrefixEmailAddress.to,
                        listEmailAddress: PrefixEmailAddress.to.listEmailAddress(widget.emailSelected)
                      ),
                    if (widget.emailSelected.cc.numberEmailAddress() > 0)
                      _buildRecipientsWidgetToDisplayFull(
                        context: context,
                        prefixEmailAddress: PrefixEmailAddress.cc,
                        listEmailAddress: PrefixEmailAddress.cc.listEmailAddress(widget.emailSelected)
                      ),
                    if (widget.emailSelected.bcc.numberEmailAddress() > 0)
                      _buildRecipientsWidgetToDisplayFull(
                        context: context,
                        prefixEmailAddress: PrefixEmailAddress.bcc,
                        listEmailAddress: PrefixEmailAddress.bcc.listEmailAddress(widget.emailSelected)
                      ),
                  ],
                ),
              )
            ),
            TMailButtonWidget.fromText(
              text: AppLocalizations.of(context).hide,
              textStyle: ThemeUtils.textStyleBodyBody1(
                color: AppColor.steelGray400,
              ),
              backgroundColor: Colors.transparent,
              onTapActionCallback: () => setState(() => _isDisplayAll = false),
            )
          ]
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _getMaxWidth(context),
                maxHeight: 34,
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  if (widget.emailSelected.to.numberEmailAddress() > 0)
                    ..._buildRecipientsWidget(
                      context: context,
                      prefixEmailAddress: PrefixEmailAddress.to,
                      listEmailAddress: PrefixEmailAddress.to.listEmailAddress(widget.emailSelected)
                    ),
                  if (widget.emailSelected.cc.numberEmailAddress() > 0)
                    ..._buildRecipientsWidget(
                      context: context,
                      prefixEmailAddress: PrefixEmailAddress.cc,
                      listEmailAddress: PrefixEmailAddress.cc.listEmailAddress(widget.emailSelected)
                    ),
                  if (widget.emailSelected.bcc.numberEmailAddress() > 0)
                    ..._buildRecipientsWidget(
                      context: context,
                      prefixEmailAddress: PrefixEmailAddress.bcc,
                      listEmailAddress: PrefixEmailAddress.bcc.listEmailAddress(widget.emailSelected)
                    ),
                ]
              ),
            ),
            if (widget.emailSelected.countRecipients > 1)
              TMailButtonWidget.fromIcon(
                icon: _imagePaths.icChevronDownOutline,
                iconColor: AppColor.steelGray400,
                padding: const EdgeInsets.all(3),
                iconSize: 20,
                backgroundColor: Colors.transparent,
                onTapActionCallback: () => setState(() => _isDisplayAll = true),
              )
          ]
        );
      }
    } else {
      if (_isDisplayAll) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.emailSelected.to.numberEmailAddress() > 0)
                      _buildRecipientsWidgetToDisplayFull(
                        context: context,
                        prefixEmailAddress: PrefixEmailAddress.to,
                        listEmailAddress: PrefixEmailAddress.to.listEmailAddress(widget.emailSelected)
                      ),
                    if (widget.emailSelected.cc.numberEmailAddress() > 0)
                      _buildRecipientsWidgetToDisplayFull(
                        context: context,
                        prefixEmailAddress: PrefixEmailAddress.cc,
                        listEmailAddress: PrefixEmailAddress.cc.listEmailAddress(widget.emailSelected)
                      ),
                    if (widget.emailSelected.bcc.numberEmailAddress() > 0)
                      _buildRecipientsWidgetToDisplayFull(
                        context: context,
                        prefixEmailAddress: PrefixEmailAddress.bcc,
                        listEmailAddress: PrefixEmailAddress.bcc.listEmailAddress(widget.emailSelected)
                      ),
                  ],
                )
              ),
              TMailButtonWidget.fromText(
                text: AppLocalizations.of(context).hide,
                textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColor.primaryColor,
                  fontSize: 15
                ),
                backgroundColor: Colors.transparent,
                onTapActionCallback: () => setState(() => _isDisplayAll = false),
              )
            ]
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              constraints: BoxConstraints(maxWidth: _getMaxWidth(context)),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  if (widget.emailSelected.to.numberEmailAddress() > 0)
                    ..._buildRecipientsWidget(
                      context: context,
                      prefixEmailAddress: PrefixEmailAddress.to,
                      listEmailAddress: PrefixEmailAddress.to.listEmailAddress(widget.emailSelected)
                    ),
                  if (widget.emailSelected.cc.numberEmailAddress() > 0)
                    ..._buildRecipientsWidget(
                      context: context,
                      prefixEmailAddress: PrefixEmailAddress.cc,
                      listEmailAddress: PrefixEmailAddress.cc.listEmailAddress(widget.emailSelected)
                    ),
                  if (widget.emailSelected.bcc.numberEmailAddress() > 0)
                    ..._buildRecipientsWidget(
                      context: context,
                      prefixEmailAddress: PrefixEmailAddress.bcc,
                      listEmailAddress: PrefixEmailAddress.bcc.listEmailAddress(widget.emailSelected)
                    ),
                ]
              ),
            ),
            if (widget.emailSelected.countRecipients > 1)
              TMailButtonWidget.fromIcon(
                icon: _imagePaths.icChevronDown,
                backgroundColor: Colors.transparent,
                onTapActionCallback: () => setState(() => _isDisplayAll = true),
              )
          ]
        );
      }
    }
  }

  List<Widget> _buildRecipientsTag({required List<EmailAddress> listEmailAddress}) {
    return listEmailAddress
      .mapIndexed((index, emailAddress) => TMailButtonWidget.fromText(
        text: index == listEmailAddress.length - 1
          ? emailAddress.asString()
          : '${emailAddress.asString()},',
        textStyle: ThemeUtils.textStyleBodyBody1(color: AppColor.steelGray400),
        padding: const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 8),
        backgroundColor: Colors.transparent,
        onTapActionCallback: () => widget.openEmailAddressDetailAction?.call(context, emailAddress),
        onLongPressActionCallback: () => AppUtils.copyEmailAddressToClipboard(context, emailAddress.emailAddress),
      ))
      .toList();
  }


  Widget _buildRecipientsWidgetToDisplayFull({
    required BuildContext context,
    required PrefixEmailAddress prefixEmailAddress,
    required List<EmailAddress> listEmailAddress,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrefixRecipientWidget(prefixEmailAddress: prefixEmailAddress),
        Expanded(
          child: Wrap(
            children: _buildRecipientsTag(listEmailAddress: listEmailAddress)
          )
        )
      ],
    );
  }

  List<Widget> _buildRecipientsWidget({
    required BuildContext context,
    required PrefixEmailAddress prefixEmailAddress,
    required List<EmailAddress> listEmailAddress,
  }) {
    return [
      PrefixRecipientWidget(prefixEmailAddress: prefixEmailAddress),
      ..._buildRecipientsTag(listEmailAddress: listEmailAddress)
    ];
  }

  double _getMaxWidth(BuildContext context) {
    if (_responsiveUtils.isPortraitMobile(context)) {
      return widget.maxWidth - _maxSizeFullDisplayEmailAddressArrowDownButton;
    } else if (_responsiveUtils.isWebDesktop(context)) {
      return widget.maxWidth / 2;
    } else {
      return widget.maxWidth * 3/4;
    }
  }

  double get _maxHeight {
    return _isDisplayAll && widget.maxHeight != null
      ? widget.maxHeight! / 2 - _offsetTop
      : double.infinity;
  }
}