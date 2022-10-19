import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_app.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class AppListDashboardItem extends StatefulWidget {
  final LinagoraApp app;

  const AppListDashboardItem(this.app, {Key? key}) : super(key: key);

  @override
  State<AppListDashboardItem> createState() => _AppListDashboardItemState();
}

class _AppListDashboardItemState extends State<AppListDashboardItem> {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  bool _isHoverItem = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return InkWell(
          onTap: () => _openApp(widget.app.appUri),
          onHover: (value) => setState(() => _isHoverItem = value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: _backgroundColorItem(context)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildAppItem(context)
          ),
        );
      }
    );
  }

  Widget _buildAppItem(BuildContext context) {
    final builder = SloganBuilder(arrangedByHorizontal: true)
      ..setSizeLogo(32.0)
      ..setPadding(const EdgeInsets.only(left: 12))
      ..setSloganText(widget.app.appName)
      ..addOnTapCallback(() async {
        final url = widget.app.appUri;
        if (await launcher.canLaunchUrl(url)) {
          await launcher.launchUrl(url);
        }
      })
      ..setSloganTextStyle(const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorNameEmail));
    if (widget.app.iconName.endsWith('svg')) {
      builder.setLogoSVG(_imagePaths.getConfigurationImagePath(widget.app.iconName));
    } else {
      builder.setLogo(_imagePaths.getConfigurationImagePath(widget.app.iconName));
    }
    return builder.build();
  }

  Color _backgroundColorItem(BuildContext context) {
    if (_isHoverItem) {
      return AppColor.colorBgMailboxSelected;
    }
    return _responsiveUtils.isDesktop(context)
      ? AppColor.colorBgDesktop
      : Colors.white;
  }

  void _openApp(Uri appLink) async {
    if (await launcher.canLaunchUrl(appLink)) {
      await launcher.launchUrl(appLink);
    }
  }
}
