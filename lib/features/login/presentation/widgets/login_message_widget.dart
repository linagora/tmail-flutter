
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_failure_message_resolver.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

class LoginMessageWidget extends StatelessWidget {

  static const double _loginTextFieldWidthSmallScreen = 280.0;
  static const double _loginTextFieldWidthLargeScreen = 320.0;

  final LoginFormType formType;
  final Either<Failure, Success> viewState;

  final LoginFailureMessageResolver _failureMessageResolver;

  LoginMessageWidget({
    super.key,
    required this.formType,
    required this.viewState
  }) : _failureMessageResolver = LoginFailureMessageResolver(
        getBinding<ToastManager>(),
      );

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 11,
        bottom: 36,
        start: 58,
        end: 58
      ),
      child: SizedBox(
        width: context.width < ResponsiveUtils.minTabletWidth
          ? _loginTextFieldWidthSmallScreen
          : _loginTextFieldWidthLargeScreen,
        child: Text(
          viewState.fold(
            (failure) => _failureMessageResolver.resolve(
              appLocalizations,
              failure,
            ),
            (success) {
              if (formType == LoginFormType.credentialForm) {
                return appLocalizations.loginInputCredentialMessage;
              } else if (formType == LoginFormType.dnsLookupForm) {
                return appLocalizations.dnsLookupLoginMessage;
              } else if (formType == LoginFormType.passwordForm) {
                return appLocalizations.enterYourPasswordToSignIn;
              } else if (formType == LoginFormType.baseUrlForm) {
                return appLocalizations.loginInputUrlMessage;
              } else {
                return '';
              }
            }
          ),
          textAlign: TextAlign.center,
          style: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: viewState.fold(
              (failure) => AppColor.textFieldErrorBorderColor,
              (success) => AppColor.colorNameEmail
            )
          ),
        )
      )
    );
  }
}
