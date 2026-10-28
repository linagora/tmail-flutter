import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rich_text_composer/rich_text_composer.dart' show HtmlEditorApi, RichTextController;
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_presentation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'vacation_controller_test.mocks.dart';

class _MockCachingManager extends Mock implements CachingManager {}
class _MockLanguageCacheManager extends Mock implements LanguageCacheManager {}
class _MockAuthorizationInterceptors extends Mock implements AuthorizationInterceptors {}
class _MockDynamicUrlInterceptors extends Mock implements DynamicUrlInterceptors {}
class _MockDeleteCredentialInteractor extends Mock implements DeleteCredentialInteractor {}
class _MockLogoutOidcInteractor extends Mock implements LogoutOidcInteractor {}
class _MockDeleteAuthorityOidcInteractor extends Mock implements DeleteAuthorityOidcInteractor {}
class _MockImagePaths extends Mock implements ImagePaths {}
class _MockResponsiveUtils extends Mock implements ResponsiveUtils {}
class _MockUuid extends Mock implements Uuid {}
class _MockToastManager extends Mock implements ToastManager {}
class _MockTwakeAppManager extends Mock implements TwakeAppManager {}
class _MockManageAccountDashBoardController extends Mock implements ManageAccountDashBoardController {
  @override
  final accountId = Rxn<AccountId>(AccountId(Id('account-id')));

  @override
  final onStart = InternalFinalCallback<void>(callback: () {});

  @override
  final onDelete = InternalFinalCallback<void>(callback: () {});
}
class _MockSettingsController extends Mock implements SettingsController {
  @override
  final onStart = InternalFinalCallback<void>(callback: () {});

  @override
  final onDelete = InternalFinalCallback<void>(callback: () {});
}

class _RecordingUpdateVacationInteractor extends Fake implements UpdateVacationInteractor {
  final savedVacations = <VacationResponse>[];

  @override
  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    VacationResponse vacationResponse, {
    bool isAuto = false,
  }) {
    savedVacations.add(vacationResponse);
    return const Stream.empty();
  }
}

class _FakeHtmlEditorApi extends Fake implements HtmlEditorApi {
  _FakeHtmlEditorApi(this.html);

  final String html;

  @override
  Future<String> getText() async => html;
}

@GenerateNiceMocks([MockSpec<AppToast>()])
void main() {
  late MockAppToast appToast;
  late _RecordingUpdateVacationInteractor updateVacationInteractor;
  late VacationController controller;

  setUp(() {
    Get.testMode = true;
    appToast = MockAppToast();
    updateVacationInteractor = _RecordingUpdateVacationInteractor();
    Get.put<CachingManager>(_MockCachingManager());
    Get.put<LanguageCacheManager>(_MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(_MockAuthorizationInterceptors());
    Get.put<AuthorizationInterceptors>(
      _MockAuthorizationInterceptors(),
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(_MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(_MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(_MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(_MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(appToast);
    Get.put<ImagePaths>(_MockImagePaths());
    Get.put<ResponsiveUtils>(_MockResponsiveUtils());
    Get.put<Uuid>(_MockUuid());
    Get.put<ToastManager>(_MockToastManager());
    Get.put<TwakeAppManager>(_MockTwakeAppManager());
    Get.put<ManageAccountDashBoardController>(_MockManageAccountDashBoardController());
    Get.put<SettingsController>(_MockSettingsController());

    controller = VacationController(updateVacationInteractor);
  });

  tearDown(Get.deleteAll);

  Future<BuildContext> pumpApp(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: Builder(builder: (builderContext) {
        context = builderContext;
        return const Scaffold();
      }),
    ));
    await tester.pumpAndSettle();
    return context;
  }

  void setUpVacation({
    required VacationResponderStatus status,
    required String editorHtml,
  }) {
    controller.vacationPresentation.value = VacationPresentation(
      status: status,
      startDate: DateTime(2026, 1, 5),
      startTime: const TimeOfDay(hour: 9, minute: 0),
    );
    controller.richTextControllerForMobile = RichTextController()
      ..htmlEditorApi = _FakeHtmlEditorApi(editorHtml);
  }

  group('VacationController::saveVacation', () {
    testWidgets(
      'rejects an enabled vacation whose mobile editor only holds an empty line',
      (tester) async {
        final context = await pumpApp(tester);
        setUpVacation(
          status: VacationResponderStatus.activated,
          editorHtml: '<div><br></div>',
        );

        controller.saveVacation(context);
        await tester.pumpAndSettle();

        verify(appToast.showToastErrorMessage(
          any,
          AppLocalizations.of(context).errorMessageWhenMessageVacationIsEmpty,
        )).called(1);
        expect(updateVacationInteractor.savedVacations, isEmpty);
      },
    );

    testWidgets(
      'rejects an enabled vacation whose mobile editor returns an empty string',
      (tester) async {
        final context = await pumpApp(tester);
        setUpVacation(status: VacationResponderStatus.activated, editorHtml: '');

        controller.saveVacation(context);
        await tester.pumpAndSettle();

        verify(appToast.showToastErrorMessage(
          any,
          AppLocalizations.of(context).errorMessageWhenMessageVacationIsEmpty,
        )).called(1);
        expect(updateVacationInteractor.savedVacations, isEmpty);
      },
    );

    testWidgets(
      'saves an enabled vacation whose mobile editor holds text',
      (tester) async {
        final context = await pumpApp(tester);
        setUpVacation(
          status: VacationResponderStatus.activated,
          editorHtml: '<div>Back on Monday</div>',
        );

        controller.saveVacation(context);
        await tester.pumpAndSettle();

        verifyNever(appToast.showToastErrorMessage(any, any));
        expect(updateVacationInteractor.savedVacations, hasLength(1));
        expect(
          updateVacationInteractor.savedVacations.single.htmlBody,
          '<div>Back on Monday</div>',
        );
      },
    );

    testWidgets(
      'saves an enabled vacation whose mobile editor only holds an image',
      (tester) async {
        final context = await pumpApp(tester);
        setUpVacation(
          status: VacationResponderStatus.activated,
          editorHtml: '<div><img src="cid:away"></div>',
        );

        controller.saveVacation(context);
        await tester.pumpAndSettle();

        verifyNever(appToast.showToastErrorMessage(any, any));
        expect(updateVacationInteractor.savedVacations, hasLength(1));
        expect(
          updateVacationInteractor.savedVacations.single.htmlBody,
          '<div><img src="cid:away"></div>',
        );
      },
    );

    testWidgets(
      'saves a disabled vacation even when the mobile editor is empty',
      (tester) async {
        final context = await pumpApp(tester);
        setUpVacation(
          status: VacationResponderStatus.deactivated,
          editorHtml: '<div><br></div>',
        );

        controller.saveVacation(context);
        await tester.pumpAndSettle();

        verifyNever(appToast.showToastErrorMessage(any, any));
        expect(updateVacationInteractor.savedVacations, hasLength(1));
        expect(updateVacationInteractor.savedVacations.single.isEnabled, isFalse);
      },
    );
  });
}
