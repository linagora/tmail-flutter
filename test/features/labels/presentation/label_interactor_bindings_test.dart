import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
// ignore: implementation_imports
import 'package:get/get_navigation/src/router_report.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/delete_a_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/edit_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_all_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_label_changes_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_interactor_bindings.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('LabelInteractorBindings', () {
    // RouterReportManager keeps its current route across Get.reset: pin it.
    final dashboardRoute = MaterialPageRoute<void>(builder: (_) => const SizedBox());

    setUp(() {
      RouterReportManager.reportCurrentRoute(dashboardRoute);
      Get.put(HttpClient(Dio()));
      Get.put(const Uuid());
      Get.put(RemoteExceptionThrower());
    });

    tearDown(() {
      RouterReportManager.clearRouteKeys();
      Get.reset();
    });

    test(
      'label dialog interactors still resolve after the route that first resolved the bindings is disposed',
      () {
        final composerRoute = MaterialPageRoute<void>(builder: (_) => const SizedBox());
        RouterReportManager.reportCurrentRoute(composerRoute);
        LabelInteractorBindings().dependencies();
        Get.find<GetAllLabelInteractor>();
        Get.find<DeleteALabelInteractor>();
        Get.find<GetLabelChangesInteractor>();

        RouterReportManager.reportRouteDispose(composerRoute);
        RouterReportManager.reportCurrentRoute(dashboardRoute);

        expect(Get.find<CreateNewLabelInteractor>(), isA<CreateNewLabelInteractor>());
        expect(Get.find<EditLabelInteractor>(), isA<EditLabelInteractor>());
      },
    );
  });
}
