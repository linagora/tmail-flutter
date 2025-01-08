import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/either_view_state_extension.dart';
import 'package:core/utils/string_convert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:rich_text_composer/views/commons/logger.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/auto_sign_in_via_deep_link_interactor.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_callback_action_define.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin OpenAppDeepLinkHandlerMixin on MessageDialogActionMixin {
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
      logError('DeepLinksManager::parseOpenAppDeepLink:Exception = $e');
      return null;
    }
  }

  void handleOpenAppDeepLinks({
    required OpenAppDeepLinkData openAppDeepLinkData,
    OnDeepLinkFailureCallback? onFailureCallback,
    OnAutoSignInViaDeepLinkSuccessCallback? onAutoSignInSuccessCallback,
    OnDeepLinkConfirmLogoutCallback<OpenAppDeepLinkData>? onConfirmLogoutCallback,
    UserName? username,
    bool isSignedIn = true,
  }) {
    if (!openAppDeepLinkData.isValidAuthentication()) {
      onFailureCallback?.call();
      return;
    }

    if (isSignedIn) {
      if (currentContext == null || username == null) {
        onFailureCallback?.call();
        return;
      }

      if (openAppDeepLinkData.isLoggedInWith(username.value)) {
        onFailureCallback?.call();
        return;
      }

      _showConfirmDialogSwitchAccount(
        context: currentContext!,
        currentUsername: username.value,
        newUsername: openAppDeepLinkData.username,
        onConfirmAction: () => onConfirmLogoutCallback?.call(openAppDeepLinkData),
        onCancelAction: () => onFailureCallback?.call()
      );
    } else {
      autoSignInViaDeepLink(
        openAppDeepLinkData: openAppDeepLinkData,
        onAutoSignInSuccessCallback: (viewState) => onAutoSignInSuccessCallback?.call(viewState),
        onFailureCallback: () => onFailureCallback?.call(),
      );
    }
  }

  Future<void> autoSignInViaDeepLink({
    required OpenAppDeepLinkData openAppDeepLinkData,
    required OnAutoSignInViaDeepLinkSuccessCallback onAutoSignInSuccessCallback,
    required OnDeepLinkFailureCallback onFailureCallback,
  }) async {
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
      logError('DeepLinksManager::_autoSignInViaDeepLink:Exception = $e');
      onFailureCallback.call();
    }
  }

  void _showConfirmDialogSwitchAccount({
    required BuildContext context,
    required String currentUsername,
    required String newUsername,
    required Function onConfirmAction,
    required Function onCancelAction,
  }) {
    final appLocalizations = AppLocalizations.of(context);

    showConfirmDialogAction(
      context,
      '',
      appLocalizations.yes,
      title: appLocalizations.switchAccountConfirmation,
      alignCenter: true,
      outsideDismissible: false,
      titleActionButtonMaxLines: 1,
      messageStyle: const TextStyle(
        color: AppColor.colorTextBody,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      listTextSpan: [
        TextSpan(text: appLocalizations.youAreCurrentlyLoggedInWith),
        TextSpan(
          text: ' $currentUsername',
          style: const TextStyle(
            color: AppColor.colorTextBody,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const TextSpan(text: '. '),
        TextSpan(text: appLocalizations.doYouWantToLogOutAndSwitchTo),
        TextSpan(
          text: ' $newUsername',
          style: const TextStyle(
            color: AppColor.colorTextBody,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const TextSpan(text: '?'),
      ],
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction,
    );
  }
}
