import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../fixtures/garbage_collection_fixtures.dart';
import '../../base/base_controller_test.mocks.dart';

Future<void> _pumpHostApp(WidgetTester tester) async {
  await tester.pumpWidget(
    const GetMaterialApp(
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: SizedBox()),
    ),
  );
  await tester.pumpAndSettle();
}

/// A share cold start opens the composer before the label bindings are injected.
Future<LabelController> _injectBindingsUnderClosedComposer(
  WidgetTester tester,
) async {
  final labelController = Get.put(LabelController(), permanent: true);
  Get.to(() => const Scaffold(body: Text('composer')));
  await tester.pumpAndSettle();
  labelController.injectLabelsBindings();

  Get.back();
  await tester.pumpAndSettle();
  return labelController;
}

Future<WeakReference<LabelRepository>> _openAndCloseCreateLabelModal(
  WidgetTester tester,
  LabelController labelController,
) async {
  labelController.openCreateNewLabelModal(accountId: AccountId(Id('a')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('create_new_label_modal')), findsOneWidget);
  final repository = WeakReference(Get.find<LabelRepository>());

  Get.back();
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  setUp(() {
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(MockAuthorizationInterceptors());
    Get.put<AuthorizationInterceptors>(
      MockAuthorizationInterceptors(),
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(ImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());
    Get.put(HttpClient(Dio()));
    Get.put(const Uuid());
    Get.put(RemoteExceptionThrower());
    Get.put(VerifyNameInteractor());
  });

  tearDown(Get.reset);

  testWidgets(
    'create label modal renders after the route that first injected the label bindings is closed',
    (tester) async {
      await _pumpHostApp(tester);
      final labelController = await _injectBindingsUnderClosedComposer(tester);

      labelController.openCreateNewLabelModal(accountId: AccountId(Id('a')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('create_new_label_modal')), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    },
  );

  testWidgets(
    'label repository rebuilt for each create label modal is released after the modal closes',
    (tester) async {
      await _pumpHostApp(tester);
      final labelController = await _injectBindingsUnderClosedComposer(tester);

      final repositories = <WeakReference<LabelRepository>>[];
      for (var attempt = 0; attempt < 3; attempt++) {
        repositories.add(
          await _openAndCloseCreateLabelModal(tester, labelController),
        );
      }
      await tester.runAsync(GarbageCollectionFixtures.forceGarbageCollection);

      expect(repositories.where((repository) => repository.target != null), isEmpty);
    },
  );
}
