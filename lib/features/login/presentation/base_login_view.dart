import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/recent_item_tile_widget.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_text_input_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract class BaseLoginView extends GetWidget<LoginController> {
  BaseLoginView({Key? key}) : super(key: key);

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  Widget buildLoginMessage(BuildContext context, Either<Failure, Success> viewState) {
    return Padding(
      padding: const EdgeInsets.only(top: 11, bottom: 36, left: 58, right: 58),
      child: SizedBox(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: Text(
          viewState.fold(
            (failure) {
              if (failure is CheckOIDCIsAvailableFailure) {
                return _getMessageFailure(context, failure.exception);
              } else if (failure is AuthenticationUserFailure) {
                return _getMessageFailure(context, failure.exception);
              } else if (failure is GetOIDCIsAvailableFailure) {
                return _getMessageFailure(context, failure.exception);
              } else if (failure is GetTokenOIDCFailure) {
                return _getMessageFailure(context, failure.exception);
              } else if (failure is AuthenticateOidcOnBrowserFailure) {
                return _getMessageFailure(context, failure.exception);
              } else if (failure is GetOIDCConfigurationFailure) {
                return AppLocalizations.of(context).canNotVerifySSOConfiguration;
              } else {
                return AppLocalizations.of(context).unknownError;
              }
            },
            (success) {
              if (controller.loginFormType.value == LoginFormType.credentialForm) {
                return AppLocalizations.of(context).loginInputCredentialMessage;
              } else if (controller.loginFormType.value == LoginFormType.ssoForm) {
                return AppLocalizations.of(context).loginInputSSOMessage;
              }
              return AppLocalizations.of(context).loginInputUrlMessage;
            }),
        key: const Key('login_message'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: viewState.fold(
            (failure) => AppColor.textFieldErrorBorderColor,
            (success) => AppColor.colorNameEmail)),
      ))
    );
  }

  String _getMessageFailure(BuildContext context, dynamic exception) {
    if (exception is CanNotFoundBaseUrl) {
      return AppLocalizations.of(context).requiredUrl;
    } else if (exception is CanNotFoundUserName) {
      return AppLocalizations.of(context).requiredEmail;
    } else if (exception is CanNotFoundPassword) {
      return AppLocalizations.of(context).requiredPassword;
    } else if (exception is CanNotFoundOIDCLinks) {
      return AppLocalizations.of(context).ssoNotAvailable;
    }  else if (exception is CanNotFoundToken) {
      return AppLocalizations.of(context).canNotGetToken;
    } else {
      return '';
    }
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
        onPressed: controller.handleLoginPressed,
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
        controller: controller.usernameInputController,
        onTextChange: controller.setUserNameText,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        keyboardType: TextInputType.emailAddress,
        decoration: (LoginInputDecorationBuilder()
          ..setLabelText(AppLocalizations.of(context).email)
          ..setHintText(AppLocalizations.of(context).email))
          .build(),
        debounceDuration: const Duration(milliseconds: 300),
        suggestionsCallback: controller.getAllRecentLoginUsernameAction,
        itemBuilder: (context, loginUsername) => RecentItemTileWidget(loginUsername, imagePath: imagePaths),
        onSuggestionSelected: (recentUsername) {
          controller.setUsername(recentUsername.username);
          controller.passFocusNode.requestFocus();
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
          ..setOnSubmitted((value) => controller.handleLoginPressed())
          ..passwordInput(true)
          ..key(const Key('login_password_input'))
          ..obscureText(true)
          ..onChange(controller.setPasswordText)
          ..textInputAction(TextInputAction.done)
          ..hintText(AppLocalizations.of(context).password)
          ..setFocusNode(controller.passFocusNode))
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