import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/dialog/modal_list_action_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/add_delegates_form.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/add_delegates_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/my_delegates_notifier.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/add_delegates/delegate_address_field.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnDelegatesAdded = void Function(AddDelegatesResult result);

/// Pick addresses as chips, then Add sends one `Delegate/set`. See ADR-0115.
class AddDelegatesDialog extends ConsumerWidget {
  static final LinagoraDialogStyle _tokens = LinagoraDialogStyle.material();
  static const EdgeInsetsGeometry _headerPadding = EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 16);

  final Session session;
  final DelegateSuggestionLoader loadSuggestions;
  final OnDelegatesAdded onDelegatesAdded;

  /// The outcome is unknown, so the caller marks its list stale.
  final VoidCallback onAddFailed;

  const AddDelegatesDialog({
    super.key,
    required this.session,
    required this.loadSuggestions,
    required this.onDelegatesAdded,
    required this.onAddFailed,
  });

  static Future<void> show(AddDelegatesDialog dialog) {
    return DialogRouter().openDialogModal(child: dialog, dialogLabel: UiKeys.addDelegatesDialog);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final form = ref.watch(addDelegatesProvider);

    return PopScope(
      canPop: !form.isSubmitting,
      child: Dialog(
        key: const ValueKey(UiKeys.addDelegatesDialog),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_tokens.surfaceRadius)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _tokens.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(l10n, form),
              Flexible(
                child: SingleChildScrollView(
                  padding: _tokens.contentPadding,
                  child: _buildContent(context, ref, l10n, form),
                ),
              ),
              Divider(height: 1, color: _tokens.dividerColor),
              _buildFooter(context, ref, l10n, form),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, AddDelegatesForm form) {
    return Padding(
      padding: _headerPadding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.delegateMailboxAccount,
              style: _tokens.titleTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: l10n.close,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(Size.square(_tokens.iconButtonSize)),
            style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: form.isSubmitting ? null : popBack,
            icon: SvgPicture.asset(Get.find<ImagePaths>().icCloseDialog, width: 24, height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AddDelegatesForm form,
  ) {
    final hasRejected = form.candidates.any((candidate) => candidate.isRejected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExplanation(l10n.addDelegatesExplanation),
        SizedBox(height: _tokens.contentGap),
        DelegateAddressField(
          candidates: form.candidates,
          loadSuggestions: (query, {limit}) => _loadAllowedSuggestions(ref, query, limit: limit),
          onPick: (emailAddress) => _pick(context, ref, emailAddress),
          onUnpick: ref.read(addDelegatesProvider.notifier).unpick,
          onTyped: ref.read(addDelegatesProvider.notifier).typeAddress,
          // A chip picked while the request runs would never be sent.
          isEnabled: !form.isSubmitting,
        ),
        if (hasRejected)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.someDelegatesCouldNotBeAdded,
              style: ThemeUtils.textStyleBodyBody3(color: AppColor.redFF3347),
            ),
          ),
      ],
    );
  }

  Widget _buildExplanation(String text) {
    return Text(text, style: _tokens.messageTextStyle);
  }

  Widget _buildFooter(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AddDelegatesForm form,
  ) {
    return ModalListActionButtonWidget(
      padding: _tokens.fixedFooterPadding,
      negativeLabel: l10n.cancel,
      positiveLabel: l10n.addDelegate,
      negativeKey: const ValueKey(UiKeys.addDelegatesCancelButton),
      positiveKey: const ValueKey(UiKeys.addDelegatesSubmitButton),
      isPositiveActionEnabled: form.canAdd && !form.isSubmitting,
      isProgressing: form.isSubmitting,
      onNegativeAction: () {
        if (!form.isSubmitting) popBack();
      },
      onPositiveAction: () => _add(context, ref),
    );
  }

  /// A typed address not yet a chip is picked first, so Add never drops it. Refused, it stays to be fixed.
  void _add(BuildContext context, WidgetRef ref) {
    final form = ref.read(addDelegatesProvider);
    if (form.isSubmitting) return;
    final pendingAddress = form.pendingAddress.trim();
    if (pendingAddress.isNotEmpty && !_pick(context, ref, EmailAddress(null, pendingAddress))) return;
    _submit(context, ref);
  }

  Future<List<EmailAddress>> _loadAllowedSuggestions(WidgetRef ref, String query, {int? limit}) async {
    final excluded = {
      session.username.value,
      ..._delegateUsernames(ref),
    }.map((username) => username.toLowerCase()).toSet();
    final contacts = await loadSuggestions(query, limit: limit);
    return contacts.where((contact) => !excluded.contains(contact.emailAddress.toLowerCase())).toList();
  }

  /// Read at each use, so a list re-read while the dialog is open counts.
  Set<String> _delegateUsernames(WidgetRef ref) => ref.read(myDelegatesProvider.notifier).lastUsernames;

  bool _pick(BuildContext context, WidgetRef ref, EmailAddress emailAddress) {
    final refusal = ref.read(addDelegatesProvider.notifier).pick(
          emailAddress,
          ownUsername: session.username.value,
          delegateUsernames: _delegateUsernames(ref),
        );
    final message = _refusalMessage(AppLocalizations.of(context), refusal, emailAddress);
    if (message != null) ref.read(appToastProvider).showToastErrorMessage(context, message);
    return refusal == null || refusal == DelegateAddressRefusal.alreadyPicked;
  }

  String? _refusalMessage(AppLocalizations l10n, DelegateAddressRefusal? refusal, EmailAddress emailAddress) {
    return switch (refusal) {
      null || DelegateAddressRefusal.alreadyPicked || DelegateAddressRefusal.submitting => null,
      DelegateAddressRefusal.invalid => l10n.invalidDelegateEmailAddress,
      DelegateAddressRefusal.yourself => l10n.cannotDelegateToYourself,
      DelegateAddressRefusal.alreadyDelegate => l10n.alreadyHasDelegateAccess(emailAddress.emailAddress.trim()),
    };
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(appToastProvider);
    switch (await ref.read(addDelegatesProvider.notifier).submit(session)) {
      case AddDelegatesIgnored():
        return;
      case AddDelegatesFailed():
        onAddFailed();
        if (context.mounted) toast.showToastErrorMessage(context, l10n.couldNotAddDelegates);
      case AddDelegatesSucceeded(:final result):
        onDelegatesAdded(result);
        if (context.mounted) _closeOnAdded(context, toast, l10n, result);
    }
  }

  void _closeOnAdded(BuildContext context, AppToast toast, AppLocalizations l10n, AddDelegatesResult result) {
    final addedMessage = _addedMessage(l10n, result.addedUsernames);
    if (addedMessage != null) toast.showToastSuccessMessage(context, addedMessage);
    if (result.rejectedUsernames.isEmpty) popBack();
  }

  String? _addedMessage(AppLocalizations l10n, List<String> addedUsernames) {
    return switch (addedUsernames.length) {
      0 => null,
      1 => l10n.delegateHasBeenAdded(addedUsernames.single),
      final count => l10n.delegatesHaveBeenAdded(count),
    };
  }
}
