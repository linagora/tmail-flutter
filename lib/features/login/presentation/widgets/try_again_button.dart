import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/login/presentation/extensions/login_failure_extensions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

class TryAgainButton extends StatelessWidget {
  const TryAgainButton({
    super.key,
    required this.onRetry,
    required this.responsiveUtils,
    this.viewState,
  });

  final VoidCallback onRetry;
  final ResponsiveUtils responsiveUtils;
  final Either<Failure, Success>? viewState;

  @override
  Widget build(BuildContext context) {
    if (_shouldHideRetry(context)) {
      return const SizedBox.shrink();
    }

    return TMailButtonWidget.fromText(
      text: AppLocalizations.of(context).tryAgain,
      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 16,
        color: Colors.white,
      ),
      backgroundColor: AppColor.primaryColor,
      onTapActionCallback: onRetry,
      borderRadius: 10,
      margin: const EdgeInsetsDirectional.only(bottom: 16, start: 24, end: 24),
      width: responsiveUtils.getDeviceWidth(context),
      textAlign: TextAlign.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  bool _shouldHideRetry(BuildContext context) {
    return viewState?.fold(
          (failure) => failure.shouldHideRetryDuringSilentReAuthentication(
            toastManager: getBinding<ToastManager>(),
            appLocalizations: AppLocalizations.of(context),
          ),
          (success) => false,
        ) ??
        false;
  }
}