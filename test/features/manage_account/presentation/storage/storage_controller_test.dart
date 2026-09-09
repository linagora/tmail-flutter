import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/quotas/data_types.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/saas/saas_account_capability.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/widgets/upgrade_storage_widget.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/domain/state/get_paywall_url_state.dart';
import 'package:tmail_ui_user/features/paywall/domain/usecases/get_paywall_url_interactor.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'storage_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<ManageAccountDashBoardController>(),
  MockSpec<GetPaywallUrlInteractor>(),
  MockSpec<PaywallController>(),
  MockSpec<StorageController>(),
])
void main() {
  const jmapUrl = 'https://domain.tld/jmap';
  final accountId = AccountId(Id('account-id'));
  late MockDynamicUrlInterceptors dynamicUrlInterceptors;

  Session premiumSession({bool isPaying = false, bool canUpgrade = true}) {
    final saasCapability = SaaSAccountCapability(
      isPaying: isPaying,
      canUpgrade: canUpgrade,
    );
    final uri = Uri.parse(jmapUrl);
    return Session(
      {SessionExtensions.linagoraSaaSCapability: saasCapability},
      {
        accountId: Account(
          AccountName('alice@domain.tld'),
          true,
          false,
          {SessionExtensions.linagoraSaaSCapability: saasCapability},
        ),
      },
      {SessionExtensions.linagoraSaaSCapability: accountId},
      UserName('alice@domain.tld'),
      uri,
      uri,
      uri,
      uri,
      jmap.State('state'),
    );
  }

  void registerBaseControllerDependencies() {
    final authorizationInterceptors = MockAuthorizationInterceptors();
    dynamicUrlInterceptors = MockDynamicUrlInterceptors();

    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(dynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(
      MockDeleteAuthorityOidcInteractor(),
    );
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(ImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(MockUuid());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());

    when(dynamicUrlInterceptors.jmapUrl).thenReturn(jmapUrl);
  }

  setUp(() {
    Get.testMode = true;
    registerBaseControllerDependencies();
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
    Get.reset();
  });

  group('StorageController paywall availability', () {
    late MockManageAccountDashBoardController dashboardController;
    late MockGetPaywallUrlInteractor getPaywallUrlInteractor;
    late MockPaywallController paywallController;
    late Rxn<AccountId> currentAccountId;
    late RxString ownEmailAddress;
    Session? currentSession;
    StorageController? storageController;
    var controllerClosed = false;

    void arrangePaywallState(Stream<Either<Failure, Success>> stream) {
      when(getPaywallUrlInteractor.execute(jmapUrl)).thenAnswer((_) => stream);
    }

    void createController({bool isWeb = true}) {
      PlatformInfo.isTestingForWeb = isWeb;
      storageController = StorageController(
        dashBoardController: dashboardController,
        getPaywallUrlInteractor: getPaywallUrlInteractor,
      );
      storageController!.onInit();
    }

    setUp(() {
      dashboardController = MockManageAccountDashBoardController();
      getPaywallUrlInteractor = MockGetPaywallUrlInteractor();
      paywallController = MockPaywallController();
      currentAccountId = Rxn(accountId);
      ownEmailAddress = 'alice@domain.tld'.obs;
      currentSession = premiumSession();
      controllerClosed = false;

      when(dashboardController.accountId).thenReturn(currentAccountId);
      when(dashboardController.sessionCurrent).thenAnswer((_) => currentSession);
      when(dashboardController.ownEmailAddress).thenReturn(ownEmailAddress);
      when(dashboardController.paywallController).thenReturn(paywallController);
      when(paywallController.ownEmailAddress)
          .thenReturn('alice@domain.tld');
      arrangePaywallState(Stream.value(Left(GetPaywallUrlFailure(Exception()))));
    });

    tearDown(() {
      if (!controllerClosed) storageController?.onClose();
    });

    test('hides upgrade when Workplace and ecosystem paywalls are unavailable',
        () async {
      createController();
      await pumpEventQueue();

      expect(storageController!.isUpgradeStorageDisabled(), isTrue);
      verify(getPaywallUrlInteractor.execute(jmapUrl)).called(1);
    });

    test('shows upgrade when a qualified ecosystem paywall is valid', () async {
      final pattern =
          PaywallUrlPattern('https://domain.tld/{localPart}/premium');
      arrangePaywallState(Stream.value(Right(GetPaywallUrlSuccess(
        pattern,
      ))));

      createController();
      await pumpEventQueue();

      expect(storageController!.isUpgradeStorageDisabled(), isFalse);
    });

    for (final unsafePattern in [
      'javascript:alert(1)',
      'http://domain.tld/premium',
      '/premium',
    ]) {
      test('hides upgrade for unsafe ecosystem pattern: $unsafePattern',
          () async {
        arrangePaywallState(Stream.value(Right(GetPaywallUrlSuccess(
          PaywallUrlPattern(unsafePattern),
        ))));

        createController();
        await pumpEventQueue();

        expect(storageController!.isUpgradeStorageDisabled(), isTrue);
      });
    }

    test('shows upgrade for a valid Workplace when ecosystem loading fails',
        () async {
      createController();
      await pumpEventQueue();

      expect(
        storageController!.isUpgradeStorageDisabled(
          workplaceFqdn: 'workplace.domain.tld',
        ),
        isFalse,
      );
    });

    test('hides upgrade when paywall controller is unavailable', () async {
      final pattern = PaywallUrlPattern('https://domain.tld/premium');
      when(dashboardController.paywallController).thenReturn(null);
      arrangePaywallState(Stream.value(Right(GetPaywallUrlSuccess(pattern))));
      createController();
      await pumpEventQueue();

      expect(storageController!.isUpgradeStorageDisabled(), isTrue);
    });

    test('keeps upgrade hidden for the highest subscription', () async {
      currentSession = premiumSession(isPaying: true, canUpgrade: false);
      createController();
      await pumpEventQueue();

      expect(
        storageController!.isUpgradeStorageDisabled(
          workplaceFqdn: 'workplace.domain.tld',
        ),
        isTrue,
      );
      verifyNever(getPaywallUrlInteractor.execute(any));
    });

    test('does not load ecosystem paywall for an ineligible account',
        () async {
      currentSession = premiumSession(canUpgrade: false);
      createController();
      await pumpEventQueue();

      expect(storageController!.isUpgradeStorageDisabled(), isTrue);
      verifyNever(getPaywallUrlInteractor.execute(any));
    });

    test('uses cached ecosystem paywall on click without another load',
        () async {
      final pattern = PaywallUrlPattern('https://domain.tld/premium');
      arrangePaywallState(Stream.value(Right(GetPaywallUrlSuccess(pattern))));
      createController();
      await pumpEventQueue();

      storageController!.onUpgradeStorage();

      verify(getPaywallUrlInteractor.execute(jmapUrl)).called(1);
      verify(paywallController.navigateToPaywall(
        workplaceFqdn: null,
        ecosystemPaywallUrlPattern: pattern,
      )).called(1);
    });

    test('ignores ecosystem response after controller is closed', () async {
      final stateController = StreamController<Either<Failure, Success>>();
      arrangePaywallState(stateController.stream);
      createController();
      await pumpEventQueue();

      storageController!.onClose();
      controllerClosed = true;
      stateController.add(Right(GetPaywallUrlSuccess(
        PaywallUrlPattern('https://domain.tld/premium'),
      )));
      await pumpEventQueue();

      expect(storageController!.isUpgradeStorageDisabled(), isTrue);
      expect(stateController.hasListener, isFalse);
      await stateController.close();
    });

    test('does not load paywall or change mobile navigation behavior', () async {
      createController(isWeb: false);
      await pumpEventQueue();

      verifyNever(getPaywallUrlInteractor.execute(any));

      storageController!.onUpgradeStorage();

      verify(paywallController.navigateToPaywall(
        workplaceFqdn: null,
        ecosystemPaywallUrlPattern: null,
      )).called(1);
    });
  });

  group('StorageView Workplace availability', () {
    late MockStorageController storageController;
    late MockManageAccountDashBoardController dashboardController;
    late MockResponsiveUtils responsiveUtils;
    late Rxn<Quota> octetsQuota;

    Future<ProviderContainer> pumpStorageView(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: GetMaterialApp(
            locale: LocalizationService.defaultLocale,
            supportedLocales: LocalizationService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: _TestStorageView(storageController),
          ),
        ),
      );
      await tester.pump();
      return ProviderScope.containerOf(
        tester.element(find.byType(_TestStorageView)),
      );
    }

    setUp(() {
      PlatformInfo.isTestingForWeb = true;
      storageController = MockStorageController();
      dashboardController = MockManageAccountDashBoardController();
      responsiveUtils = MockResponsiveUtils();
      octetsQuota = Rxn(_storageQuota(
        used: 1,
        hardLimit: 100,
        warnLimit: 90,
      ));

      when(storageController.dashBoardController)
          .thenReturn(dashboardController);
      when(storageController.responsiveUtils).thenReturn(responsiveUtils);
      when(storageController.imagePaths).thenReturn(ImagePaths());
      when(dashboardController.octetsQuota).thenReturn(octetsQuota);
      when(responsiveUtils.isMobile(any)).thenReturn(false);
      when(responsiveUtils.isDesktop(any)).thenReturn(true);
      when(responsiveUtils.isWebDesktop(any)).thenReturn(true);
      when(storageController.isUpgradeStorageDisabled(
        workplaceFqdn: null,
      )).thenReturn(true);
      when(storageController.isUpgradeStorageDisabled(
        workplaceFqdn: 'workplace.domain.tld',
      )).thenReturn(false);
    });

    testWidgets('shows and hides upgrade when Workplace changes after render',
        (tester) async {
      final container = await pumpStorageView(tester);

      expect(find.byType(UpgradeStorageWidget), findsNothing);

      container
          .read(workplaceFqdnProvider.notifier)
          .setFqdn('workplace.domain.tld');
      await tester.pump();

      expect(find.byType(UpgradeStorageWidget), findsOneWidget);

      await tester.tap(find.text('Upgrade storage'));
      verify(storageController.onUpgradeStorage(
        workplaceFqdn: 'workplace.domain.tld',
      )).called(1);

      container.read(workplaceFqdnProvider.notifier).setFqdn(null);
      await tester.pump();

      expect(find.byType(UpgradeStorageWidget), findsNothing);
    });

    testWidgets('does not evaluate or display premium upgrade on mobile',
        (tester) async {
      PlatformInfo.isTestingForWeb = false;
      when(responsiveUtils.isMobile(any)).thenReturn(true);
      when(responsiveUtils.isDesktop(any)).thenReturn(false);
      when(responsiveUtils.isWebDesktop(any)).thenReturn(false);

      await pumpStorageView(tester);

      expect(find.byType(UpgradeStorageWidget), findsNothing);
      verifyNever(storageController.isUpgradeStorageDisabled(
        workplaceFqdn: anyNamed('workplaceFqdn'),
      ));
    });
  });
}

class _TestStorageView extends StorageView {
  final StorageController testController;

  const _TestStorageView(this.testController);

  @override
  StorageController get controller => testController;
}

Quota _storageQuota({
  required int used,
  required int hardLimit,
  required int warnLimit,
}) => Quota(
  Id('storage'),
  ResourceType.octets,
  Scope.account,
  'Storage',
  used: UnsignedInt(used),
  hardLimit: UnsignedInt(hardLimit),
  warnLimit: UnsignedInt(warnLimit),
);
