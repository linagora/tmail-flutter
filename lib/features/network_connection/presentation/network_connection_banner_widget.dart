
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NetworkConnectionBannerWidget extends StatelessWidget {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  NetworkConnectionBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.colorNetworkConnectionBannerBackground,
      width: double.infinity,
      padding: _getPadding(context),
      margin: const EdgeInsetsDirectional.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).no_internet_connection,
            textAlign: TextAlign.center,
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              color: AppColor.colorNetworkConnectionLabel,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsetsGeometry _getPadding(BuildContext context) {
    if (_responsiveUtils.isMobile(context) || _responsiveUtils.isTabletLarge(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 6);
    }
  }
}