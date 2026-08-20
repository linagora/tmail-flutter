class UiKeys {
  const UiKeys._();

  static const String composeEmailButton = 'composeEmailButton';
  static const String sendEmailButton = 'sendEmailButton';
  static const String downloadAllAttachmentsButton = 'download_all_attachments_button';
  static const String listViewAppGrid = 'listViewAppGrid';
  static const String toggleAppGridButton = 'toggleAppGridButton';
  static const String closeComposerButton = 'closeComposerButton';
  static const String saveDraftButton = 'saveDraftButton';
  static const String saveTemplatePopupItem = 'saveAsTemplatePopupItem';
  // Keep snake_case values — existing widgets and tests already reference these key names.
  static const String composerMoreButton = 'composer_more_button';
  /// Button rendered by ComposeButtonWidget. The widget itself is keyed with
  /// [composeEmailButton] by its callers.
  static const String composeEmailPrimaryAction = 'compose_email_button';
  static const String saveDraftPopupItem = 'save_as_draft_popup_item';
  static const String emptyThreadView = 'empty_thread_view';
  static const String emptySearchEmailView = 'empty_search_email_view';
  static const String searchFilterListView = 'search_filter_list_view';
  // Suggestion-overlay chips; compose with the filter name. Distinct from the result-bar keys.
  static const String quickSearchFilterButtonPrefix = 'quick_search_filter_button_';

  // Email rules / rules filter creator
  static const String createRuleButton = 'createRuleButton';
  static const String emailRulesSettingMenuItem = 'setting_email_rules';
  static const String editEmailRuleButton = 'editEmailRuleButton';
  static const String moreEmailRuleButton = 'moreEmailRuleButton';
  static const String addActionButton = 'addActionButton';
  static const String mobileMailboxMenuButton = 'mobileMailboxMenuButton';
  static const String userAvatar = 'userAvatar';

  // Advanced search
  static const String openAdvancedSearchButton = 'open_advanced_search_button';
  static const String advancedSearchLabelDropDown = 'advanced_search_label_drop_down';
  static const String advancedSearchSearchButton = 'advanced_search_search_button';
  static const String advancedSearchHasAttachmentCheckbox = 'advanced_search_has_attachment_checkbox';

  static const String mailboxMoreActionButton = 'mailbox_more_action_button';
  static const String mailboxSearchButton = 'mailbox_search_button';
  static const String addNewFolderButton = 'add_new_folder_button';
  static const String addNewLabelButton = 'labels_bar_widget_add_new_label_button';
  static const String cleanMessageBannerNotVisible = 'clean_message_banner_not_visible';
}
