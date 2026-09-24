import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_actions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_view_state.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_card_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/active_ecosystem_provider.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';

class EcosystemCalendarEventCardWidget extends ConsumerWidget {
  final AccountId? accountId;
  final String? jmapUrl;
  final CalendarEvent calendarEvent;
  final CalendarEventCardViewState viewState;
  final CalendarEventCardActions actions;

  const EcosystemCalendarEventCardWidget({
    super.key,
    required this.accountId,
    required this.jmapUrl,
    required this.calendarEvent,
    required this.viewState,
    required this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ecosystemState = ref.watch(activeEcosystemProvider(
      accountId,
      jmapUrl,
    ));
    final calendarUrlTemplate = switch (ecosystemState) {
      EcosystemAvailable(:final ecosystem) => ecosystem.calendarUrlTemplate,
      _ => null,
    };

    return CalendarEventCardWidget(
      calendarEvent: calendarEvent,
      viewState: viewState,
      actions: actions,
      calendarUrlTemplate: calendarUrlTemplate,
    );
  }
}
