import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/data/network/label_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

import '../models/provisioning_email.dart';
import '../models/provisioning_label.dart';
import '../utils/jmap/jmap_test_client.dart';
import '../utils/test_timeouts.dart';
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

    await _refreshLabelsInUi(client.accountId, createdLabels);

    return createdLabels;
  }

  // Await the refresh itself so it cannot rebuild the sidebar mid-test.
  Future<void> _refreshLabelsInUi(
    AccountId accountId,
    List<Label> created,
  ) async {
    await waitForMailboxReady();
    final labelController =
        getBinding<MailboxDashBoardController>()?.labelController;
    if (labelController == null) {
      throw StateError('Provisioning labels: no LabelController');
    }
    final createdIds = created.map((label) => label.id).toSet();
    // Subscribe before triggering the refresh so its emission is not missed.
    final refreshed = labelController.labels.stream.firstWhere(
      (labels) => createdIds.every((id) => labels.any((l) => l.id == id)),
    );
    labelController.getAllLabels(accountId);
    await refreshed.timeout(
      TestTimeouts.long,
      onTimeout: () => throw StateError(
        'Provisioned labels did not reach the sidebar: '
        '${created.map((l) => l.safeDisplayName).toList()}',
      ),
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
