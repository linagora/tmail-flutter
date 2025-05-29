import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/presentation/views/text/slogan_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tmail_ui_user/features/base/widget/application_logo_with_text_widget.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/login/presentation/base_login_view.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/privacy_link_widget.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_message_widget.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/try_again_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LoginView extends BaseLoginView {

  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryLightColor,
      body: Center(child: SingleChildScrollView(
          child: ResponsiveWidget(
            responsiveUtils: controller.responsiveUtils,
            mobile: _buildMobileForm(context),
            desktop: _buildWebForm(context),
          ))),
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
                child: ApplicationLogoWidthTextWidget()
              ),
              Padding(
                padding: const EdgeInsets.only(top: 67),
                child: Text(
                    AppLocalizations.of(context).signIn,
                    style: const TextStyle(fontSize: 32, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
                )
              ),
              Obx(() => LoginMessageWidget(
                formType: controller.loginFormType.value,
                viewState: controller.viewState.value,
              )),
              Obx(() {
                switch (controller.loginFormType.value) {
                  case LoginFormType.credentialForm:
                    return buildInputCredentialForm(context);
                  case LoginFormType.retry:
                    return TryAgainButton(
                      onRetry: controller.retryCheckOidc,
                      responsiveUtils: controller.responsiveUtils,
                    );
                  default:
                    return const SizedBox.shrink();
                }
              }),
              _buildLoadingProgress(context),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: PrivacyLinkWidget(),
              ),
              const ApplicationVersionWidget(padding: EdgeInsets.only(top: 8)),
            ],
          )
        ),
        Positioned.fill(
          bottom: 24,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              controller.imagePaths.icPowerByLinagora,
              width: 97,
              height: 44,
              fit: BoxFit.fill)))
      ],
    );
  }

  Widget _buildWebForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 60),
      child: Row(
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
                  child: SloganBuilder(
                    arrangedByHorizontal: true,
                    logo: controller.imagePaths.icJMAPStandard,
                    sizeLogo: 48.0,
                    paddingText: const EdgeInsets.only(left: 12),
                    text: AppLocalizations.of(context).jmapStandard,
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.colorNameEmail)
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SloganBuilder(
                    arrangedByHorizontal: true,
                    logo: controller.imagePaths.icEncrypted,
                    sizeLogo: 48.0,
                    paddingText: const EdgeInsets.only(left: 12),
                    text: AppLocalizations.of(context).encryptedMailbox,
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.colorNameEmail)
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SloganBuilder(
                    arrangedByHorizontal: true,
                    logo: controller.imagePaths.icTeam,
                    sizeLogo: 48.0,
                    paddingText: const EdgeInsets.only(left: 12),
                    text: AppLocalizations.of(context).manageEmailAsATeam,
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.colorNameEmail)
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SloganBuilder(
                    arrangedByHorizontal: true,
                    logo: controller.imagePaths.icIntegration,
                    sizeLogo: 48.0,
                    paddingText: const EdgeInsets.only(left: 12),
                    text: AppLocalizations.of(context).multipleIntegrations,
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColor.colorNameEmail)
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 44),
                  child: SvgPicture.asset(
                    controller.imagePaths.icLoginGraphic,
                    fit: BoxFit.fill,
                    alignment: Alignment.center
                  )
                )
              ],
            )
          ),
          Column(
            children: [
              Container(
                height: 684,
                width: 458,
                padding: const EdgeInsets.symmetric(horizontal: 31),
                clipBehavior: Clip.antiAlias,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  shadows: [
                    BoxShadow(
                      color: AppColor.loginViewShadowColor,
                      blurRadius: 40,
                      offset: Offset(0, 2),
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 66),
                      child: ApplicationLogoWidthTextWidget()
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 67),
                      child: Text(
                        AppLocalizations.of(context).signIn,
                        style: const TextStyle(fontSize: 32, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
                      )
                    ),
                    Obx(() => LoginMessageWidget(
                      formType: controller.loginFormType.value,
                      viewState: controller.viewState.value,
                    )),
                    Obx(() {
                      switch (controller.loginFormType.value) {
                        case LoginFormType.credentialForm:
                          return buildInputCredentialForm(context);
                        case LoginFormType.retry:
                          return TryAgainButton(
                            onRetry: controller.retryCheckOidc,
                            responsiveUtils: controller.responsiveUtils,
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    }),
                    _buildLoadingProgress(context),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: PrivacyLinkWidget()
                    ),
                    const ApplicationVersionWidget(padding: EdgeInsets.only(top: 8)),
                  ],
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 44, bottom: 10),
                child: SvgPicture.asset(controller.imagePaths.icPowerByLinagora, width: 97, height: 44, fit: BoxFit.fill)
              )
            ]
          )
        ],
      )
    );
  }

  Widget _buildLoadingProgress(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) {
        switch (controller.loginFormType.value) {
          case LoginFormType.credentialForm:
            return buildLoginButton(context);
          default:
            return const SizedBox.shrink();
        }
      },
      (success) {
        if (success is LoadingState) {
          return buildLoadingCircularProgress();
        } else {
          switch (controller.loginFormType.value) {
            case LoginFormType.credentialForm:
              return buildLoginButton(context);
            default:
              return const SizedBox.shrink();
          }
        }
      }
    ));
  }
}