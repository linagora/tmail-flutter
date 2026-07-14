import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';

/// Bottom spinner shown while a load-more page is fetching.
class SearchEmailLoadMoreIndicator extends ConsumerWidget with AppLoaderMixin {
  const SearchEmailLoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWaiting = ref.watch(
      searchEmailPresentationProvider
          .select((state) => state.searchMoreState == SearchMoreState.waiting),
    );
    if (!isWaiting) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: loadingWidget,
    );
  }
}
