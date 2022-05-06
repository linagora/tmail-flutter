import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/text_builder.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/state/login_state.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_text_input_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract class BaseLoginView extends GetWidget<LoginController> {
  BaseLoginView({Key? key}) : super(key: key);

  final loginController = Get.find<LoginController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  Widget buildLoginMessage(BuildContext context, LoginState loginState) {
    return Padding(
      padding: const EdgeInsets.only(top: 11, bottom: 36, left: 58, right: 58),
      child: SizedBox(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: CenterTextBuilder()
          .key(const Key('login_message'))
          .text(loginState.viewState.fold(
            (failure) {
              if (failure is LoginMissUrlAction) {
                return AppLocalizations.of(context).requiredUrl;
              } else if (failure is LoginMissUsernameAction) {
                return AppLocalizations.of(context).requiredEmail;
              } else if (failure is LoginMissPasswordAction) {
                return AppLocalizations.of(context).requiredPassword;
              } else {
                return AppLocalizations.of(context).unknown_error_login_message;
              }
            },
            (success) {
              if (loginController.loginFormType.value == LoginFormType.credentialForm || kIsWeb) {
                return AppLocalizations.of(context).loginInputCredentialMessage;
              }
              return AppLocalizations.of(context).loginInputUrlMessage;
            }))
          .textStyle(TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: loginState.viewState.fold(
              (failure) => AppColor.textFieldErrorBorderColor,
              (success) => AppColor.colorNameEmail)))
          .build()
      )
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return Container(
        margin:  const EdgeInsets.only(bottom: 16, left: 24, right: 24),
        width: responsiveUtils.getDeviceWidth(context),height: 48,
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
            child: Text(AppLocalizations.of(context).signIn,
                style: const TextStyle(fontSize: 16, color: Colors.white)
            ),
            onPressed: () {
              loginController.handleLoginPressed();
            }
        )
    );
  }

  Widget buildInputCredentialForm(BuildContext context) {
    return Column(
      children: [
        buildUserNameInput(context),
        buildPasswordInput(context)
      ],
    );
  }

  Widget buildUserNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 24, left: 24),
      child: Container(
        child: (TextFieldBuilder()..key(const Key('login_username_input'))
            ..onChange((value) => loginController.setUserNameText(value))
            ..textInputAction(TextInputAction.next)
            ..keyboardType(TextInputType.emailAddress)
            ..textDecoration((LoginInputDecorationBuilder()
                ..setLabelText(AppLocalizations.of(context).email)
                ..setHintText(AppLocalizations.of(context).email))
              .build()))
          .build()));
  }

  Widget buildPasswordInput(BuildContext context) {
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
}