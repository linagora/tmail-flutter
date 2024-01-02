import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_id/twake_id_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TwakeIdView extends GetWidget<TwakeIdController> {

  const TwakeIdView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

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
    );
  }
}