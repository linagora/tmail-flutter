import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/emit_state_mixin.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/remove_a_label_from_an_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_a_label_from_an_email_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/mixin/add_label_to_email_mixin.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/email_action_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/garbage_collection_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import '../../../../fixtures/widget_fixtures.dart';
import 'add_label_to_email_mixin_test.mocks.dart';

/// Wires the mixin the way MailboxDashBoardController does: interactors are
/// resolved from GetX at tap time, results are routed to the label handlers.
class _AddLabelToEmailHost extends BaseController
    with EmitStateMixin, AddLabelToEmailMixin {
  _AddLabelToEmailHost(this.labels);

  final List<Label> labels;

  @override
  bool get isCurrentLabelAvailable => true;

  @override
  List<Label> get currentLabelList => labels;

  @override
  AccountId? get currentAccountId => AccountFixtures.aliceAccountId;

  @override
  Session? get currentSession => SessionFixtures.aliceSession;

  @override
  ToastManager get currentToastManager => toastManager;

  @override
  BaseController get currentController => this;

  @override
  AddALabelToAnEmailInteractor? get addALabelToAnEmailInteractor =>
      getBinding<AddALabelToAnEmailInteractor>();

  @override
  RemoveALabelFromAnEmailInteractor? get removeALabelFromAnEmailInteractor =>
      getBinding<RemoveALabelFromAnEmailInteractor>();

  @override
  OnSyncLabelForEmail? get onSyncLabelForEmail => null;

  @override
  void handleSuccessViewState(Success success) {
    subscribeLabelViewStateSuccess(success);
  }

  @override
  void handleFailureViewState(Failure failure) {
    subscribeLabelViewStateFailure(failure);
  }
}

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
  MockSpec<EmailRepository>(),
])
void main() {
  late MockToastManager mockToastManager;
  late MockEmailRepository mockEmailRepository;

  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;
  final emailId = EmailId(Id('email-1'));
  final workKeyword = KeyWordIdentifier('\$label_work');
  final travelKeyword = KeyWordIdentifier('\$label_travel');
  final workLabel = Label(keyword: workKeyword, displayName: 'Work');
  final travelLabel = Label(keyword: travelKeyword, displayName: 'Travel');

  setUp(() {
    Get.testMode = true;
    mockToastManager = MockToastManager();
    mockEmailRepository = MockEmailRepository();

    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    final authorizationInterceptors = MockAuthorizationInterceptors();
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(ImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(MockUuid());
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(MockTwakeAppManager());
  });

  tearDown(Get.reset);

  PresentationEmail buildEmail(List<KeyWordIdentifier> labelKeywords) {
    return PresentationEmail(
      id: emailId,
      keywords: {for (final keyword in labelKeywords) keyword: true},
    );
  }

  /// Registers the bindings while a page route is current, as the dashboard
  /// route does in production.
  Future<_AddLabelToEmailHost> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()),
    );
    await tester.pump();
    EmailActionInteractorBindings(mockEmailRepository).dependencies();
    return _AddLabelToEmailHost([workLabel, travelLabel]);
  }

  /// Picks [label] in a freshly opened modal and returns a weak reference to
  /// the modal route, so callers can check it is released once closed.
  Future<WeakReference<Route>> selectLabelInModal(
    WidgetTester tester, {
    required _AddLabelToEmailHost host,
    required PresentationEmail email,
    required Label label,
  }) async {
    final modalClosed = host.openAddLabelToEmailDialogModal(
      email: email,
      onCreateANewLabelAction: () {},
    );
    await tester.pumpAndSettle();
    final modal = find.byKey(const Key('add_label_to_email_modal'));
    expect(modal, findsOneWidget);
    final modalRoute = WeakReference(ModalRoute.of(tester.element(modal))!);

    await tester.tap(find.text(label.displayName!));
    await tester.pumpAndSettle();
    await modalClosed;
    return modalRoute;
  }

  group('AddLabelToEmailMixin::openAddLabelToEmailDialogModal', () {
    testWidgets(
      'should add the selected label every time '
      'when the label modal is reopened on the same email',
      (tester) async {
        when(mockEmailRepository.addLabelToEmail(any, any, any, any))
            .thenAnswer((_) async {});
        final host = await pumpHost(tester);

        await selectLabelInModal(
          tester,
          host: host,
          email: buildEmail([]),
          label: workLabel,
        );
        await selectLabelInModal(
          tester,
          host: host,
          email: buildEmail([workKeyword]),
          label: travelLabel,
        );

        verify(mockEmailRepository.addLabelToEmail(
          session,
          accountId,
          emailId,
          workKeyword,
        )).called(1);
        verify(mockEmailRepository.addLabelToEmail(
          session,
          accountId,
          emailId,
          travelKeyword,
        )).called(1);
        verify(mockToastManager.showMessageSuccess(
          AddALabelToAnEmailSuccess(emailId, travelKeyword, 'Travel'),
        )).called(1);
        verifyNever(mockToastManager.showMessageFailure(any));
      },
    );

    testWidgets(
      'should remove the deselected label every time '
      'when the label modal is reopened on the same email',
      (tester) async {
        when(mockEmailRepository.removeLabelFromEmail(any, any, any, any))
            .thenAnswer((_) async {});
        final host = await pumpHost(tester);

        await selectLabelInModal(
          tester,
          host: host,
          email: buildEmail([workKeyword, travelKeyword]),
          label: workLabel,
        );
        await selectLabelInModal(
          tester,
          host: host,
          email: buildEmail([travelKeyword]),
          label: travelLabel,
        );

        verify(mockEmailRepository.removeLabelFromEmail(
          session,
          accountId,
          emailId,
          workKeyword,
        )).called(1);
        verify(mockEmailRepository.removeLabelFromEmail(
          session,
          accountId,
          emailId,
          travelKeyword,
        )).called(1);
        verify(mockToastManager.showMessageSuccess(
          RemoveALabelFromAnEmailSuccess(emailId, travelKeyword, 'Travel'),
        )).called(1);
        verifyNever(mockToastManager.showMessageFailure(any));
      },
    );

    testWidgets(
      'should still remove a label outside the modal '
      'when the modal was used to remove a label before',
      (tester) async {
        when(mockEmailRepository.removeLabelFromEmail(any, any, any, any))
            .thenAnswer((_) async {});
        final host = await pumpHost(tester);

        await selectLabelInModal(
          tester,
          host: host,
          email: buildEmail([workKeyword, travelKeyword]),
          label: workLabel,
        );
        host.toggleLabelToEmail(emailId, travelLabel, false);
        await tester.pumpAndSettle();

        verify(mockEmailRepository.removeLabelFromEmail(
          session,
          accountId,
          emailId,
          travelKeyword,
        )).called(1);
        verifyNever(mockToastManager.showMessageFailure(any));
      },
    );

    testWidgets(
      'should show the failure toast '
      'when the repository rejects the second label',
      (tester) async {
        final exception = Exception('set error');
        when(mockEmailRepository.addLabelToEmail(
          any,
          any,
          any,
          workKeyword,
        )).thenAnswer((_) async {});
        when(mockEmailRepository.addLabelToEmail(
          any,
          any,
          any,
          travelKeyword,
        )).thenThrow(exception);
        final host = await pumpHost(tester);

        await selectLabelInModal(
          tester,
          host: host,
          email: buildEmail([]),
          label: workLabel,
        );
        await selectLabelInModal(
          tester,
          host: host,
          email: buildEmail([workKeyword]),
          label: travelLabel,
        );

        verify(mockToastManager.showMessageFailure(
          AddALabelToAnEmailFailure(
            exception: exception,
            labelDisplay: 'Travel',
          ),
        )).called(1);
      },
    );

    testWidgets(
      'should release every closed label modal '
      'when labels are added from it repeatedly',
      (tester) async {
        when(mockEmailRepository.addLabelToEmail(any, any, any, any))
            .thenAnswer((_) async {});
        final host = await pumpHost(tester);

        final modalRoutes = <WeakReference<Route>>[];
        for (final label in [workLabel, travelLabel, workLabel, travelLabel]) {
          modalRoutes.add(await selectLabelInModal(
            tester,
            host: host,
            email: buildEmail([]),
            label: label,
          ));
        }
        await tester.runAsync(GarbageCollectionFixtures.forceGarbageCollection);

        verify(mockEmailRepository.addLabelToEmail(any, any, any, any))
            .called(4);
        expect(modalRoutes.where((route) => route.target != null), isEmpty);
      },
    );
  });
}
