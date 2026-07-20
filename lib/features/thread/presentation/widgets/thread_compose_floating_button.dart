import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';

typedef OnTapThreadComposeAction = void Function();

class ThreadComposeFloatingButton extends ConsumerWidget {
  final ResponsiveUtils responsiveUtils;
  final ScrollController scrollController;
  final bool isTrashViewOpen;
  final bool isSelectModeActive;
  final bool hasSelectedEmails;
  final OnTapThreadComposeAction onTapCompose;

  const ThreadComposeFloatingButton({
    super.key,
    required this.responsiveUtils,
    required this.scrollController,
    required this.isTrashViewOpen,
    required this.isSelectModeActive,
    required this.hasSelectedEmails,
    required this.onTapCompose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const SizedBox.shrink();
    }

    final searchViewState = ref.watch(searchViewStateProvider);
    final canShowComposeButton = _canShowComposeButton(
      isSearchEngaged: searchViewState.isSearchEngaged,
      isTrashViewOpen: isTrashViewOpen,
      isSelectModeActive: isSelectModeActive,
    );

    if (!canShowComposeButton) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: _resolveButtonPadding(context),
      child: ComposeFloatingButton(
        key: const ValueKey(UiKeys.composeEmailButton),
        scrollController: scrollController,
        onTap: onTapCompose
      ),
    );
  }

  /// Hidden inside any search UI, the trash view, or selection mode.
  bool _canShowComposeButton({
    required bool isSearchEngaged,
    required bool isTrashViewOpen,
    required bool isSelectModeActive,
  }) =>
      !isSearchEngaged && !isTrashViewOpen && !isSelectModeActive;

  EdgeInsetsGeometry _resolveButtonPadding(BuildContext context) {
    // Only mobile with a selection needs to clear the bottom action bar.
    final needsBottomInset = PlatformInfo.isMobile && hasSelectedEmails;
    if (!needsBottomInset) return EdgeInsets.zero;

    return EdgeInsets.only(
      bottom: responsiveUtils.isTabletLarge(context) ? 85 : 70,
    );
  }
}
