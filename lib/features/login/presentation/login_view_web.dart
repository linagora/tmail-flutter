import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tmail_ui_user/features/login/presentation/base_login_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LoginView extends BaseLoginView {

  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryLightColor,
      body: SafeArea(
        child: Center(child: SingleChildScrollView(
          child: ResponsiveWidget(
            responsiveUtils: responsiveUtils,
            mobile: _buildMobileForm(context),
            desktop: _buildWebForm(context),
        )))
      ),
    );
  }

  Widget _buildMobileForm(BuildContext context) {
    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 720, minHeight: 720),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 67),
                child: (SloganBuilder(arrangedByHorizontal: true)
                    ..setSloganText(AppLocalizations.of(context).app_name)
                    ..setSloganTextAlign(TextAlign.center)
                    ..setSloganTextStyle(const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold))
                    ..setSizeLogo(36)
                    ..setLogo(imagePaths.icLogoTMail))
                 .build()
              ),
              Padding(
                padding: const EdgeInsets.only(top: 67),
                child: Text(
                    AppLocalizations.of(context).signIn,
                    style: const TextStyle(fontSize: 32, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
                )
              ),
              Obx(() => buildLoginMessage(context, loginController.loginState.value)),
              buildInputCredentialForm(context),
              buildLoginButton(context)
            ],
          )
        ),
        Positioned.fill(
          bottom: 24,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              imagePaths.icPowerByLinagora,
              width: 97,
              height: 44,
              fit: BoxFit.fill)))
      ],
    );
  }

  Widget _buildWebForm(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 86),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).jmapBasedMailSolution,
                    style: const TextStyle(fontSize: 36, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: (SloganBuilder(arrangedByHorizontal: true, )
                        ..setLogoSVG(imagePaths.icJMAPStandard)
                        ..setSizeLogo(48.0)
                        ..setPadding(const EdgeInsets.only(left: 12))
                        ..setSloganText(AppLocalizations.of(context).jmapStandard)
                        ..setSloganTextStyle(const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.colorNameEmail)))
                      .build()
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: (SloganBuilder(arrangedByHorizontal: true, )
                        ..setLogoSVG(imagePaths.icEncrypted)
                        ..setSizeLogo(48.0)
                        ..setPadding(const EdgeInsets.only(left: 12))
                        ..setSloganText(AppLocalizations.of(context).encryptedMailbox)
                        ..setSloganTextStyle(const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.colorNameEmail)))
                      .build()
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: (SloganBuilder(arrangedByHorizontal: true, )
                        ..setLogoSVG(imagePaths.icTeam)
                        ..setSizeLogo(48.0)
                        ..setPadding(const EdgeInsets.only(left: 12))
                        ..setSloganText(AppLocalizations.of(context).manageEmailAsATeam)
                        ..setSloganTextStyle(const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.colorNameEmail)))
                      .build()
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: (SloganBuilder(arrangedByHorizontal: true, )
                        ..setLogoSVG(imagePaths.icIntegration)
                        ..setSizeLogo(48.0)
                        ..setPadding(const EdgeInsets.only(left: 12))
                        ..setSloganText(AppLocalizations.of(context).multipleIntegrations)
                        ..setSloganTextStyle(const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.colorNameEmail)))
                      .build()
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 44),
                    child: Image(
                      image: AssetImage(imagePaths.loginGraphic),
                      fit: BoxFit.fill,
                      alignment: Alignment.center
                    )
                  )
                ],
              )
            ),
            Column(
              children: [
                SizedBox(
                  height: 690,
                  width: 445,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 31, right: 31),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 66),
                            child: (SloganBuilder(arrangedByHorizontal: true)
                                ..setSloganText(AppLocalizations.of(context).app_name)
                                ..setSloganTextAlign(TextAlign.center)
                                ..setSloganTextStyle(const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold))
                                ..setSizeLogo(36)
                                ..setLogo(imagePaths.icLogoTMail))
                              .build()
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 67),
                            child: Text(
                              AppLocalizations.of(context).signIn,
                              style: const TextStyle(fontSize: 32, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
                            )
                          ),
                          Obx(() => buildLoginMessage(context, loginController.loginState.value)),
                          buildInputCredentialForm(context),
                          buildLoginButton(context)
                        ],
                      )
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 44, bottom: 10),
                  child: SvgPicture.asset(imagePaths.icPowerByLinagora, width: 97, height: 44, fit: BoxFit.fill))
              ]
            )
          ],
        )
      ],
    );
  }
}