
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/widgets/profiles_header_widget.dart';

class ProfilesView extends GetWidget<ProfilesController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ProfilesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(context, _responsiveUtils),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SettingsUtils.getContentBackgroundColor(context, _responsiveUtils),
        decoration: SettingsUtils.getBoxDecorationForContent(context, _responsiveUtils),
        margin: SettingsUtils.getMarginViewForForwardSettingDetails(context, _responsiveUtils),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_responsiveUtils.isWebDesktop(context))
              ...[
                ProfilesHeaderWidget(imagePaths: _imagePaths, responsiveUtils: _responsiveUtils),
                Container(height: 1, color: AppColor.colorDividerHeaderSetting)
              ],
            Expanded(child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IdentitiesView()
                ])
            ))
          ],
        ),
      ),
    );
  }
}