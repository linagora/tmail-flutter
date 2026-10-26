import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' show HtmlEditorController;
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
    vacationController = VacationController(MockUpdateVacationInteractor());
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
  });
}

class _RecordingHtmlEditorController extends Fake implements HtmlEditorController {
  String? text;

  @override
  void setText(String text) => this.text = text;
}

class _FakeRichTextWebController extends RichTextWebController {
  _FakeRichTextWebController(this._editorController);

  final HtmlEditorController _editorController;

  @override
  HtmlEditorController get editorController => _editorController;
}
