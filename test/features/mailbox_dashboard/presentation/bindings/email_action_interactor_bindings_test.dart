import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/add_list_label_to_list_emails_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_a_label_from_an_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/email_action_interactor_bindings.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../../../../fixtures/garbage_collection_fixtures.dart';
import '../../../../fixtures/widget_fixtures.dart';

class _FakeEmailRepository extends Fake implements EmailRepository {}

typedef _ResolveBinding = Object? Function();

typedef _DialogResolution = ({Object? instance, WeakReference<Route> route});

/// Registers the bindings while a page route is current, as the dashboard
/// route does in production.
Future<void> _pumpHostAndBind(WidgetTester tester) async {
  await tester.pumpWidget(
    WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()),
  );
  await tester.pump();
  EmailActionInteractorBindings(_FakeEmailRepository()).dependencies();
}

/// Resolves the binding while a dialog is the current GetX route, the way
/// the label modal does on touch layouts, then closes that dialog.
Future<_DialogResolution> _resolveInsideDialog(
  WidgetTester tester,
  _ResolveBinding resolve,
) async {
  Route? dialogRoute;
  final dialogClosed = DialogRouter().openDialogModal(
    child: Builder(builder: (context) {
      dialogRoute ??= ModalRoute.of(context);
      return const SizedBox.shrink();
    }),
    dialogLabel: 'add-label-to-email-modal',
  );
  await tester.pumpAndSettle();

  final instance = resolve();

  popBack();
  await tester.pumpAndSettle();
  await dialogClosed;

  return (instance: instance, route: WeakReference(dialogRoute!));
}

Future<void> _expectResolvableAfterDialogCloses(
  WidgetTester tester,
  _ResolveBinding resolve,
) async {
  await _pumpHostAndBind(tester);

  final resolution = await _resolveInsideDialog(tester, resolve);

  expect(resolution.instance, isNotNull);
  expect(resolve(), isNotNull);
}

Future<void> _expectSameInstanceAcrossDialogs(
  WidgetTester tester,
  _ResolveBinding resolve,
) async {
  await _pumpHostAndBind(tester);
  final instance = resolve();

  for (var attempt = 0; attempt < 3; attempt++) {
    final resolution = await _resolveInsideDialog(tester, resolve);
    expect(resolution.instance, same(instance), reason: 'attempt ${attempt + 1}');
  }
  expect(resolve(), same(instance));
}

Future<void> _expectClosedDialogRoutesReleased(
  WidgetTester tester,
  _ResolveBinding resolve,
) async {
  await _pumpHostAndBind(tester);

  final routes = <WeakReference<Route>>[];
  for (var attempt = 0; attempt < 5; attempt++) {
    routes.add((await _resolveInsideDialog(tester, resolve)).route);
  }
  await tester.runAsync(GarbageCollectionFixtures.forceGarbageCollection);

  expect(routes.where((route) => route.target != null), isEmpty);
}

void main() {
  tearDown(Get.reset);

  group('EmailActionInteractorBindings::dependencies', () {
    final dialogResolvedBindings = <String, _ResolveBinding>{
      'AddALabelToAnEmailInteractor': getBinding<AddALabelToAnEmailInteractor>,
      'RemoveALabelFromAnEmailInteractor':
          getBinding<RemoveALabelFromAnEmailInteractor>,
    };

    dialogResolvedBindings.forEach((name, resolve) {
      testWidgets(
        'should keep $name resolvable '
        'when the dialog that resolved it is closed',
        (tester) => _expectResolvableAfterDialogCloses(tester, resolve),
      );

      testWidgets(
        'should reuse the same $name '
        'when it is resolved inside a dialog repeatedly',
        (tester) => _expectSameInstanceAcrossDialogs(tester, resolve),
      );

      testWidgets(
        'should release every closed dialog route '
        'when $name is resolved inside it',
        (tester) => _expectClosedDialogRoutesReleased(tester, resolve),
      );
    });

    testWidgets('should register AddListLabelToListEmailsInteractor',
        (tester) async {
      await _pumpHostAndBind(tester);

      expect(getBinding<AddListLabelToListEmailsInteractor>(), isNotNull);
    });
  });
}
