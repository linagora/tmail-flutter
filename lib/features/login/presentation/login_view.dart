import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/base/widget/recent_item_tile_widget.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/presentation/base_login_view.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/dns_lookup_input_form.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/horizontal_progress_loading_button.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_back_button.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_message_widget.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/password_input_form.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LoginView extends BaseLoginView {

  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeUtils.setSystemDarkUIStyle();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => !didPop
        ? controller.handleBackButtonAction(context)
        : null,
      child: Scaffold(
        backgroundColor: AppColor.primaryLightColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: _supportScrollForm(context)
                  ? Stack(children: [
                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: _buildCenterForm(context)
                        )
                      ),
                      Obx(() {
                        if (controller.isBackButtonActivated) {
                          return LoginBackButton(
                            onBackAction: () => controller.handleBackButtonAction(context)
                          );
                        }
                        return const SizedBox.shrink();
                      })
                    ])
                  : Stack(children: [
                      _buildCenterForm(context),
                      Obx(() {
                        if (controller.isBackButtonActivated) {
                          return LoginBackButton(
                            onBackAction: () => controller.handleBackButtonAction(context)
                          );
                        }
                        return const SizedBox.shrink();
                      })
                    ]),
            ),
          ),
        )),
    );
  }

  Widget _buildCenterForm(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: _supportScrollForm(context)
          ? const BoxConstraints(minWidth: 240, maxWidth: 400)
          : const BoxConstraints(minWidth: double.infinity),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: controller.responsiveUtils.isHeightShortest(context) ? 64 : 0),
              child: Text(
                AppLocalizations.of(context).login,
                style: const TextStyle(fontSize: 32, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
              )
            ),
            Obx(() => LoginMessageWidget(
              formType: controller.loginFormType.value,
              viewState: controller.viewState.value,
            )),
            Obx(() {
              switch (controller.loginFormType.value) {
                case LoginFormType.dnsLookupForm:
                case LoginFormType.retry:
                  return DNSLookupInputForm(
                    textEditingController: controller.usernameInputController,
                    onTextChange: controller.onUsernameChange,
                    onTextSubmitted: (_) => controller.invokeDNSLookupToGetJmapUrl(),
                    suggestionsCallback: controller.getAllRecentLoginUsernameAction,
                    onSuggestionSelected: controller.selectUsernameFromSuggestion
                  );
                case LoginFormType.passwordForm:
                  return PasswordInputForm(
                    key: const Key('password_input_form'),
                    textEditingController: controller.passwordInputController,
                    focusNode: controller.passFocusNode,
                    onTextChange: controller.onPasswordChange,
                    onTextSubmitted: (_) => controller.handleLoginPressed(context),
                  );
                case LoginFormType.baseUrlForm:
                  return _buildUrlInput(context);
                case LoginFormType.credentialForm:
                  return buildInputCredentialForm(context);
                default:
                  return const SizedBox.shrink();
              }
            }),
            _buildLoadingProgress(context),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: PrivacyLinkWidget(),
            ),
            const ApplicationVersionWidget(),
          ]
        ),
      )
    );
  }

  Widget _buildUrlInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
      child: TypeAheadFormFieldBuilder<RecentLoginUrl>(
        controller: controller.urlInputController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.url,
        focusNode: controller.baseUrlFocusNode,
        onTextChange: controller.onBaseUrlChange,
        onTextSubmitted: (value) => controller.handleNextInUrlInputFormPress(),
        decoration: (LoginInputDecorationBuilder()
            ..setLabelText(AppLocalizations.of(context).prefix_https)
            ..setPrefixText(AppLocalizations.of(context).prefix_https))
         .build(),
        debounceDuration: const Duration(milliseconds: 300),
        suggestionsCallback: controller.getAllRecentLoginUrlAction,
        itemBuilder: (_, loginUrl) => RecentItemTileWidget(loginUrl),
        onSuggestionSelected: (loginUrl) => controller.selectBaseUrlFromSuggestion(loginUrl.url),
        noItemsFoundBuilder: (context) => const SizedBox(),
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
      ));
  }

  Widget _buildExpandedButton(BuildContext context, Widget child) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: child
      )
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      width: controller.responsiveUtils.getDeviceWidth(context),height: 48,
      child: ElevatedButton(
        key: const Key('nextToCredentialForm'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 0, color: AppColor.primaryColor)
          )
        ),
        child: Text(AppLocalizations.of(context).next,
          style: const TextStyle(fontSize: 16, color: Colors.white)
        ),
        onPressed: () {
          if (controller.loginFormType.value == LoginFormType.retry) {
            controller.loginFormType.value = LoginFormType.dnsLookupForm;
          }
          if (controller.loginFormType.value == LoginFormType.dnsLookupForm) {
            controller.invokeDNSLookupToGetJmapUrl();
          } else {
            controller.handleNextInUrlInputFormPress();
          }
        }
      )
    );
  }

  Widget _buildNextButtonInContext(BuildContext context) {
    return _supportScrollForm(context)
      ? _buildNextButton(context)
      : _buildExpandedButton(context, _buildNextButton(context));
  }

  Widget _buildLoginButtonInContext(BuildContext context) {
    return _supportScrollForm(context)
      ? buildLoginButton(context)
      : _buildExpandedButton(context, buildLoginButton(context));
  }
  
  bool _supportScrollForm(BuildContext context) {
    return !(controller.responsiveUtils.isMobile(context) && controller.responsiveUtils.isPortrait(context));
  }

  Widget _buildLoadingProgress(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) {
        switch (controller.loginFormType.value) {
          case LoginFormType.dnsLookupForm:
          case LoginFormType.baseUrlForm:
          case LoginFormType.retry:
            return _buildNextButtonInContext(context);
          case LoginFormType.passwordForm:
          case LoginFormType.credentialForm:
            return _buildLoginButtonInContext(context);
          default:
            return const SizedBox.shrink();
        }
      },
      (success) {
        if (success is LoadingState) {
          return _supportScrollForm(context)
            ? const HorizontalProgressLoadingButton()
            : _buildExpandedButton(context, const HorizontalProgressLoadingButton());
        } else {
          switch (controller.loginFormType.value) {
            case LoginFormType.dnsLookupForm:
            case LoginFormType.baseUrlForm:
              return _buildNextButtonInContext(context);
            case LoginFormType.passwordForm:
            case LoginFormType.credentialForm:
              return _buildLoginButtonInContext(context);
            default:
              return const SizedBox.shrink();
          }
        }
      }
    ));
  }
}