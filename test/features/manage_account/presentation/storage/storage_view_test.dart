import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
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
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/widgets/upgrade_storage_widget.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_launcher.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/recording_paywall_launcher.dart';

import 'storage_view_test.mocks.dart';

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
])
void main() {
  final accountId = AccountId(Id('account-id'));

  Session premiumSession() {
    final capability = SaaSAccountCapability(canUpgrade: true);
    final uri = Uri.parse('https://domain.tld/jmap');
    return Session(
      {SessionExtensions.linagoraSaaSCapability: capability},
      {
        accountId: Account(
          AccountName('alice@domain.tld'),
          true,
          false,
          {SessionExtensions.linagoraSaaSCapability: capability},
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
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
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
  }

  setUp(() {
    Get.testMode = true;
    registerBaseControllerDependencies();
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
    Get.reset();
  });

  group('StorageView premium CTA', () {
    late MockManageAccountDashBoardController dashboardController;
    late MockResponsiveUtils responsiveUtils;
    late Rxn<Quota> octetsQuota;
    late RecordingPaywallLauncher paywallLauncher;

    Future<ProviderContainer> pumpStorageView(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paywallLauncherProvider.overrideWithValue(paywallLauncher),
          ],
          child: const GetMaterialApp(
            locale: LocalizationService.defaultLocale,
            supportedLocales: LocalizationService.supportedLocales,
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: StorageView(),
          ),
        ),
      );
      await tester.pump();
      return ProviderScope.containerOf(
        tester.element(find.byType(StorageView)),
      );
    }

    setUp(() {
      PlatformInfo.isTestingForWeb = true;
      dashboardController = MockManageAccountDashBoardController();
      paywallLauncher = RecordingPaywallLauncher();
      responsiveUtils = MockResponsiveUtils();
      octetsQuota = Rxn(_storageQuota(
        used: 1,
        hardLimit: 100,
        warnLimit: 90,
      ));

      // GetX runs the lifecycle hooks when a controller is registered.
      when(dashboardController.onStart)
          .thenReturn(InternalFinalCallback<void>(callback: () {}));
      when(dashboardController.onDelete)
          .thenReturn(InternalFinalCallback<void>(callback: () {}));
      Get.put<ManageAccountDashBoardController>(dashboardController);
      Get.put<ResponsiveUtils>(responsiveUtils);
      when(dashboardController.octetsQuota).thenReturn(octetsQuota);
      when(dashboardController.sessionCurrent).thenReturn(premiumSession());
      when(dashboardController.accountId).thenReturn(Rxn(accountId));
      when(dashboardController.ownEmailAddress)
          .thenReturn('alice@domain.tld'.obs);
      when(dashboardController.dynamicUrlInterceptors).thenReturn(
        DynamicUrlInterceptors()..setJmapUrl('https://jmap.domain.tld'),
      );
      when(responsiveUtils.isMobile(any)).thenReturn(false);
      when(responsiveUtils.isDesktop(any)).thenReturn(true);
      when(responsiveUtils.isWebDesktop(any)).thenReturn(true);
    });

    testWidgets('reacts to Workplace FQDN changes and passes its Uri',
        (tester) async {
      final container = await pumpStorageView(tester);

      expect(find.byType(UpgradeStorageWidget), findsNothing);

      container
          .read(workplaceFqdnProvider.notifier)
          .setFqdn('workplace.domain.tld');
      await tester.pump();

      expect(find.byType(UpgradeStorageWidget), findsOneWidget);

      final appLocalizations = AppLocalizations.of(
        tester.element(find.byType(UpgradeStorageWidget)),
      );
      await tester.tap(find.text(appLocalizations.upgradeStorage));
      expect(paywallLauncher.launchCount, 1);
      expect(
        paywallLauncher.launchedDestination,
        Uri.parse('https://workplace.domain.tld/settings/premium'),
      );

      container.read(workplaceFqdnProvider.notifier).setFqdn(null);
      await tester.pump();

      expect(find.byType(UpgradeStorageWidget), findsNothing);
    });

    testWidgets('does not display premium upgrade on mobile', (tester) async {
      PlatformInfo.isTestingForWeb = false;
      when(responsiveUtils.isMobile(any)).thenReturn(true);
      when(responsiveUtils.isDesktop(any)).thenReturn(false);
      when(responsiveUtils.isWebDesktop(any)).thenReturn(false);

      // Configure a destination that would render the CTA on web, so the
      // assertion below can only pass because of the platform gate.
      final container = await pumpStorageView(tester);
      container
          .read(workplaceFqdnProvider.notifier)
          .setFqdn('workplace.domain.tld');
      await tester.pump();

      expect(find.byType(UpgradeStorageWidget), findsNothing);
      expect(paywallLauncher.launchCount, 0);
    });
  });
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
