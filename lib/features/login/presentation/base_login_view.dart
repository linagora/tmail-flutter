import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/recent_item_tile_widget.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
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

  final FocusNode passFocusNode = FocusNode();

  Widget buildLoginMessage(BuildContext context, LoginState loginState) {
    return Padding(
      padding: const EdgeInsets.only(top: 11, bottom: 36, left: 58, right: 58),
      child: SizedBox(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: Text(
          loginState.viewState.fold(
            (failure) {
              if (failure is LoginMissUrlAction) {
                return AppLocalizations.of(context).requiredUrl;
              } else if (failure is LoginMissUsernameAction) {
                return AppLocalizations.of(context).requiredEmail;
              } else if (failure is LoginMissPasswordAction) {
                return AppLocalizations.of(context).requiredPassword;
              } else if (failure is LoginSSONotAvailableAction) {
                return AppLocalizations.of(context).ssoNotAvailable;
              } else if (failure is GetOIDCConfigurationFailure
                  || failure is LoginCanNotVerifySSOConfigurationAction) {
                return AppLocalizations.of(context).canNotVerifySSOConfiguration;
              } else if (failure is GetTokenOIDCFailure || failure is LoginCanNotGetTokenAction) {
                return AppLocalizations.of(context).canNotGetToken;
              } else {
                return AppLocalizations.of(context).unknownError;
              }
            },
            (success) {
              if (loginController.loginFormType.value == LoginFormType.credentialForm) {
                return AppLocalizations.of(context).loginInputCredentialMessage;
              } else if (loginController.loginFormType.value == LoginFormType.ssoForm) {
                return AppLocalizations.of(context).loginInputSSOMessage;
              }
              return AppLocalizations.of(context).loginInputUrlMessage;
            }),
        key: const Key('login_message'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: loginState.viewState.fold(
            (failure) => AppColor.textFieldErrorBorderColor,
            (success) => AppColor.colorNameEmail)),
      ))
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
        onPressed: loginController.handleLoginPressed,
        child: Text(
          AppLocalizations.of(context).signIn,
          style: const TextStyle(fontSize: 16, color: Colors.white)
        )
      )
    );
  }

  Widget buildInputCredentialForm(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          buildUserNameInput(context),
          buildPasswordInput(context)
        ],
      ),
    );
  }

  Widget buildUserNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, right: 24, left: 24),
      child: TypeAheadFormFieldBuilder<RecentLoginUsername>(
        key: const Key('login_username_input'),
        controller: loginController.usernameInputController,
        onTextChange: loginController.setUserNameText,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        keyboardType: TextInputType.emailAddress,
        decoration: (LoginInputDecorationBuilder()
          ..setLabelText(AppLocalizations.of(context).email)
          ..setHintText(AppLocalizations.of(context).email))
          .build(),
        debounceDuration: const Duration(milliseconds: 300),
        suggestionsCallback: loginController.getAllRecentLoginUsernameAction,
        itemBuilder: (context, loginUsername) => RecentItemTileWidget(loginUsername, imagePath: imagePaths),
        onSuggestionSelected: (recentUsername) {
          loginController.setUsername(recentUsername.username);
          passFocusNode.requestFocus();
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(borderRadius: BorderRadius.all(Radius.circular(14))),
        noItemsFoundBuilder: (context) => const SizedBox(),
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
      )
    );
  }

  Widget buildPasswordInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, right: 24, left: 24),
      child: Container(
        child: (LoginTextInputBuilder(
            context,
            imagePaths,
            autocorrect: false,
            autofillHints: [AutofillHints.password]
          )
          ..setOnSubmitted((value) => loginController.handleLoginPressed())
          ..passwordInput(true)
          ..key(const Key('login_password_input'))
          ..obscureText(true)
          ..onChange(loginController.setPasswordText)
          ..textInputAction(TextInputAction.done)
          ..hintText(AppLocalizations.of(context).password)
          ..setFocusNode(passFocusNode))
        .build()));
  }

  Widget buildLoadingCircularProgress() {
    return const SizedBox(
        key: Key('login_loading_icon'),
        width: 40,
        height: 40,
        child: CircularProgressIndicator(color: AppColor.primaryColor));
  }
}