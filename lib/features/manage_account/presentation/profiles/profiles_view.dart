
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class ProfilesView extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;

  const ProfilesView({
    Key? key,
    required this.responsiveUtils,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingDetailViewBuilder(
      responsiveUtils: responsiveUtils,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (responsiveUtils.isWebDesktop(context))
            ...[
              const SettingHeaderWidget(menuItem: AccountMenuItem.profiles),
              const Divider(height: 1, color: AppColor.colorDividerHeaderSetting),
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