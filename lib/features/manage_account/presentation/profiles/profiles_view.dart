
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/widgets/profiles_header_widget.dart';

class ProfilesView extends StatelessWidget {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  ProfilesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingDetailViewBuilder(
      responsiveUtils: _responsiveUtils,
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
              ]
            )
          ))
        ]
      )
    );
  }
}