import 'dart:async';

import 'package:core/presentation/extensions/either_view_state_extension.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/string_convert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/auto_sign_in_via_deep_link_interactor.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_account_verifier.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_callback_action_define.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin OpenAppDeepLinkHandlerMixin {
  /// Access tokens of sign-in links already handled in this process. The
  /// launch link stays readable for the whole process, so without this a
  /// link the user refused would prompt again each time Home is rebuilt.
  final Set<String> _handledSignInLinkTokens = {};

  bool _isSignInLinkInProgress = false;

  @visibleForTesting
  void resetHandledSignInLinks() {
    _handledSignInLinkTokens.clear();
    _isSignInLinkInProgress = false;
  }

  OpenAppDeepLinkData? parseOpenAppDeepLink(Uri uri) {
    try {
      final accessToken = uri.queryParameters['access_token'] ?? '';
      final refreshToken = uri.queryParameters['refresh_token'];
      final idToken = uri.queryParameters['id_token'];
      final expiresInStr = uri.queryParameters['expires_in'];
      final username = uri.queryParameters['username'];
      final registrationUrl = uri.queryParameters['registrationUrl'] ?? '';
      final jmapUrl = uri.queryParameters['jmapUrl'] ?? '';

      final expiresIn = expiresInStr != null
          ? int.tryParse(expiresInStr)
          : null;

      final usernameDecoded = username?.isNotEmpty == true
          ? StringConvert.decodeBase64ToString(username!)
          : username ?? '';

      return OpenAppDeepLinkData(
        registrationUrl: registrationUrl,
        jmapUrl: jmapUrl,
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: idToken,
        expiresIn: expiresIn,
        username: usernameDecoded,
      );
    } catch (e) {
      logWarning('DeepLinksManager::parseOpenAppDeepLink:Exception = $e');
      return null;
    }
  }

  /// Single entry point for `openApp` sign-in links, signed in or not.
  ///
  /// The link comes from any web page or email, so nothing is stored until the
  /// user confirmed the account the server reports for the link token.
  Future<void> handleOpenAppDeepLinks({
    required OpenAppDeepLinkData openAppDeepLinkData,
    OnDeepLinkFailureCallback? onFailureCallback,
    OnAutoSignInViaDeepLinkSuccessCallback? onAutoSignInSuccessCallback,
    OnDeepLinkConfirmLogoutCallback<OpenAppDeepLinkData>? onConfirmLogoutCallback,
    UserName? username,
    bool isSignedIn = true,
    bool Function()? isCallerActive,
  }) async {
    if (!openAppDeepLinkData.isValidAuthentication()) {
      _notifyLinkRefused(openAppDeepLinkData);
      onFailureCallback?.call();
      return;
    }

    if (!_claimSignInLink(openAppDeepLinkData)) {
      onFailureCallback?.call();
      return;
    }

    try {
      final accountUsername = await _withLoading(
        () => _verifyLinkAccount(openAppDeepLinkData),
      );
      // The caller may have closed while the server answered: none of its
      // callbacks may run then, on success or on failure.
      if (isCallerActive?.call() == false) {
        logWarning('DeepLinksManager::handleOpenAppDeepLinks: the caller closed while the link was verified');
        return;
      }

      if (accountUsername == null) {
        onFailureCallback?.call();
        return;
      }

      final context = currentContext;
      if (context == null || !context.mounted) {
        logWarning('DeepLinksManager::handleOpenAppDeepLinks: no context to confirm the sign-in link');
        onFailureCallback?.call();
        return;
      }
      // From here every outcome is the user's decision (or an account already
      // signed in): the link must not prompt again when Home re-reads it.
      _markSignInLinkHandled(openAppDeepLinkData);

      if (isSignedIn) {
        if (username == null ||
            OpenAppDeepLinkData.isSameUsername(accountUsername, username.value)) {
          onFailureCallback?.call();
          return;
        }

        await _showConfirmDialogSwitchAccount(
          context: context,
          currentUsername: username.value,
          newUsername: '${OpenAppDeepLinkData.displayUsernameOf(accountUsername)} (${openAppDeepLinkData.jmapHost})',
          onConfirmAction: () => onConfirmLogoutCallback?.call(openAppDeepLinkData),
          onCancelAction: () => onFailureCallback?.call(),
        );
      } else {
        await _showConfirmDialogSignIn(
          context,
          '${OpenAppDeepLinkData.displayUsernameOf(accountUsername)} (${openAppDeepLinkData.jmapHost})',
          onConfirmAction: () => autoSignInViaDeepLink(
            openAppDeepLinkData: openAppDeepLinkData,
            onAutoSignInSuccessCallback: (viewState) => onAutoSignInSuccessCallback?.call(viewState),
            onFailureCallback: () => onFailureCallback?.call(),
          ),
          onCancelAction: () => onFailureCallback?.call(),
        );
      }
    } finally {
      _isSignInLinkInProgress = false;
    }
  }

  /// Stores the link token as the session. Call it only after the user
  /// confirmed the account: from [handleOpenAppDeepLinks], or after the
  /// switch-account dialog and the logout that follows it.
  Future<void> autoSignInViaDeepLink({
    required OpenAppDeepLinkData openAppDeepLinkData,
    required OnAutoSignInViaDeepLinkSuccessCallback onAutoSignInSuccessCallback,
    required OnDeepLinkFailureCallback onFailureCallback,
  }) async {
    if (!openAppDeepLinkData.isValidAuthentication()) {
      logWarning('DeepLinksManager::autoSignInViaDeepLink: invalid or insecure deep link data');
      _notifyLinkRefused(openAppDeepLinkData);
      onFailureCallback.call();
      return;
    }

    try {
      final autoSignInViaDeepLinkInteractor = Get.find<AutoSignInViaDeepLinkInteractor>();

      final autoSignInViewState = await autoSignInViaDeepLinkInteractor.execute(
        baseUri: openAppDeepLinkData.baseUri,
        tokenOIDC: openAppDeepLinkData.tokenOIDC,
        oidcConfiguration: openAppDeepLinkData.oidcConfiguration,
      ).last;

      autoSignInViewState.foldSuccess<AutoSignInViaDeepLinkSuccess>(
        onSuccess: onAutoSignInSuccessCallback,
        onFailure: (failure) => onFailureCallback.call(),
      );
    } catch (e) {
      logWarning('DeepLinksManager::_autoSignInViaDeepLink:Exception = $e');
      onFailureCallback.call();
    }
  }

  Future<T> _withLoading<T>(Future<T> Function() action) async {
    final context = currentContext;
    final isLoadingShown = context != null && context.mounted;
    if (isLoadingShown) {
      SmartDialog.showLoading(msg: AppLocalizations.of(context).loadingPleaseWait);
    }
    try {
      return await action();
    } finally {
      if (isLoadingShown) await SmartDialog.dismiss(status: SmartStatus.loading);
    }
  }

  /// One sign-in link at a time, and a link already decided is not handled again.
  bool _claimSignInLink(OpenAppDeepLinkData openAppDeepLinkData) {
    if (_isSignInLinkInProgress) {
      logWarning('DeepLinksManager::_claimSignInLink: another sign-in link is being confirmed');
      return false;
    }
    if (_handledSignInLinkTokens.contains(openAppDeepLinkData.accessToken)) {
      log('DeepLinksManager::_claimSignInLink: sign-in link already handled');
      return false;
    }
    _isSignInLinkInProgress = true;
    return true;
  }

  /// A link is handled for good once the user decided, or once the server
  /// refused it for good. A transient failure leaves it retryable.
  void _markSignInLinkHandled(OpenAppDeepLinkData openAppDeepLinkData) {
    _handledSignInLinkTokens.add(openAppDeepLinkData.accessToken);
  }

  /// Returns the server account of the link token when it is the link
  /// username, or null when the server can't be reached or the token belongs
  /// to another account.
  Future<String?> _verifyLinkAccount(OpenAppDeepLinkData openAppDeepLinkData) async {
    try {
      final verifier = Get.find<DeepLinkAccountVerifier>();
      final accountUsername = await verifier.getAccountUsername(openAppDeepLinkData);
      if (OpenAppDeepLinkData.isSameUsername(accountUsername, openAppDeepLinkData.username)) {
        return accountUsername;
      }
      logWarning('DeepLinksManager::_verifyLinkAccount: the link username is not the account of its token');
      _markSignInLinkHandled(openAppDeepLinkData);
    } on DioException catch (e) {
      logWarning('DeepLinksManager::_verifyLinkAccount:DioException = ${e.type} ${e.response?.statusCode}');
      if (_isTokenRefused(e)) _markSignInLinkHandled(openAppDeepLinkData);
    } catch (e) {
      logWarning('DeepLinksManager::_verifyLinkAccount:Exception = $e');
    }

    _showErrorToast((localizations) => localizations.deepLinkAccountCannotBeVerified);
    return null;
  }

  /// The server answered that the token is not valid: retrying can't help.
  static bool _isTokenRefused(DioException exception) =>
      const {401, 403}.contains(exception.response?.statusCode);

  void _notifyLinkRefused(OpenAppDeepLinkData openAppDeepLinkData) {
    // A bare openapp link (web "Open in app" banner) only brings the app up.
    if (openAppDeepLinkData.accessToken.isEmpty) return;

    _showErrorToast((localizations) => localizations.deepLinkCannotBeOpened);
  }

  void _showErrorToast(String Function(AppLocalizations localizations) message) {
    final context = currentContext;
    final overlayContext = currentOverlayContext;
    if (context == null || overlayContext == null || !Get.isRegistered<AppToast>()) return;

    Get.find<AppToast>().showToastErrorMessage(
      overlayContext,
      message(AppLocalizations.of(context)),
    );
  }

  /// Runs exactly one of [onConfirmAction] / [onCancelAction]: closing the
  /// dialog any other way (back button, route change) counts as a cancel.
  Future<void> _awaitConfirmDialog({
    required Future<void> Function(VoidCallback onConfirm, VoidCallback onCancel) showDialog,
    required FutureOr<void> Function() onConfirmAction,
    required Function onCancelAction,
  }) async {
    var isDecided = false;
    Future<void>? confirmedAction;
    await showDialog(
      () {
        isDecided = true;
        confirmedAction = Future.sync(onConfirmAction);
      },
      () {
        isDecided = true;
        onCancelAction();
      },
    );
    if (!isDecided) onCancelAction();
    await confirmedAction;
  }

  Future<void> _showConfirmDialogSignIn(
    BuildContext context,
    String account, {
    required FutureOr<void> Function() onConfirmAction,
    required Function onCancelAction,
  }) {
    final appLocalizations = AppLocalizations.of(context);

    return _awaitConfirmDialog(
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction,
      showDialog: (onConfirm, onCancel) => MessageDialogActionManager().showConfirmDialogAction(
        context,
        '',
        appLocalizations.signIn,
        key: const Key('confirm_sign_in_with_link_dialog'),
        title: appLocalizations.signInWithLinkTitle,
        alignCenter: true,
        outsideDismissible: false,
        listTextSpan: [
          TextSpan(text: appLocalizations.signInWithLinkAccountPrefix),
          TextSpan(
            text: ' $account',
            style: ThemeUtils.textStyleM3BodyMedium1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: '. ${appLocalizations.signInWithLinkWarning}'),
        ],
        onConfirmAction: onConfirm,
        onCancelAction: onCancel,
      ),
    );
  }

  Future<void> _showConfirmDialogSwitchAccount({
    required BuildContext context,
    required String currentUsername,
    required String newUsername,
    required FutureOr<void> Function() onConfirmAction,
    required Function onCancelAction,
  }) {
    final appLocalizations = AppLocalizations.of(context);

    return _awaitConfirmDialog(
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction,
      showDialog: (onConfirm, onCancel) => MessageDialogActionManager().showConfirmDialogAction(
        context,
        '',
        appLocalizations.yes,
        title: appLocalizations.switchAccountConfirmation,
        alignCenter: true,
        outsideDismissible: false,
        listTextSpan: [
          TextSpan(text: appLocalizations.youAreCurrentlyLoggedInWith),
          TextSpan(
            text: ' $currentUsername',
            style: ThemeUtils.textStyleM3BodyMedium1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: '. '),
          TextSpan(text: appLocalizations.doYouWantToLogOutAndSwitchTo),
          TextSpan(
            text: ' $newUsername',
            style: ThemeUtils.textStyleM3BodyMedium1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: '?'),
        ],
        onConfirmAction: onConfirm,
        onCancelAction: onCancel,
      ),
    );
  }
}
