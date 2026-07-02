import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/twp_warning.dart';
import 'package:tmail_ui_user/features/email/presentation/providers/twp_warning_notifier.dart';

class TwpWarningControllerSync extends ConsumerStatefulWidget {
  final EmailId? emailId;
  final List<TwpWarning>? warnings;
  final Map<KeyWordIdentifier, bool>? keywords;
  final Widget child;

  const TwpWarningControllerSync({
    super.key,
    required this.emailId,
    required this.warnings,
    required this.keywords,
    required this.child,
  });

  @override
  ConsumerState<TwpWarningControllerSync> createState() =>
      _TwpWarningControllerSyncState();
}

class _TwpWarningControllerSyncState
    extends ConsumerState<TwpWarningControllerSync> {
  @override
  void initState() {
    super.initState();
    _scheduleSync();
  }

  @override
  void didUpdateWidget(covariant TwpWarningControllerSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emailId != widget.emailId ||
        !identical(oldWidget.warnings, widget.warnings) ||
        !identical(oldWidget.keywords, widget.keywords)) {
      _scheduleSync();
    }
  }

  void _scheduleSync() {
    final emailId = widget.emailId;
    final warnings = widget.warnings;
    final keywords = widget.keywords;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(twpWarningProvider.notifier);
      if (emailId != null) {
        notifier.setWarnings(emailId, warnings ?? const []);
      } else {
        notifier.clearWarnings();
      }
      notifier.setKeywords(keywords);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
