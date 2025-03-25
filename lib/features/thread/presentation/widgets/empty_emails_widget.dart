import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/empty_emails_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmptyEmailsWidget extends StatelessWidget {

  final bool isSearchActive;
  final bool isFilterMessageActive;
  final bool isNetworkConnectionAvailable;

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  EmptyEmailsWidget({
    Key? key,
    this.isSearchActive = false,
    this.isFilterMessageActive = false,
    this.isNetworkConnectionAvailable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final childWidget = Padding(
      padding: EmptyEmailsWidgetStyles.padding,
      child: Column(
        mainAxisAlignment: _responsiveUtils.isScreenWithShortestSide(context)
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            _imagePaths.icEmptyFolder,
            width: EmptyEmailsWidgetStyles.iconSize,
            height: EmptyEmailsWidgetStyles.iconSize,
            fit: BoxFit.fill
          ),
          Padding(
            padding: EmptyEmailsWidgetStyles.labelPadding,
            child: Text(
              key: const Key('empty_email_message'),
              _getMessageEmptyEmail(context),
              style: ThemeUtils.textStyleInter600(),
              textAlign: TextAlign.center,
            ),
          ),
          if (_showEmailSubMessage)
            Text(
              key: const Key('empty_email_sub_message'),
              AppLocalizations.of(context).startToComposeEmails,
              style: ThemeUtils.textStyleInter400.copyWith(
                letterSpacing: -0.15,
                fontSize: 16,
                height: 21.01 / 16,
                color: AppColor.gray424244.withValues(alpha: 0.64),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
    return Container(
      constraints: const BoxConstraints(maxWidth: EmptyEmailsWidgetStyles.maxWidth),
      alignment: AlignmentDirectional.center,
      child: _responsiveUtils.isScreenWithShortestSide(context)
        ? SingleChildScrollView(child: childWidget)
        : CustomScrollView(
            slivers: [
              SliverFillRemaining(child: childWidget)
            ]
          )
    );
  }

  bool get _showEmailSubMessage => isNetworkConnectionAvailable &&
      !isFilterMessageActive &&
      !isSearchActive;

  String _getMessageEmptyEmail(BuildContext context) {
    if (!isNetworkConnectionAvailable) {
      return AppLocalizations.of(context).no_internet_connection_try_again_later;
    }
    
    if (isSearchActive) {
      return AppLocalizations.of(context).no_emails_matching_your_search;
    } else if (isFilterMessageActive) {
      return AppLocalizations.of(context).noEmailMatchYourCurrentFilter;
    } else {
      return AppLocalizations.of(context).youDoNotHaveAnyEmailInYourCurrentFolder;
    }
  }
}