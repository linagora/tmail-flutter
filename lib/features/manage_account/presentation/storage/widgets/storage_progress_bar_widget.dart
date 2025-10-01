import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class StorageProgressBarWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final Quota quota;
  final bool isMobile;

  const StorageProgressBarWidget({
    super.key,
    required this.imagePaths,
    required this.quota,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    final logoStorageWidget = Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColor.lightGrayF6FAFF,
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        imagePaths.icCloud,
        width: 30.72,
        height: 30.72,
        fit: BoxFit.fill,
      ),
    );

    final infoStorageWidgets = <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            quota.usedStorageAsString,
            style: ThemeUtils.textStyleInter600().copyWith(
              color: AppColor.m3SurfaceBackground,
              fontSize: 18.13,
              height: 22.66 / 18.13,
              letterSpacing: 0.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text(
                      appLocalizations.storageUsedMessage(
                        quota.hardLimitStorageAsString,
                      ),
                      style: ThemeUtils.textStyleInter500().copyWith(
                        color: AppColor.m3Tertiary20,
                        fontSize: 9.06,
                        height: 13.6 / 9.06,
                        letterSpacing: 0.08,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Text(
                  appLocalizations.storageAvailableMessage(
                    quota.quotaAvailableStorageAsString,
                  ),
                  style: ThemeUtils.textStyleInter600().copyWith(
                    color: AppColor.m3Tertiary20,
                    fontSize: 9.06,
                    height: 13.6 / 9.06,
                    letterSpacing: 0.08,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.only(top: 5),
        width: double.infinity,
        child: LinearProgressIndicator(
          color: quota.getQuotasStateProgressBarColor(
            fromSetting: true,
          ),
          minHeight: 4.53,
          backgroundColor: AppColor.lightGrayF7F6F9,
          borderRadius: const BorderRadius.all(
            Radius.circular(13.03),
          ),
          value: quota.usedStoragePercent,
        ),
      ),
    ];

    return Container(
      width: isMobile ? double.infinity : 439,
      padding: const EdgeInsets.only(bottom: 16),
      child: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                logoStorageWidget,
                const SizedBox(height: 8),
                ...infoStorageWidgets,
              ],
            )
          : Row(
              children: [
                logoStorageWidget,
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: infoStorageWidgets,
                  ),
                ),
              ],
            ),
    );
  }
}
