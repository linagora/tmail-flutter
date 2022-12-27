
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ProfilesView extends GetWidget<ProfilesController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  ProfilesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(context, _responsiveUtils),
      body: ResponsiveWidget(
        responsiveUtils: _responsiveUtils, 
        mobile: IdentitiesView(),
        desktop: _buildProfilesWeb(context))
    );
  }

  Widget _buildProfilesWeb(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        border: Border.all(color: AppColor.colorBorderIdentityInfo),
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for(var widget in _buildProfilesTitle(context))
            widget,
          const Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2),
          Expanded(child: IdentitiesView()),
        ],
      ),
    );
  }

  List<Widget> _buildProfilesTitle(BuildContext context) {
    return [
      Text(
        AppLocalizations.of(context).profiles.inCaps, 
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          fontFamily: 'Inter',
          color: Colors.black)),
      const SizedBox(height: 4.0),
      Text(
        AppLocalizations.of(context).profiles_description,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColor.colorContentEmail),
        ),
      const SizedBox(height: 16.0),
    ];
  }
}