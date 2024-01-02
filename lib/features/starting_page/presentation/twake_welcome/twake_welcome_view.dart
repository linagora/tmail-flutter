import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TwakeWelcomeView extends GetWidget<TwakeWelcomeController> {

  const TwakeWelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    return TwakeWelcomeScreen(
      logo: SvgPicture.asset(controller.imagePaths.icLogoTwakeWelcome),
      signInTitle: AppLocalizations.of(context).signIn.capitalizeFirst ?? '',
      createTwakeIdTitle: AppLocalizations.of(context).createTwakeId,
      useCompanyServerTitle: AppLocalizations.of(context).useCompanyServer,
      description: AppLocalizations.of(context).descriptionWelcomeTo,
    );
  }
}