import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_id/twake_id_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class TwakeIdView extends GetWidget<TwakeIdController> {

  const TwakeIdView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return TwakeIdScreen(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        signInTitle: AppLocalizations.of(context).signIn.capitalizeFirst ?? '',
        createTwakeIdTitle: AppLocalizations.of(context).createTwakeId,
        useCompanyServerTitle: AppLocalizations.of(context).useCompanyServer,
        description: AppLocalizations.of(context).descriptionTwakeId,
        onUseCompanyServerOnTap: controller.handleUseCompanyServer,
        backButton: controller.isAddAnotherAccount
          ? TMailButtonWidget.fromIcon(
              icon: controller.imagePaths.icArrowLeft,
              backgroundColor: Colors.transparent,
              margin: const EdgeInsetsDirectional.only(start: 8),
              iconColor: Colors.black,
              onTapActionCallback: popBack)
          : null,
      );
    });
  }
}