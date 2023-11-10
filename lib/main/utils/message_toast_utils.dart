
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MessageToastUtils {

  static String? getMessageByException(BuildContext context, dynamic exception) {
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
    } else if (exception is ConnectionTimeout || exception is BadGateway || exception is SocketError) {
      return AppLocalizations.of(context).wrongUrlMessage;
    } else if (exception is BadCredentialsException) {
      return AppLocalizations.of(context).badCredentials;
    } else if (exception is ConnectionError) {
      return AppLocalizations.of(context).connectionError;
    } else if (exception is UnknownError && exception.message != null) {
      return '[${exception.code ?? ''}] ${exception.message}';
    } else if (exception is NotFoundSessionException) {
      return AppLocalizations.of(context).notFoundSession;
    } else {
      return null;
    }
  }
}
