import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/state/login_state.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_text_input_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LoginView extends GetWidget<LoginController> {

  final loginController = Get.find<LoginController>();
  final imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final keyboardUtils = Get.find<KeyboardUtils>();

  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.primaryLightColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: _supportScrollForm(context)
            ? Stack(
                children: [
                  Center(child: SingleChildScrollView(child: _buildCenterForm(context), scrollDirection: Axis.vertical)),
                  Obx(() {
                    return loginController.loginFormType.value == LoginFormType.credentialForm
                      ? _buildBackButton(context)
                      : const SizedBox.shrink();
                  })
                ]
              )
            : Stack(
                children: [
                  _buildCenterForm(context),
                  Obx(() {
                    return loginController.loginFormType.value == LoginFormType.credentialForm
                      ? _buildBackButton(context)
                      : const SizedBox.shrink();
                  })
                ]
            ),
        ),
    ));
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
                top: _responsiveUtils.isHeightShortest(context) ? 64 : 0),
              child: Text(
                AppLocalizations.of(context).login,
                style: const TextStyle(fontSize: 32, color: AppColor.colorNameEmail, fontWeight: FontWeight.w900)
              )
            ),
            Obx(() => _buildLoginMessage(context, loginController.loginState.value)),
            Obx(() {
              switch (controller.loginFormType.value) {
                case LoginFormType.baseUrlForm:
                  return _buildUrlInput(context);
                case LoginFormType.credentialForm:
                  return _buildInputCredentialForm(context);
                default:
                  return const SizedBox.shrink();
              }
            }),
            Obx(() {
              switch (controller.loginFormType.value) {
                case LoginFormType.baseUrlForm:
                  return _supportScrollForm(context)
                    ? _buildNextButton(context)
                    : _buildExpandedButton(context, _buildNextButton(context));
                case LoginFormType.credentialForm:
                  return Obx(() => loginController.loginState.value.viewState.fold(
                    (failure) => _buildLoginButtonInContext(context),
                    (success) => success is LoginLoadingAction
                      ? _buildLoadingCircularProgress()
                      : _buildLoginButtonInContext(context)));
                default:
                  return const SizedBox.shrink();
              }
            })
          ]
        ),
      )
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
        left: 12,
        top: 12,
        child: IconButton(
          key: const Key('login_arrow_back_button'),
          onPressed: () => controller.handleBackInCredentialForm(),
          icon: SvgPicture.asset(
            imagePaths.icBack,
            alignment: Alignment.center,
            color: AppColor.primaryColor
          )
        ),
    );
  }

  Widget _buildLoginMessage(BuildContext context, LoginState loginState) {
    return Padding(
      padding: const EdgeInsets.only(top: 11, bottom: 36, left: 58, right: 58),
      child: SizedBox(
        width: _responsiveUtils.getWidthLoginTextField(context),
        child: CenterTextBuilder()
          .key(const Key('login_message'))
          .text(loginState.viewState.fold(
            (failure) => failure is AuthenticationUserFailure
              ? AppLocalizations.of(context).unknown_error_login_message
              : AppLocalizations.of(context).loginInputUrlMessage,
            (success) => AppLocalizations.of(context).loginInputUrlMessage))
          .textStyle(TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: loginState.viewState.fold(
              (failure) => failure is AuthenticationUserFailure
                ? AppColor.textFieldErrorBorderColor
                : AppColor.colorNameEmail,
              (success) => AppColor.colorNameEmail)))
          .build()
      )
    );
  }

  Widget _buildInputCredentialForm(BuildContext context) {
    return Column(
      children: [
        _buildUserNameInput(context),
        _buildPasswordInput(context)
      ],
    );
  }

  Widget _buildUrlInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
      child: Container(
        child: (TextFieldBuilder()
            ..key(const Key('login_url_input'))
            ..onChange((value) => loginController.formatUrl(value))
            ..textInputAction(TextInputAction.next)
            ..addController(loginController.urlInputController)
            ..keyboardType(TextInputType.url)
            ..onSubmitted((value) {
                controller.handleNextInUrlInputFormPress();
              })
            ..textDecoration((LoginInputDecorationBuilder()
                  ..setLabelText(AppLocalizations.of(context).prefix_https)
                  ..setPrefixText(AppLocalizations.of(context).prefix_https))
               .build()))
          .build()));
  }

  Widget _buildUserNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 24, left: 24),
      child: Container(
        child: (TextFieldBuilder()
            ..key(const Key('login_username_input'))
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
      padding: const EdgeInsets.only(bottom: 40, right: 24, left: 24),
      child: Container(
        child: (LoginTextInputBuilder(context, imagePaths)
            ..setOnSubmitted((value) => loginController.handleLoginPressed())
            ..passwordInput(true)
            ..key(const Key('login_password_input'))
            ..obscureText(true)
            ..onChange((value) => loginController.setPasswordText(value))
            ..textInputAction(TextInputAction.done)
            ..hintText(AppLocalizations.of(context).password))
          .build()));
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
      width: _responsiveUtils.getDeviceWidth(context),height: 48,
      child: ElevatedButton(
        key: const Key('nextToCredentialForm'),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white),
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => AppColor.primaryColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 0, color: AppColor.primaryColor)
          ))
        ),
        child: Text(AppLocalizations.of(context).next,
          style: const TextStyle(fontSize: 16, color: Colors.white)
        ),
        onPressed: () {
          loginController.handleNextInUrlInputFormPress();
        }
      )
    );
  }

  Widget _buildLoginButtonInContext(BuildContext context) {
    return _supportScrollForm(context)
      ? _buildLoginButton(context)
      : _buildExpandedButton(context, _buildLoginButton(context));
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      width: _responsiveUtils.getDeviceWidth(context),height: 48,
      child: ElevatedButton(
        key: const Key('loginSubmitForm'),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white),
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => AppColor.primaryColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 0, color: AppColor.primaryColor)
          ))
        ),
        child: Text(AppLocalizations.of(context).login,
          style: const TextStyle(fontSize: 16, color: Colors.white)
        ),
        onPressed: () {
          loginController.handleLoginPressed();
        }
      )
    );
  }

  Widget _buildLoadingCircularProgress() {
    return const SizedBox(
      key: Key('login_loading_icon'),
      width: 40,
      height: 40,
      child: CircularProgressIndicator(color: AppColor.primaryColor));
  }
  
  bool _supportScrollForm(BuildContext context) {
    return !(responsiveUtils.isMobile(context) && responsiveUtils.isPortrait(context));
  }
}