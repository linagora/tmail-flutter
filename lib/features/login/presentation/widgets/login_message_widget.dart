
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/dns_lookup_to_get_jmap_url_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

class LoginMessageWidget extends StatelessWidget {

  static const double _loginTextFieldWidthSmallScreen = 280.0;
  static const double _loginTextFieldWidthLargeScreen = 320.0;

  final LoginFormType formType;
  final Either<Failure, Success> viewState;

  final ToastManager? _toastManager = getBinding<ToastManager>();

  LoginMessageWidget({
    super.key,
    required this.formType,
    required this.viewState
  });

  @override
  Widget build(BuildContext context) {
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
            (failure) {
              if (failure is FeatureFailure && failure.exception is NoNetworkError) {
                return AppLocalizations.of(context).youAreOffline;
              }

              if (failure is GetOIDCConfigurationFailure) {
                return AppLocalizations.of(context).canNotVerifySSOConfiguration;
              } else if (failure is DNSLookupToGetJmapUrlFailure) {
                return AppLocalizations.of(context).dnsLookupLoginMessage;
              } else if (failure is GetTokenOIDCFailure && failure.exception is NoSuitableBrowserForOIDCException) {
                return AppLocalizations.of(context).noSuitableBrowserForOIDC;
              } else if (failure is FeatureFailure) {
                return _toastManager?.getMessageByException(
                  context,
                  failure.exception,
                  useDefaultMessage: true,
                ) ?? AppLocalizations.of(context).unknownError;
              } else {
                return AppLocalizations.of(context).unknownError;
              }
            },
            (success) {
              if (formType == LoginFormType.credentialForm) {
                return AppLocalizations.of(context).loginInputCredentialMessage;
              } else if (formType == LoginFormType.dnsLookupForm) {
                return AppLocalizations.of(context).dnsLookupLoginMessage;
              } else if (formType == LoginFormType.passwordForm) {
                return AppLocalizations.of(context).enterYourPasswordToSignIn;
              } else if (formType == LoginFormType.baseUrlForm) {
                return AppLocalizations.of(context).loginInputUrlMessage;
              } else {
                return '';
              }
            }
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
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
