
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_button.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_sender_builder.dart';
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
  final _scrollController = ScrollController();

  bool _isDisplayAll = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Padding(
          padding: EdgeInsets.only(top: _isDisplayAll
            ? DirectionUtils.isDirectionRTLByLanguage(context) ? 3 : 5.5
            : 0),
          child: PlatformInfo.isWeb
            ? Container(
                constraints: BoxConstraints(
                  maxHeight: _isDisplayAll && widget.maxHeight != null
                    ? widget.maxHeight! / 2 - _offsetTop
                    : double.infinity
                ),
                child: ScrollbarListView(
                  scrollController: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: _buildEmailAddressOfReceiver(
                      context,
                      widget.emailSelected,
                      _isDisplayAll,
                      widget.maxWidth
                    ),
                  ),
                ),
              )
            : _buildEmailAddressOfReceiver(
                context,
                widget.emailSelected,
                _isDisplayAll,
                widget.maxWidth
              ),
        )),
        if (_isDisplayAll)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: DirectionUtils.isDirectionRTLByLanguage(context) ? 0 : 6),
            child: MaterialTextButton(
              padding: DirectionUtils.isDirectionRTLByLanguage(context)
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                : null,
              onTap: () => setState(() => _isDisplayAll = false),
              label: AppLocalizations.of(context).hide,
            )
          )
      ]
    );
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
          Transform(
            transform: Matrix4.translationValues(0.0, -5.0, 0.0),
            child: TMailButtonWidget.fromIcon(
              icon: _imagePaths.icChevronDown,
              backgroundColor: Colors.transparent,
              onTapActionCallback: () => setState(() => _isDisplayAll = true),
            ),
          )
        ]
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        onTap: () => widget.openEmailAddressDetailAction?.call(context, emailAddress),
        onLongPress: () {
          AppUtils.copyEmailAddressToClipboard(context, emailAddress.emailAddress);
        },
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
    if (_responsiveUtils.isPortraitMobile(context)) {
      return maxWidth - _maxSizeFullDisplayEmailAddressArrowDownButton;
    } else if (_responsiveUtils.isWebDesktop(context)) {
      return maxWidth / 2;
    } else {
      return maxWidth * 3/4;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}