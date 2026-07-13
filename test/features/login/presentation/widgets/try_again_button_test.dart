import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/try_again_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

AppLocalizations? _appLocalizations;

class _MinifiedLikeException implements Exception {
  @override
  String toString() => "Instance of 'minified:aHb'";
}

void _runAsWeb() {
  PlatformInfo.isTestingForWeb = true;
  addTearDown(() => PlatformInfo.isTestingForWeb = false);
}

Widget _makeTestableWidget(Either<Failure, Success> viewState) {
  return GetMaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: Scaffold(
      body: Builder(builder: (context) {
        _appLocalizations = AppLocalizations.of(context);
        return TryAgainButton(
          onRetry: () {},
          responsiveUtils: ResponsiveUtils(),
          viewState: viewState,
        );
      }),
    ),
  );
}

Future<void> _pump(WidgetTester tester, Either<Failure, Success> viewState) async {
  await tester.pumpWidget(_makeTestableWidget(viewState));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<ImagePaths>(ImagePaths());
    Get.put<AppToast>(AppToast());
    Get.put<ToastManager>(
      ToastManager(
        Get.find<AppToast>(),
        Get.find<ImagePaths>(),
      ),
    );
  });

  tearDown(Get.reset);

  testWidgets(
      'WHEN web silent re-auth has no visible message THEN Try again is hidden',
      (tester) async {
    _runAsWeb();

    await _pump(tester, Left(GetTokenOIDCFailure(
      _MinifiedLikeException(),
      ssoConfirmed: true,
    )));

    expect(find.text(_appLocalizations!.tryAgain), findsNothing);
  });

  testWidgets(
      'WHEN non-web silent re-auth has no visible message THEN Try again is visible',
      (tester) async {
    PlatformInfo.isTestingForWeb = false;

    await _pump(tester, Left(GetTokenOIDCFailure(
      _MinifiedLikeException(),
      ssoConfirmed: true,
    )));

    expect(find.text(_appLocalizations!.tryAgain), findsOneWidget);
  });
}
