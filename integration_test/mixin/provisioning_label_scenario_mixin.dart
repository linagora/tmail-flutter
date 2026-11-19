import 'package:flutter/foundation.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/data/network/label_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

import '../models/provisioning_email.dart';
import '../models/provisioning_label.dart';
import '../utils/jmap/jmap_test_client.dart';
import '../utils/wait_for_mailbox_ready.dart';

mixin ProvisioningLabelScenarioMixin {
  Future<List<Label>> provisionLabels(
    List<ProvisioningLabel> provisioningLabels,
  ) async {
    if (provisioningLabels.isEmpty) {
      return [];
    }

    final client = await JmapTestClient.current();
    final labelApi = LabelApi(client.httpClient, const Uuid());

    // Sequential: concurrent Label/set races in the memory backend
    final List<Label> createdLabels = [];
    for (final provisioningLabel in provisioningLabels) {
      try {
        createdLabels.add(
          await labelApi.createNewLabel(
            client.accountId,
            provisioningLabel.toLabel(),
          ),
        );
      } catch (e, st) {
        Error.throwWithStackTrace(
          StateError(
            'Failed to provision label ${provisioningLabel.displayName}: $e',
          ),
          st,
        );
      }
    }

    debugPrint('[label-diag] created=${createdLabels.map((l) => '${l.id?.value}:${l.safeDisplayName}').toList()} '
        'backend=${client.backendUrl} account=${client.accountId.id.value}');
    await _refreshLabelsInUi(client.accountId);

    return createdLabels;
  }

  Future<void> _refreshLabelsInUi(AccountId accountId) async {
    await waitForMailboxReady();
    final dashboard = getBinding<MailboxDashBoardController>();
    final lc = dashboard?.labelController;
    debugPrint('[label-diag] before refresh appAccount=${dashboard?.accountId.value?.id.value} '
        'enabled=${lc?.isLabelSettingEnabled.value} loaded=${lc?.isLabelsLoaded.value} '
        'expand=${lc?.labelListExpandMode.value} labels=${lc?.labels.map((l) => l.safeDisplayName).toList()}');
    lc?.getAllLabels(accountId);
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
