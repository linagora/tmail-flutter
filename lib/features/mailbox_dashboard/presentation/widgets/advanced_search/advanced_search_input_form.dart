import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_autocomplete_input_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_button_arrow_down_field_with_tab_key_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_date_drop_down_field_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_with_tab_key_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/advanced_filter_view_state_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_field_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form_bottom_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/label_drop_down_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/sort_by_drop_down_button.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef _AddressFieldConfig = ({
  List<EmailAddress> Function(WidgetRef ref) listEmailAddress,
  ExpandMode Function(WidgetRef ref) expandMode,
  TextEditingController textEditingController,
  GlobalKey<TagsEditorState> keyTagEditor,
  FocusNode focusNode,
  FocusNode nextFocusNode,
});

typedef _TextFieldConfig = ({
  TextEditingController textEditingController,
  FocusNode currentFocusNode,
  FocusNode nextFocusNode,
});

class AdvancedSearchInputForm extends GetWidget<AdvancedFilterController> {
  const AdvancedSearchInputForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return FocusTraversalGroup(
      child: Column(
        children: [
          for (final entry in _addressFields())
            ..._withGap(_buildAddressField(entry.field, entry.config)),
          for (final entry in _textFields(appLocalizations))
            ..._withGap(_buildTextField(entry.field, appLocalizations, entry.config)),
          _buildMailboxField(context, appLocalizations),
          const SizedBox(height: 12),
          _buildLabelField(),
          _buildDateField(),
          const SizedBox(height: 12),
          _buildSortByField(),
          const SizedBox(height: 24),
          AdvancedSearchFilterFormBottomView(focusManager: controller.focusManager),
        ],
      ),
    );
  }

  List<Widget> _withGap(Widget field) => [field, const SizedBox(height: 12)];

  List<({FilterField field, _AddressFieldConfig config})> _addressFields() => [
    (
      field: FilterField.from,
      config: (
        listEmailAddress: (ref) => _toEmailAddresses(ref.watch(
          searchFilterProvider.select((filter) => filter.from))),
        expandMode: (ref) => ref.watch(advancedFilterViewStateProvider.select(
          (state) => state.fromAddressExpandMode,
        )),
        textEditingController: controller.fromEmailAddressController,
        keyTagEditor: controller.keyFromEmailTagEditor,
        focusNode: controller.focusManager.fromFieldFocusNode,
        nextFocusNode: controller.focusManager.toFieldFocusNode,
      ),
    ),
    (
      field: FilterField.to,
      config: (
        listEmailAddress: (ref) => _toEmailAddresses(ref.watch(
          searchFilterProvider.select((filter) => filter.to))),
        expandMode: (ref) => ref.watch(advancedFilterViewStateProvider.select(
          (state) => state.toAddressExpandMode,
        )),
        textEditingController: controller.toEmailAddressController,
        keyTagEditor: controller.keyToEmailTagEditor,
        focusNode: controller.focusManager.toFieldFocusNode,
        nextFocusNode: controller.focusManager.subjectFieldFocusNode,
      ),
    ),
  ];

  List<({FilterField field, _TextFieldConfig config})> _textFields(
    AppLocalizations appLocalizations,
  ) => [
    (
      field: FilterField.subject,
      config: (
        textEditingController: controller.subjectFilterInputController,
        currentFocusNode: controller.focusManager.subjectFieldFocusNode,
        nextFocusNode: controller.focusManager.hasKeywordFieldFocusNode,
      ),
    ),
    (
      field: FilterField.hasKeyword,
      config: (
        textEditingController: controller.hasKeyWordFilterInputController,
        currentFocusNode: controller.focusManager.hasKeywordFieldFocusNode,
        nextFocusNode: controller.focusManager.notKeywordFieldFocusNode,
      ),
    ),
    (
      field: FilterField.notKeyword,
      config: (
        textEditingController: controller.notKeyWordFilterInputController,
        currentFocusNode: controller.focusManager.notKeywordFieldFocusNode,
        nextFocusNode: controller.focusManager.mailboxFieldFocusNode,
      ),
    ),
  ];

  Widget _buildAddressField(FilterField field, _AddressFieldConfig config) {
    return AdvancedSearchFieldWidget(
      filterField: field,
      useHeight: false,
      child: Consumer(builder: (context, ref, _) {
        final listEmailAddress = config.listEmailAddress(ref);
        return DefaultAutocompleteInputFieldWidget(
          field: field,
          listEmailAddress: listEmailAddress,
          expandMode: config.expandMode(ref),
          minInputLengthAutocomplete: controller
            .mailboxDashBoardController
            .minInputLengthAutocomplete,
          controller: config.textEditingController,
          focusNode: config.focusNode,
          nextFocusNode: config.nextFocusNode,
          keyTagEditor: config.keyTagEditor,
          onShowFullListEmailAddressAction: (field) =>
              controller.showFullEmailAddress(
                field,
                ref.read(advancedFilterViewStateProvider.notifier)),
          onUpdateListEmailAddressAction: (field, listEmailAddress) =>
              controller.updateListEmailAddress(
                field,
                listEmailAddress,
                ref.read(searchFilterProvider.notifier)),
          onSuggestionEmailAddress: controller.getAutoCompleteSuggestion,
          onSearchAction: () => controller.onSearchAction(
            committedFilter: ref.read(searchFilterProvider),
            filterNotifier: ref.read(searchFilterProvider.notifier)),
          onRemoveDraggableEmailAddressAction: (draggableEmailAddress) =>
              controller.removeDraggableEmailAddress(
                draggableEmailAddress,
                ref.read(searchFilterProvider.notifier),
                ref.read(advancedFilterViewStateProvider.notifier)),
        );
      }),
    );
  }

  Widget _buildTextField(
    FilterField field,
    AppLocalizations appLocalizations,
    _TextFieldConfig config,
  ) {
    return AdvancedSearchFieldWidget(
      filterField: field,
      child: Consumer(builder: (context, ref, _) => DefaultInputFieldWithTabKeyWidget(
          textEditingController: config.textEditingController,
          currentFocusNode: config.currentFocusNode,
          nextFocusNode: config.nextFocusNode,
          hintText: field.getHintText(appLocalizations),
          onTextChange: (value) => controller.onTextChanged(
            field,
            value,
            ref.read(searchFilterProvider.notifier)),
        )),
    );
  }

  Widget _buildMailboxField(BuildContext context, AppLocalizations appLocalizations) {
    return AdvancedSearchFieldWidget(
      filterField: FilterField.mailBox,
      child: Consumer(builder: (context, ref, _) {
        final mailbox = ref.watch(searchFilterProvider.select((filter) => filter.mailbox));
        return DefaultButtonArrowDownFieldWithTabKeyWidget(
          text: mailbox?.getFolderNameForQuickSearch(appLocalizations) ?? appLocalizations.allEmail,
          iconArrowDown: controller.imagePaths.icDropDown,
          currentFocusNode: controller.focusManager.mailboxFieldFocusNode,
          nextFocusNode: controller.focusManager.attachmentCheckboxFocusNode,
          onTap: () => controller.selectedMailBox(
            context,
            mailboxSelected: mailbox,
            filterNotifier: ref.read(searchFilterProvider.notifier)),
        );
      }),
    );
  }

  Widget _buildLabelField() {
    return Obx(() {
      final isLabelAvailable =
          controller.mailboxDashBoardController.isLabelAvailable;

      final labels =
          controller.mailboxDashBoardController.labelController.labels;

      if (isLabelAvailable && labels.isNotEmpty) {
        return AdvancedSearchFieldWidget(
          filterField: FilterField.labels,
          padding: const EdgeInsets.only(bottom: 12),
          child: Consumer(builder: (context, ref, _) {
            final labelSelected =
                ref.watch(searchFilterProvider.select((filter) => filter.label));
            return LabelDropDownButton(
              imagePaths: controller.imagePaths,
              labels: labels,
              labelSelected: labelSelected,
              onSelectLabelsActions: (newLabel) {
                ref.read(searchFilterProvider.notifier).toggleLabel(newLabel);
              },
            );
          }),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildDateField() {
    return AdvancedSearchFieldWidget(
      filterField: FilterField.date,
      child: Consumer(builder: (context, ref, _) {
        final filter = ref.watch(searchFilterProvider);
        return DefaultDateDropDownFieldWidget(
          imagePaths: controller.imagePaths,
          receiveTimeTypes: EmailReceiveTimeType.valuesForSearch,
          startDate: filter.startDate?.value.toLocal(),
          endDate: filter.endDate?.value.toLocal(),
          receiveTimeTypeSelected: filter.emailReceiveTimeType,
          onReceiveTimeSelected: (receiveTime) =>
              controller.updateReceiveDateSearchFilter(
                context,
                receiveTime,
                committedFilter: ref.read(searchFilterProvider),
                filterNotifier: ref.read(searchFilterProvider.notifier),
              ),
          onOpenDatPicker: () => controller.selectDateRange(
            context,
            committedFilter: ref.read(searchFilterProvider),
            filterNotifier: ref.read(searchFilterProvider.notifier)),
        );
      }),
    );
  }

  Widget _buildSortByField() {
    return AdvancedSearchFieldWidget(
      filterField: FilterField.sortBy,
      child: Consumer(builder: (context, ref, _) => SortByDropDownButton(
        imagePaths: controller.imagePaths,
        sortOrderSelected: ref.watch(
          searchFilterProvider.select((filter) => filter.sortOrderType)),
        onSortOrderSelected: (sortOrder) {
          if (sortOrder == null) return;
          ref
            .read(searchFilterProvider.notifier)
            .setSortOrder(sortOrder);
        },
      )),
    );
  }

  List<EmailAddress> _toEmailAddresses(Set<String> emails) =>
      emails.map((email) => EmailAddress(null, email)).toList();
}
