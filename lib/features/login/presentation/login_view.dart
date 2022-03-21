import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/state/login_state.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LoginView extends GetWidget<LoginController> {

  final loginController = Get.find<LoginController>();
  final imagePaths = Get.find<ImagePaths>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final keyboardUtils = Get.find<KeyboardUtils>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.primaryLightColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSlogan(context),
                      Obx(() => _buildLoginMessage(context, loginController.loginState.value)),
                      if (!kIsWeb) _buildUrlInput(context),
                      _buildUserNameInput(context),
                      _buildPasswordInput(context),
                      Obx(() => loginController.loginState.value.viewState.fold(
                        (failure) => _buildLoginButton(context),
                        (success) => success is LoginLoadingAction ? _buildLoadingCircularProgress() : _buildLoginButton(context))),
                    ],
                  ),
                ),
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlogan(BuildContext context) {
    return (SloganBuilder()
        ..setSloganText(AppLocalizations.of(context).login_text_slogan)
        ..setSloganTextAlign(TextAlign.center)
        ..setSloganTextStyle(TextStyle(color: AppColor.primaryColor, fontSize: 16, fontWeight: FontWeight.w700))
        ..setLogo(imagePaths.icLogoTMail))
      .build();
  }

  Widget _buildLoginMessage(BuildContext context, LoginState loginState) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24, top: 60),
      child: Container(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: CenterTextBuilder()
          .key(Key('login_message'))
          .text(loginState.viewState.fold(
            (failure) => failure is AuthenticationUserFailure
              ? AppLocalizations.of(context).unknown_error_login_message
              : AppLocalizations.of(context).login_text_login_to_continue,
            (success) => AppLocalizations.of(context).login_text_login_to_continue))
          .textStyle(TextStyle(
            color: loginState.viewState.fold(
              (failure) => failure is AuthenticationUserFailure
                ? AppColor.textFieldErrorBorderColor
                : AppColor.appColor,
              (success) => AppColor.appColor)))
          .build()
      )
    );
  }

  Widget _buildUrlInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: (TextFieldBuilder()
            ..key(Key('login_url_input'))
            ..onChange((value) => loginController.formatUrl(value))
            ..textInputAction(TextInputAction.next)
            ..addController(loginController.urlInputController)
            ..keyboardType(TextInputType.url)
            ..textDecoration((LoginInputDecorationBuilder()
                ..setLabelText(AppLocalizations.of(context).prefix_https)
                ..setPrefixText(AppLocalizations.of(context).prefix_https))
                .build()))
          .build()));
  }

  Widget _buildUserNameInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: (TextFieldBuilder()
            ..key(Key('login_username_input'))
            ..onChange((value) => loginController.setUserNameText(value))
            ..textInputAction(TextInputAction.next)
            ..keyboardType(TextInputType.emailAddress)
            ..textDecoration((LoginInputDecorationBuilder()
                ..setLabelText(AppLocalizations.of(context).email)
                ..setHintText(AppLocalizations.of(context).email))
                .build()))
          .build()));
  }

  Widget _buildPasswordInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Container(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: (TextFieldBuilder()
            ..key(Key('login_password_input'))
            ..obscureText(true)
            ..onChange((value) => loginController.setPasswordText(value))
            ..textInputAction(TextInputAction.done)
            ..textDecoration((LoginInputDecorationBuilder()
                ..setLabelText(AppLocalizations.of(context).password)
                ..setHintText(AppLocalizations.of(context).password))
                .build()))
          .build()));
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: SizedBox(
        key: Key('login_confirm_button'),
        width: responsiveUtils.getWidthLoginButton(),
        height: 48,
        child: ElevatedButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white),
            backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => AppColor.buttonColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
              side: BorderSide(width: 0, color: AppColor.buttonColor)))),
          child: Text(AppLocalizations.of(context).login, style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            keyboardUtils.hideKeyboard(context);
            loginController.handleLoginPressed();
          }),
      )
    );
  }

  Widget _buildLoadingCircularProgress() {
    return SizedBox(
      key: Key('login_loading_icon'),
      width: 40,
      height: 40,
      child: CircularProgressIndicator(color: AppColor.primaryColor));
  }
}