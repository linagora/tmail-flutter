import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/utils/html_transformer/editor_html_sanitizer.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' show HtmlEditorController;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rich_text_composer/rich_text_composer.dart' show HtmlEditorApi, RichTextController;
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'vacation_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  // Base controller mockspecs
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  // Vacation controller mockspecs
  MockSpec<ManageAccountDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<SettingsController>(fallbackGenerators: fallbackGenerators),
  MockSpec<UpdateVacationInteractor>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockManageAccountDashBoardController mockDashboardController;
  late Rxn<VacationResponse> vacationResponse;
  late MockUpdateVacationInteractor mockUpdateVacationInteractor;
  late VacationController vacationController;
  late _RecordingHtmlEditorController webEditorController;

  setUp(() {
    Get.testMode = true;
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
    Get.put<ImagePaths>(MockImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(MockUuid());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());

    vacationResponse = Rxn<VacationResponse>();
    mockDashboardController = MockManageAccountDashBoardController();
    when(mockDashboardController.vacationResponse).thenReturn(vacationResponse);
    Get.put<ManageAccountDashBoardController>(mockDashboardController);
    Get.put<SettingsController>(MockSettingsController());

    PlatformInfo.isTestingForWeb = true;
    mockUpdateVacationInteractor = MockUpdateVacationInteractor();
    vacationController = VacationController(mockUpdateVacationInteractor);
    vacationController.onInit();
    webEditorController = _RecordingHtmlEditorController();
    vacationController.richTextControllerForWeb =
        _FakeRichTextWebController(webEditorController);
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
    Get.reset();
  });

  group('VacationController loading the stored vacation message:', () {
    // The vacation message is stored raw on the server (other clients,
    // admin tools) and the web editor is a same-origin iframe that evaluates
    // inline handlers: only the sanitized message may reach it.
    const storedMessage =
        '<p>Out of office</p><img src="x" onerror="alert(document.cookie)">';

    test(
      'SHOULD give the web editor the message without its event handlers',
    () async {
      vacationResponse.value = VacationResponse(
        isEnabled: false,
        htmlBody: storedMessage,
      );
      await pumpEventQueue();

      expect(webEditorController.text, contains('Out of office'));
      expect(webEditorController.text, isNot(contains('onerror')));
    });

    test(
      'SHOULD expose the message without its event handlers '
      'as the editor initial text',
    () async {
      vacationResponse.value = VacationResponse(
        isEnabled: false,
        htmlBody: storedMessage,
      );
      await pumpEventQueue();

      expect(vacationController.vacationMessageHtmlText, contains('Out of office'));
      expect(vacationController.vacationMessageHtmlText, isNot(contains('onerror')));
    });

    test(
      'SHOULD give the mobile editor the message without its event handlers',
    () async {
      PlatformInfo.isTestingForWeb = false;
      final mobileEditorApi = _RecordingHtmlEditorApi();
      vacationController.richTextControllerForMobile = RichTextController()
        ..htmlEditorApi = mobileEditorApi;

      vacationResponse.value = VacationResponse(
        isEnabled: false,
        htmlBody: storedMessage,
      );
      await pumpEventQueue();

      expect(mobileEditorApi.text, contains('Out of office'));
      expect(mobileEditorApi.text, isNot(contains('onerror')));
    });
  });

  group('VacationController saving the stored vacation message:', () {
    // The stored message may carry markup the display sanitizer drops (here
    // float): saving without touching the editor must not rewrite it.
    const storedMessage = '<div style="float:right">Back on Monday</div>';

    Future<BuildContext> pumpContext(WidgetTester tester) async {
      late BuildContext context;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
        context = c;
        return const SizedBox();
      })));
      return context;
    }

    Future<VacationResponse> save(WidgetTester tester) async {
      when(mockDashboardController.accountId)
          .thenReturn(Rxn(AccountId(Id('account-id'))));
      when(mockUpdateVacationInteractor.execute(any, any))
          .thenAnswer((_) => const Stream.empty());
      vacationResponse.value = VacationResponse(
        isEnabled: true,
        fromDate: UTCDate(DateTime.utc(2026, 1, 1)),
        htmlBody: storedMessage,
      );
      await tester.pump();
      final context = await pumpContext(tester);

      vacationController.saveVacation(context);
      await tester.pump();

      return verify(mockUpdateVacationInteractor.execute(any, captureAny))
          .captured
          .single as VacationResponse;
    }

    testWidgets(
      'SHOULD save the stored message unchanged when the web editor is untouched',
    (tester) async {
      expect(EditorHtmlSanitizer.sanitize(storedMessage), isNot(storedMessage));

      final saved = await save(tester);

      expect(saved.htmlBody, storedMessage);
    });

    testWidgets(
      'SHOULD save the stored message unchanged when the mobile editor is untouched',
    (tester) async {
      PlatformInfo.isTestingForWeb = false;
      vacationController.richTextControllerForMobile = RichTextController()
        ..htmlEditorApi = _RecordingHtmlEditorApi(wrapGetTextInNewlines: true);

      final saved = await save(tester);

      expect(saved.htmlBody, storedMessage);
    });

    testWidgets(
      'SHOULD save the edited message without active content',
    (tester) async {
      when(mockDashboardController.accountId)
          .thenReturn(Rxn(AccountId(Id('account-id'))));
      when(mockUpdateVacationInteractor.execute(any, any))
          .thenAnswer((_) => const Stream.empty());
      vacationResponse.value = VacationResponse(
        isEnabled: true,
        fromDate: UTCDate(DateTime.utc(2026, 1, 1)),
        htmlBody: storedMessage,
      );
      await tester.pump();
      final context = await pumpContext(tester);
      vacationController.updateMessageHtmlText('<p>New</p><script>x</script>');

      vacationController.saveVacation(context);
      await tester.pump();

      final saved = verify(mockUpdateVacationInteractor.execute(any, captureAny))
          .captured
          .single as VacationResponse;
      expect(saved.htmlBody, contains('New'));
      expect(saved.htmlBody, isNot(contains('<script')));
    });
  });
}

class _RecordingHtmlEditorController extends Fake implements HtmlEditorController {
  String? text;

  @override
  void setText(String text) => this.text = text;
}

class _RecordingHtmlEditorApi extends Fake implements HtmlEditorApi {
  _RecordingHtmlEditorApi({this.wrapGetTextInNewlines = false});

  // The mobile editor template wraps its content in newlines.
  final bool wrapGetTextInNewlines;
  String? text;

  @override
  Future<void> setText(String text) async => this.text = text;

  @override
  Future<String> getText() async => wrapGetTextInNewlines ? '\n$text\n' : text ?? '';
}

class _FakeRichTextWebController extends RichTextWebController {
  _FakeRichTextWebController(this._editorController);

  final HtmlEditorController _editorController;

  @override
  HtmlEditorController get editorController => _editorController;
}
