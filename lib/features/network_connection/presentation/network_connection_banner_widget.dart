
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NetworkConnectionBannerWidget extends StatelessWidget {

  const NetworkConnectionBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.colorNetworkConnectionBannerBackground,
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).no_internet_connection,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColor.colorNetworkConnectionLabel,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}