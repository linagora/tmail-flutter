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
      welcomeTo: AppLocalizations.of(context).welcomeTo,
      logo: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SvgPicture.asset(controller.imagePaths.icLogoTwakeWelcome),
      ),
      descriptionWelcomeTo: AppLocalizations.of(context).descriptionWelcomeTo,
      titleStartMessaging: AppLocalizations.of(context).getStarted,
      titlePrivacy: '',
    );
  }
}