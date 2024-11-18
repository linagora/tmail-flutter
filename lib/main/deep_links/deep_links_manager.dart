import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:rxdart/subjects.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/auto_sign_in_via_deep_link_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_action_define.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class DeepLinksManager with MessageDialogActionMixin {

  final AutoSignInViaDeepLinkInteractor _autoSignInViaDeepLinkInteractor;

  BehaviorSubject<DeepLinkData?> _pendingDeepLinkData = BehaviorSubject.seeded(null);

  BehaviorSubject<DeepLinkData?> get pendingDeepLinkData => _pendingDeepLinkData;

  StreamSubscription<Uri>? _deepLinkStreamSubscription;

  DeepLinksManager(this._autoSignInViaDeepLinkInteractor);

  Future<DeepLinkData?> getDeepLinkData() async {
    final uriLink = await AppLinks().getInitialLink();
    log('DeepLinksManager::getDeepLinkData:uriLink = $uriLink');
    if (uriLink == null) return null;

    final deepLinkData = parseDeepLink(uriLink.toString());
    return deepLinkData;
  }

  void registerDeepLinkStreamListener() {
    _deepLinkStreamSubscription =
        AppLinks().uriLinkStream.listen(_handleUriLinkStream);
  }

  void _handleUriLinkStream(Uri uri) {
    final deepLinkData = parseDeepLink(uri.toString());
    log('DeepLinksManager::_handleUriLinkStream:DeepLinkData = $deepLinkData');
    setPendingDeepLinkData(deepLinkData);
  }

  void setPendingDeepLinkData(DeepLinkData? deepLinkData) {
    clearPendingDeepLinkData();
    _pendingDeepLinkData.add(deepLinkData);
  }

  void clearPendingDeepLinkData() {
    if(_pendingDeepLinkData.isClosed) {
      _pendingDeepLinkData = BehaviorSubject.seeded(null);
    } else {
      _pendingDeepLinkData.add(null);
    }
  }

  DeepLinkData? parseDeepLink(String url) {
    try {
      final updatedUrl = url.replaceFirst(
        OIDCConstant.twakeWorkplaceUrlScheme,
        'https',
      );
      final uri = Uri.parse(updatedUrl);
      log('DeepLinksManager::parseDeepLink:uri = $uri');
      final action = uri.host;
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];
      final idToken = uri.queryParameters['id_token'];
      final expiresInStr = uri.queryParameters['expires_in'];
      final username = uri.queryParameters['username'];

      final expiresIn = expiresInStr != null
        ? int.tryParse(expiresInStr)
        : null;

      return DeepLinkData(
        action: action,
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: idToken,
        expiresIn: expiresIn,
        username: username,
      );
    } catch (e) {
      logError('DeepLinksManager::parseDeepLink:Exception = $e');
      return null;
    }
  }

  Future<void> handleDeepLinksWhenAppOnForegroundNotSignedIn({
    required DeepLinkData deepLinkData,
    required OnDeepLinkSuccessCallback onSuccessCallback,
    OnDeepLinkFailureCallback? onFailureCallback,
  }) async {
    log('DeepLinksManager::handleDeepLinksWhenAppOnForegroundNotSignedIn:DeepLinkData = $deepLinkData');
    if (deepLinkData.action.toLowerCase() == AppConfig.openAppHostDeepLink.toLowerCase()) {
      _handleOpenApp(
        deepLinkData: deepLinkData,
        onFailureCallback: onFailureCallback,
        onSuccessCallback: onSuccessCallback,
      );
    } else {
      onFailureCallback?.call();
    }
  }

  Future<void> handleDeepLinksWhenAppTerminatedNotSignedIn({
    required OnDeepLinkSuccessCallback onSuccessCallback,
    required OnDeepLinkFailureCallback onFailureCallback,
  }) async {
    final deepLinkData = await getDeepLinkData();
    log('DeepLinksManager::handleDeepLinksWhenAppTerminatedNotSignedIn:DeepLinkData = $deepLinkData');
    if (deepLinkData == null) {
      onFailureCallback();
      return;
    }

    if (deepLinkData.action.toLowerCase() == AppConfig.openAppHostDeepLink.toLowerCase()) {
      _handleOpenApp(
        deepLinkData: deepLinkData,
        onFailureCallback: onFailureCallback,
        onSuccessCallback: onSuccessCallback,
      );
    } else {
      onFailureCallback();
    }
  }

  Future<void> handleDeepLinksWhenAppTerminatedSignedIn({
    required String? username,
    required OnDeepLinkConfirmLogoutCallback onConfirmCallback,
    required OnDeepLinkFailureCallback onFailureCallback,
  }) async {
    final deepLinkData = await getDeepLinkData();
    log('DeepLinksManager::handleDeepLinksWhenAppTerminatedSignedIn:DeepLinkData = $deepLinkData');
    if (deepLinkData == null) {
      onFailureCallback();
      return;
    }

    if (deepLinkData.action.toLowerCase() == AppConfig.openAppHostDeepLink.toLowerCase()) {
      if (deepLinkData.username?.isNotEmpty != true || username?.isNotEmpty != true) {
        onFailureCallback();
        return;
      }

      if (deepLinkData.username == username || currentContext == null) {
        onFailureCallback();
      } else {
        _showConfirmDialogSwitchAccount(
          context: currentContext!,
          username: username!,
          onConfirmAction: () => onConfirmCallback(deepLinkData),
          onCancelAction: onFailureCallback,
        );
      }
    } else {
      onFailureCallback();
    }
  }

  void _handleOpenApp({
    required DeepLinkData deepLinkData,
    required OnDeepLinkSuccessCallback onSuccessCallback,
    OnDeepLinkFailureCallback? onFailureCallback,
  }) {
    autoSignInViaDeepLink(
      deepLinkData: deepLinkData,
      onFailureCallback: onFailureCallback,
      onSuccessCallback: onSuccessCallback,
    );
  }

  Future<void> autoSignInViaDeepLink({
    required DeepLinkData deepLinkData,
    required OnDeepLinkSuccessCallback onSuccessCallback,
    OnDeepLinkFailureCallback? onFailureCallback,
  }) async {
    try {
      if (deepLinkData.isValidToken()) {
        final autoSignInViewState = await _autoSignInViaDeepLinkInteractor.execute(
          baseUri: Uri.parse(AppConfig.saasJmapServerUrl),
          tokenOIDC: deepLinkData.getTokenOIDC(),
          oidcConfiguration: OIDCConfiguration(
            authority: AppConfig.saasRegistrationUrl,
            clientId: OIDCConstant.clientId,
            scopes: AppConfig.oidcScopes,
          ),
        ).last;

        autoSignInViewState.fold(
          (failure) => onFailureCallback?.call(),
          (success) {
            if (success is AutoSignInViaDeepLinkSuccess) {
              onSuccessCallback(success);
            } else {
              onFailureCallback?.call();
            }
          },
        );
      } else {
        onFailureCallback?.call();
      }
    } catch (e) {
      logError('DeepLinksManager::_autoSignInViaDeepLink:Exception = $e');
      onFailureCallback?.call();
    }
  }

  void _showConfirmDialogSwitchAccount({
    required BuildContext context,
    required String username,
    required Function onConfirmAction,
    required Function onCancelAction,
  }) {
    final appLocalizations = AppLocalizations.of(context);

    showConfirmDialogAction(
      context,
      '',
      appLocalizations.yesLogout,
      title: appLocalizations.logoutConfirmation,
      alignCenter: true,
      outsideDismissible: false,
      titleActionButtonMaxLines: 1,
      titlePadding: const EdgeInsetsDirectional.only(start: 24, top: 24, end: 24, bottom: 12),
      messageStyle: const TextStyle(
        color: AppColor.colorTextBody,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      listTextSpan: [
        TextSpan(text: appLocalizations.messageConfirmationLogout),
        TextSpan(
          text: ' $username',
          style: const TextStyle(
            color: AppColor.colorTextBody,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const TextSpan(text: ' ?'),
      ],
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction,
    );
  }

  void dispose() {
    _deepLinkStreamSubscription?.cancel();
    _pendingDeepLinkData.close();
  }
}