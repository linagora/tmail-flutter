import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/domain/state/create_new_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../models/provisioning_email.dart';
import '../models/provisioning_label.dart';

mixin ProvisioningLabelScenarioMixin {
  Future<List<Label>> provisionLabels(
    List<ProvisioningLabel> provisioningLabels,
  ) async {
    if (provisioningLabels.isEmpty) {
      return [];
    }

    final dashboardController = getBinding<MailboxDashBoardController>();
    final createLabelInteractor = getBinding<CreateNewLabelInteractor>();

    final accountId = dashboardController?.accountId.value;
    final labelController = dashboardController?.labelController;

    if (dashboardController == null ||
        createLabelInteractor == null ||
        accountId == null) {
      log(
        'ProvisioningLabelScenarioMixin::provisionLabels '
        'skipped: missing dashboardController, CreateNewLabelInteractor, or accountId',
      );
      return [];
    }

    final List<Label?> results = await Future.wait(provisioningLabels.map(
      (label) => _createLabel(createLabelInteractor, accountId, label),
    ));

    final List<Label> createdLabels = results.whereType<Label>().toList();

    if (createdLabels.isNotEmpty) {
      labelController?.getAllLabels(accountId);
    }

    return createdLabels;
  }

  Future<Label?> _createLabel(
    CreateNewLabelInteractor createLabelInteractor,
    AccountId accountId,
    ProvisioningLabel provisioningLabel,
  ) async {
    final result = await createLabelInteractor
        .execute(accountId, provisioningLabel.toLabel())
        .last;

    return result.fold(
      (_) => null,
      (success) => success is CreateNewLabelSuccess ? success.newLabel : null,
    );
  }

  Future<List<Label>> provisionLabelsByDisplayNames(List<String> labelNames) {
    return provisionLabels(
      labelNames.map(ProvisioningLabel.new).toList(),
    );
  }

  List<ProvisioningEmail> buildEmailsForLabel({
    required Label label,
    required String toEmail,
    required int count,
  }) {
    return List.generate(
      count,
      (index) {
        final emailNumber = index + 1;
        final displayName = label.safeDisplayName;

        return ProvisioningEmail(
          toEmail: toEmail,
          subject: 'Email $emailNumber subject $displayName',
          content: 'Email $emailNumber content $displayName',
          labels: [label],
        );
      },
    );
  }
}
