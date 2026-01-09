import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tmail_ui_user/l10n/messages_all.dart';

class AppLocalizations {

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final name = locale.countryCode == null ? locale.languageCode : locale.toString();

    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  String get initializing_data {
    return Intl.message('Initializing data...',
      name: 'initializing_data');
  }

  String get login_text_slogan {
    return Intl.message('Twake Mail',
        name: 'login_text_slogan');
  }

  String get loginInputUrlMessage {
    return Intl.message('To login and access your message please connect to your JMAP server', name: 'loginInputUrlMessage');
  }

  String get loginInputCredentialMessage {
    return Intl.message('Enter your credentials to sign in', name: 'loginInputCredentialMessage');
  }
  
  String get badCredentials {
    return Intl.message('Bad credentials', name: 'badCredentials');
  }

  String get next {
    return Intl.message('Next', name: 'next');
  }

  String get prefix_https {
    return Intl.message('https://',
        name: 'prefix_https');
  }

  String get email {
    return Intl.message('email',
        name: 'email');
  }

  String get password {
    return Intl.message('password',
        name: 'password');
  }

  String get login {
    return Intl.message('Login',
        name: 'login');
  }

  String get signIn {
    return Intl.message('Sign In',
        name: 'signIn');
  }

  String get requiredEmail {
    return Intl.message('Email is required',
        name: 'requiredEmail');
  }

  String get requiredPassword {
    return Intl.message('Password is required',
        name: 'requiredPassword');
  }

  String get requiredUrl {
    return Intl.message('Server address is required',
        name: 'requiredUrl');
  }

  String get jmapBasedMailSolution {
    return Intl.message('JMAP-based\ncollaborative team mail solution',
        name: 'jmapBasedMailSolution');
  }

  String get jmapStandard {
    return Intl.message('JMAP standard',
        name: 'jmapStandard');
  }

  String get encryptedMailbox {
    return Intl.message('Encrypted mailbox',
      name: 'encryptedMailbox');
  }

  String get manageEmailAsATeam {
    return Intl.message('Manage email as a team',
      name: 'manageEmailAsATeam');
  }

  String get multipleIntegrations {
    return Intl.message('Multiple integrations', name: 'multipleIntegrations');
  }

  String get unknownError {
    return Intl.message('Unknown error occurred, please try again',
        name: 'unknownError');
  }

  String unexpectedError(String errorMessage) {
    return Intl.message('Unexpected error: $errorMessage',
        name: 'unexpectedError',
        args: [errorMessage]);
  }

  String handshakeException(String errorMessage) {
    return Intl.message(
      'Handshake error in client: $errorMessage',
      name: 'handshakeException',
      args: [errorMessage]);
  }

  String get search_folder {
    return Intl.message(
      'Search folder',
      name: 'search_folder',
    );
  }

  String get personalFolders {
    return Intl.message(
      'Personal folders',
      name: 'personalFolders',
    );
  }

  String get new_folder {
    return Intl.message(
      'New folder',
      name: 'new_folder',
    );
  }

  String get reply_all {
    return Intl.message(
      'Reply all',
      name: 'reply_all',
    );
  }

  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
    );
  }

  String get forward {
    return Intl.message(
      'Forward',
      name: 'forward',
    );
  }

  String get no_mail_selected {
    return Intl.message(
      'No email selected',
      name: 'no_mail_selected',
    );
  }

  String get from_email_address_prefix {
    return Intl.message(
      'From',
      name: 'from_email_address_prefix',
    );
  }

  String get to_email_address_prefix {
    return Intl.message(
      'To',
      name: 'to_email_address_prefix',
    );
  }

  String get unread_email_notification {
    return Intl.message(
      'new',
      name: 'unread_email_notification',
    );
  }

  String get bcc_email_address_prefix {
    return Intl.message(
      'Bcc',
      name: 'bcc_email_address_prefix',
    );
  }

  String get reply_to_email_address_prefix {
    return Intl.message(
      'Reply to',
      name: 'reply_to_email_address_prefix',
    );
  }

  String get cc_email_address_prefix {
    return Intl.message(
      'Cc',
      name: 'cc_email_address_prefix',
    );
  }

  String get hint_text_email_address {
    return Intl.message(
      'Name or email address',
      name: 'hint_text_email_address',
    );
  }

  String get subject_email {
    return Intl.message(
      'Subject',
      name: 'subject_email',
    );
  }

  String get hint_content_email_composer {
    return Intl.message(
      'Start writing your email here',
      name: 'hint_content_email_composer',
    );
  }

  String header_email_quoted(String sentDate, String emailAddress) {
    return Intl.message(
        'On $sentDate, from $emailAddress',
        name: 'header_email_quoted',
        args: [sentDate, emailAddress]
    );
  }

  String get prefix_reply_email {
    return Intl.message(
      'Re:',
      name: 'prefix_reply_email',
    );
  }

  String get prefix_forward_email {
    return Intl.message(
      'Fwd:',
      name: 'prefix_forward_email',
    );
  }

  String get your_email_being_sent {
    return Intl.message(
      'Your email being sent...',
      name: 'your_email_being_sent',
    );
  }

  String get message_dialog_send_email_without_recipient {
    return Intl.message(
      'Your email should have at least one recipient',
      name: 'message_dialog_send_email_without_recipient',
    );
  }

  String count_email_selected(int count) {
    return Intl.message(
        '$count selected',
        name: 'count_email_selected',
        args: [count]
    );
  }

  String get mark_as_unread {
    return Intl.message(
      'Mark as unread',
      name: 'mark_as_unread',
    );
  }

  String get mark_as_read {
    return Intl.message(
      'Mark as read',
      name: 'mark_as_read',
    );
  }

  String get move_to_trash {
    return Intl.message(
      'Move to trash',
      name: 'move_to_trash',
    );
  }

  String get mark_as_starred {
    return Intl.message(
      'Mark as starred',
      name: 'mark_as_starred',
    );
  }

  String get move_to_spam {
    return Intl.message(
      'Move to spam',
      name: 'move_to_spam',
    );
  }

  String marked_multiple_item_as_read(int count) {
    return Intl.message(
        'Marked $count item as read',
        name: 'marked_multiple_item_as_read',
        args: [count]
    );
  }

  String marked_multiple_item_as_unread(int count) {
    return Intl.message(
        'Marked $count item as unread',
        name: 'marked_multiple_item_as_unread',
        args: [count]
    );
  }

  String get an_error_occurred {
    return Intl.message(
      'Error! An error occurred. Please try again later.',
      name: 'an_error_occurred',
    );
  }

  String get attachment_download_failed {
    return Intl.message(
      'Attachment download failed',
      name: 'attachment_download_failed',
    );
  }

  String downloading_file(String fileName) {
    return Intl.message(
      'Downloading $fileName',
      name: 'downloading_file',
      args: [fileName]
    );
  }

  String get preparing_to_export {
    return Intl.message(
      'Preparing to export',
      name: 'preparing_to_export'
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel'
    );
  }

  String get user_cancel_download_file {
    return Intl.message(
      'User cancel download file',
      name: 'user_cancel_download_file'
    );
  }

  String get you_need_to_grant_files_permission_to_download_attachments {
    return Intl.message(
      'You need to grant files permission to download attachments',
      name: 'you_need_to_grant_files_permission_to_download_attachments'
    );
  }

  String titleHeaderAttachment(int count, String totalSize) {
    return Intl.message(
        '$count Attachments ($totalSize)',
        name: 'titleHeaderAttachment',
        args: [count, totalSize]
    );
  }

  String singularAttachmentTitleHeader(int count, String totalSize) {
    return Intl.message(
        '$count Attachment ($totalSize)',
        name: 'singularAttachmentTitleHeader',
        args: [count, totalSize]
    );
  }

  String get attach_file_prepare_text {
    return Intl.message(
      'Preparing to attach file...',
      name: 'attach_file_prepare_text'
    );
  }

  String get can_not_upload_this_file_as_attachments {
    return Intl.message(
      'Can not upload this file as attachments',
      name: 'can_not_upload_this_file_as_attachments'
    );
  }

  String get attachments_uploaded_successfully {
    return Intl.message(
      'Attachments uploaded successfully',
      name: 'attachments_uploaded_successfully'
    );
  }

  String get pick_attachments {
    return Intl.message(
      'Pick attachments',
      name: 'pick_attachments'
    );
  }

  String get photos_and_videos {
    return Intl.message(
      'Photos and Videos',
      name: 'photos_and_videos',
    );
  }

  String get browse {
    return Intl.message(
      'Browse',
      name: 'browse',
    );
  }

  String movedToFolder(String destinationMailboxPath) {
    return Intl.message(
        'Moved to $destinationMailboxPath',
        name: 'movedToFolder',
        args: [destinationMailboxPath]
    );
  }

  String get undo {
    return Intl.message(
        'Undo',
        name: 'undo'
    );
  }

  String marked_star_multiple_item(int count) {
    return Intl.message(
        'Marked star $count item',
        name: 'marked_star_multiple_item',
        args: [count]
    );
  }

  String marked_unstar_multiple_item(int count) {
    return Intl.message(
        'Marked unstar $count item',
        name: 'marked_unstar_multiple_item',
        args: [count]
    );
  }

  String get search_mail {
    return Intl.message(
      'Search mail',
      name: 'search_mail',
    );
  }

  String get prefix_suggestion_search {
    return Intl.message(
      'Search for',
      name: 'prefix_suggestion_search',
    );
  }

  String get no_emails_matching_your_search {
    return Intl.message(
      'No emails are matching your search',
      name: 'no_emails_matching_your_search',
    );
  }

  String get results {
    return Intl.message(
      'Results',
      name: 'results',
    );
  }

  String get edit {
    return Intl.message('Edit',
        name: 'edit');
  }

  String get hint_search_emails {
    return Intl.message(
        'Search for emails and files',
        name: 'hint_search_emails');
  }

  String get compose {
    return Intl.message(
        'Compose',
        name: 'compose');
  }

  String get delete {
    return Intl.message(
        'Delete',
        name: 'delete');
  }

  String get move {
    return Intl.message(
        'Move',
        name: 'move');
  }

  String get spam {
    return Intl.message(
        'Spam',
        name: 'spam');
  }

  String get flag {
    return Intl.message(
        'Flag',
        name: 'flag');
  }

  String get read {
    return Intl.message(
        'Read',
        name: 'read');
  }

  String get unread {
    return Intl.message(
        'Unread',
        name: 'unread');
  }

  String get the_feature_is_under_development {
    return Intl.message(
        'This feature is under development.',
        name: 'the_feature_is_under_development');
  }

  String marked_message_toast(String action) {
    return Intl.message(
        'You’ve marked messages as "$action"',
        name: 'marked_message_toast',
        args: [action]
    );
  }

  String get folders {
    return Intl.message(
        'Folders',
        name: 'folders'
    );
  }

  String get sign_out {
    return Intl.message('Sign out',
        name: 'sign_out');
  }

  String get hintSearchFolders {
    return Intl.message(
        'Search folders',
        name: 'hintSearchFolders');
  }

  String get with_attachments {
    return Intl.message(
        'With attachments',
        name: 'with_attachments'
    );
  }

  String get starred {
    return Intl.message(
        'Starred',
        name: 'starred'
    );
  }

  String filter_message_toast(String filterOption) {
    return Intl.message(
        'You’ve filtered messages by "$filterOption"',
        name: 'filter_message_toast',
        args: [filterOption]
    );
  }

  String get disable_filter_message_toast {
    return Intl.message(
        'You’ve disabled filtered messages',
        name: 'disable_filter_message_toast'
    );
  }

  String get with_unread {
    return Intl.message(
        'With Unread',
        name: 'with_unread');
  }

  String get with_starred {
    return Intl.message(
        'With Starred',
        name: 'with_starred');
  }

  String get message_has_been_sent_successfully {
    return Intl.message(
      'Message has been sent successfully',
      name: 'message_has_been_sent_successfully',
    );
  }

  String get done {
    return Intl.message(
        'Done',
        name: 'done'
    );
  }

  String get newFolder {
    return Intl.message(
      'New folder',
      name: 'newFolder',
    );
  }

  String get nameOfFolderIsRequired {
    return Intl.message(
      'Name of folder is required',
      name: 'nameOfFolderIsRequired',
    );
  }

  String get folderNameCannotContainSpecialCharacters {
    return Intl.message(
      'Folder name cannot contain special characters',
      name: 'folderNameCannotContainSpecialCharacters',
    );
  }

  String get this_folder_name_is_already_taken {
    return Intl.message(
      'This folder name is already taken',
      name: 'this_folder_name_is_already_taken',
    );
  }

  String new_folder_is_created(String nameMailbox) {
    return Intl.message(
        '$nameMailbox is created',
        name: 'new_folder_is_created',
        args: [nameMailbox]
    );
  }

  String get createNewFolderFailure {
    return Intl.message(
        'Create new folder failure',
        name: 'createNewFolderFailure'
    );
  }

  String get drafts_saved {
    return Intl.message(
      'Draft saved',
      name: 'drafts_saved',
    );
  }

  String get discard {
    return Intl.message(
        'Discard',
        name: 'discard'
    );
  }

  String get skip {
    return Intl.message(
        'Skip',
        name: 'skip'
    );
  }

  String get hintInputCreateNewFolder {
    return Intl.message(
        'Enter name of folder',
        name: 'hintInputCreateNewFolder'
    );
  }

  String get rename {
    return Intl.message(
        'Rename',
        name: 'rename');
  }

  String get deleteFoldersSuccessfully {
    return Intl.message(
        'Delete folders successfully',
        name: 'deleteFoldersSuccessfully');
  }

  String get deleteFoldersFailure {
    return Intl.message(
        'Delete folders failure',
        name: 'deleteFoldersFailure');
  }

  String get deleteFolders {
    return Intl.message(
        'Delete folders',
        name: 'deleteFolders');
  }

  String message_confirmation_dialog_delete_folder(String nameMailbox) {
    return Intl.message(
        '"$nameMailbox" folder and all of the sub-folders and messages it contains will be deleted and won\'t be able to recover. Do you want to continue to delete?',
        name: 'message_confirmation_dialog_delete_folder',
        args: [nameMailbox]
    );
  }

  String message_confirmation_dialog_allow_subaddressing(String nameMailbox) {
    return Intl.message(
        'You are about to allow anyone to send emails directly to your folder "$nameMailbox" using:',
        name: 'message_confirmation_dialog_allow_subaddressing',
        args: [nameMailbox]
    );
  }

  String message_confirmation_dialog_allow_subaddressing_mobile(String nameMailbox, String address) {
    return Intl.message(
        'You are about to allow anyone to send emails directly to your folder "$nameMailbox" using the address <$address>',
        name: 'message_confirmation_dialog_allow_subaddressing_mobile',
        args: [nameMailbox, address]
    );
  }

  String get renameFolder {
    return Intl.message(
      'Rename folder',
      name: 'renameFolder');
  }

  String get renameFolderFailure {
    return Intl.message(
      'Rename folder failure',
      name: 'renameFolderFailure');
  }

  String get this_field_cannot_be_blank {
    return Intl.message(
      'This field cannot be blank',
      name: 'this_field_cannot_be_blank',
    );
  }

  String get there_is_already_folder_with_the_same_name {
    return Intl.message(
      'There is already folder with the same name',
      name: 'there_is_already_folder_with_the_same_name',
    );
  }

  String get email_address_is_not_in_the_correct_format {
    return Intl.message(
      'Email address is not in the correct format',
      name: 'email_address_is_not_in_the_correct_format',
    );
  }

  String get preparing_to_save {
    return Intl.message(
        'Preparing to save',
        name: 'preparing_to_save'
    );
  }

  String get new_message {
    return Intl.message(
      'New message',
      name: 'new_message',
    );
  }

  String get hide {
    return Intl.message(
        'Hide',
        name: 'hide');
  }

  String get compose_email {
    return Intl.message(
        'Compose email',
        name: 'compose_email');
  }

  String get email_address_copied_to_clipboard {
    return Intl.message(
        'Email address copied to clipboard',
        name: 'email_address_copied_to_clipboard');
  }

  String get emailSubaddressCopiedToClipboard {
    return Intl.message(
        'Email subaddress copied to clipboard',
        name: 'emailSubaddressCopiedToClipboard');
  }

  String get minimize {
    return Intl.message(
        'Minimize',
        name: 'minimize');
  }

  String get fullscreen {
    return Intl.message(
        'Fullscreen',
        name: 'fullscreen');
  }

  String get close {
    return Intl.message(
        'Close',
        name: 'close');
  }

  String get send {
    return Intl.message(
        'Send',
        name: 'send');
  }

  String get attachments {
    return Intl.message(
        'Attachments',
        name: 'attachments');
  }

  String get attachment {
    return Intl.message(
      'Attachment',
      name: 'attachment',
    );
  }

  String get showAll {
    return Intl.message(
        'Show all',
        name: 'showAll');
  }

  String get message_dialog_send_email_without_a_subject {
    return Intl.message(
        'Are you sure to send messages without a subject?',
        name: 'message_dialog_send_email_without_a_subject');
  }

  String get app_name {
    return Intl.message(
        'Twake Mail',
        name: 'app_name');
  }

  String get search_emails {
    return Intl.message(
        'Search emails',
        name: 'search_emails');
  }

  String get select_all {
    return Intl.message(
      'Select all',
      name: 'select_all',
    );
  }

  String get filter_messages {
    return Intl.message(
      'Filter messages',
      name: 'filter_messages',
    );
  }

  String get not_starred {
    return Intl.message(
        'Not starred',
        name: 'not_starred'
    );
  }

  String get select {
    return Intl.message(
      'Select',
      name: 'select',
    );
  }

    String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
    );
  }

  String get notSelected {
    return Intl.message(
      'Not selected',
      name: 'notSelected',
    );
  }

  String get more {
    return Intl.message(
      'More',
      name: 'more',
    );
  }

  String get back {
    return Intl.message(
      'Back',
      name: 'back',
    );
  }

  String get expand {
    return Intl.message(
        'Expand',
        name: 'expand');
  }

  String get collapse {
    return Intl.message(
        'Collapse',
        name: 'collapse');
  }

  String get save_to_drafts {
    return Intl.message(
      'Save to drafts',
      name: 'save_to_drafts',
    );
  }

  String get hint_compose_email {
    return Intl.message(
        'Start composing a letter...',
        name: 'hint_compose_email');
  }

  String get attach_file {
    return Intl.message(
        'Attach file',
        name: 'attach_file');
  }

  String get show {
    return Intl.message(
        'Show',
        name: 'show');
  }

  String get add_recipients {
    return Intl.message(
        'Add recipients',
        name: 'add_recipients');
  }

  String get sending_failed {
    return Intl.message(
        'Sending failed',
        name: 'sending_failed');
  }

  String get send_anyway {
    return Intl.message(
        'Send anyway',
        name: 'send_anyway');
  }

  String get empty_subject {
    return Intl.message(
        'Empty subject',
        name: 'empty_subject');
  }

  String get message_dialog_send_email_with_email_address_invalid {
    return Intl.message(
        'Check the correctness of email addresses and try again',
        name: 'message_dialog_send_email_with_email_address_invalid');
  }

  String get fix_email_addresses {
    return Intl.message(
        'Fix email addresses',
        name: 'fix_email_addresses');
  }

  String get your_download_has_started {
    return Intl.message(
        'Your download has started',
        name: 'your_download_has_started'
    );
  }

  String get moved_to_trash {
    return Intl.message(
        'Moved to Trash',
        name: 'moved_to_trash'
    );
  }

  String get no_internet_connection {
    return Intl.message(
        'No internet connection',
        name: 'no_internet_connection'
    );
  }

  String get no_internet_connection_try_again_later {
    return Intl.message(
      'No internet connection, try again later.',
      name: 'no_internet_connection_try_again_later'
    );
  }

  String get page_name {
    return Intl.message(
        'Twake Mail',
        name: 'page_name');
  }

  String get message_delete_all_email_in_trash_button {
    return Intl.message(
        'All messages in Trash will be deleted if you reach limited storage.',
        name: 'message_delete_all_email_in_trash_button');
  }

  String get empty_trash_now {
    return Intl.message(
        'Empty trash now',
        name: 'empty_trash_now');
  }

  String get empty_trash_folder {
    return Intl.message(
        'Empty trash folder',
        name: 'empty_trash_folder');
  }

  String get empty_trash_dialog_message {
    return Intl.message(
        'You are about to permanently delete all items in Trash. Do you want to continue?',
        name: 'empty_trash_dialog_message');
  }

  String get delete_all {
    return Intl.message(
        'Delete all',
        name: 'delete_all');
  }

  String toast_message_delete_multiple_email_permanently_success(int count) {
    return Intl.message(
        '$count Messages has been deleted forever',
        name: 'toast_message_delete_multiple_email_permanently_success',
        args: [count]);
  }

  String get toast_message_delete_a_email_permanently_success {
    return Intl.message(
        'Message has been deleted forever',
        name: 'toast_message_delete_a_email_permanently_success');
  }

  String get delete_permanently {
    return Intl.message(
        'Delete permanently',
        name: 'delete_permanently');
  }

  String get delete_messages_forever {
    return Intl.message(
        'Delete messages forever',
        name: 'delete_messages_forever');
  }

  String get delete_message_forever {
    return Intl.message(
        'Delete message forever',
        name: 'delete_message_forever');
  }

  String delete_multiple_messages_dialog(int count, String mailboxName) {
    return Intl.message(
        'You are about to permanently delete $count items in $mailboxName. Do you want to continue?',
        name: 'delete_multiple_messages_dialog',
        args: [count, mailboxName]);
  }

  String get delete_single_message_dialog {
    return Intl.message(
        'You are about to permanently delete this message. Do you want to continue?',
        name: 'delete_single_message_dialog');
  }

  String get toast_message_empty_trash_folder_success {
    return Intl.message(
        'All messages has been deleted forever',
        name: 'toast_message_empty_trash_folder_success');
  }

  String get version {
    return Intl.message(
        'Version',
        name: 'version');
  }

  String message_dialog_send_email_exceeds_maximum_size(String maxSize) {
    return Intl.message(
        'Your message could not be sent because it exceeds the maximum size of $maxSize',
        name: 'message_dialog_send_email_exceeds_maximum_size',
        args: [maxSize]
    );
  }

  String message_dialog_upload_attachments_exceeds_maximum_size(String maxSize) {
    return Intl.message(
        'You have reached the maximum file size. Please upload files that total size is less than $maxSize',
        name: 'message_dialog_upload_attachments_exceeds_maximum_size',
        args: [maxSize]
    );
  }

  String get got_it {
    return Intl.message(
        'Got it',
        name: 'got_it');
  }

  String get maximum_files_size {
    return Intl.message(
        'Maximum files size',
        name: 'maximum_files_size');
  }

  String get exchange {
    return Intl.message(
        'Exchange',
        name: 'exchange'
    );
  }

  String get forwarded_message {
    return Intl.message(
      'Forwarded message',
      name: 'forwarded_message',
    );
  }

  String get date {
    return Intl.message(
      'Date',
      name: 'date',
    );
  }

  String get mark_as_spam {
    return Intl.message(
      'Mark as spam',
      name: 'mark_as_spam',
    );
  }

  String get remove_from_spam {
    return Intl.message(
      'Remove from spam',
      name: 'remove_from_spam',
    );
  }

  String get marked_as_spam {
    return Intl.message(
      'Marked as spam',
      name: 'marked_as_spam',
    );
  }

  String get marked_as_not_spam {
    return Intl.message(
      'Marked as not spam',
      name: 'marked_as_not_spam',
    );
  }

  String get star {
    return Intl.message(
      'Star',
      name: 'star',
    );
  }

  String get un_star {
    return Intl.message(
      'Unstar',
      name: 'un_star',
    );
  }

  String get un_spam {
    return Intl.message(
      'Unspam',
      name: 'un_spam',
    );
  }

  String get settings {
    return Intl.message('Settings',
        name: 'settings');
  }

  String get manage_account {
    return Intl.message('Manage account',
        name: 'manage_account');
  }

  String get profiles {
    return Intl.message('Profiles',
        name: 'profiles');
  }

  String get profilesSettingExplanation {
    return Intl.message(
      'Info about you, and options to manage it.',
      name: 'profilesSettingExplanation'
    );
  }

  String get identities {
    return Intl.message('Identities',
        name: 'identities');
  }

  String get setDefaultIdentity {
    return Intl.message(
        'Set as default identity',
        name: 'setDefaultIdentity'
    );
  }

  String get identitiesSettingExplanation {
    return Intl.message(
      'Select the identity or email address you want to use to send an emails',
      name: 'identitiesSettingExplanation');
  }

  String get createNewIdentity {
    return Intl.message(
      'Create new identity',
      name: 'createNewIdentity');
  }

  String get new_identity {
    return Intl.message('New Identity',
        name: 'new_identity');
  }

  String get name {
    return Intl.message(
        'Name',
        name: 'name');
  }

  String get nameToBeDisplayed {
    return Intl.message(
        'Name to be displayed to recipients',
        name: 'nameToBeDisplayed');
  }

  String get reply_to {
    return Intl.message(
        'Reply to',
        name: 'reply_to');
  }

  String get bcc_to {
    return Intl.message(
        'Bcc to',
        name: 'bcc_to');
  }

  String get signature {
    return Intl.message(
        'Signature',
        name: 'signature');
  }

  String get html_template {
    return Intl.message(
        'Html template',
        name: 'html_template');
  }

  String get html {
    return Intl.message(
        'Html',
        name: 'html');
  }

  String get create {
    return Intl.message(
        'Create',
        name: 'create');
  }

  String get you_have_created_a_new_identity {
    return Intl.message(
        'You have created a new identity',
        name: 'you_have_created_a_new_identity');
  }

  String get you_have_created_a_new_default_identity {
    return Intl.message(
        'You have created a new default identity',
        name: 'you_have_created_a_new_default_identity');
  }

  String get all_identities {
    return Intl.message(
        'All identities',
        name: 'all_identities');
  }

  String get default_value {
    return Intl.message(
      'Default',
      name: 'default_value',
    );
  }

  String get delete_identity {
    return Intl.message('Delete identity',
        name: 'delete_identity');
  }

  String get message_confirmation_dialog_delete_identity {
    return Intl.message('Are you sure you want to delete this identity?',
        name: 'message_confirmation_dialog_delete_identity');
  }

  String get identity_has_been_deleted {
    return Intl.message('Identity has been deleted',
        name: 'identity_has_been_deleted');
  }

  String get delete_failed {
    return Intl.message('Delete Failed',
        name: 'delete_failed');
  }

  String get edit_identity {
    return Intl.message('Edit identity',
        name: 'edit_identity');
  }

  String get you_are_changed_your_identity_successfully {
    return Intl.message('You’ve changed your identity successfully',
        name: 'you_are_changed_your_identity_successfully');
  }

  String get save {
    return Intl.message(
        'Save',
        name: 'save');
  }

  String get hasAttachment {
    return Intl.message(
        'Has attachment',
        name: 'hasAttachment');
  }

  String get last7Days {
    return Intl.message(
        'Last 7 days',
        name: 'last7Days');
  }

  String get last15Days {
    return Intl.message(
        'Last 15 days',
        name: 'last15Days');
  }

  String get fromMe {
    return Intl.message(
        'From me',
        name: 'fromMe');
  }

  String get recent {
    return Intl.message(
        'Recent',
        name: 'recent');
  }

  String get showingResultsFor {
    return Intl.message(
        'Showing results for:',
        name: 'showingResultsFor');
  }

  String get last30Days {
    return Intl.message(
        'Last 30 days',
        name: 'last30Days');
  }

  String get last6Months {
    return Intl.message(
        'Last 6 months',
        name: 'last6Months');
  }

  String get lastYears {
    return Intl.message(
        'Last years',
        name: 'lastYears');
  }

  String get thisEmailAddressInvalid {
    return Intl.message(
      'This email address invalid',
      name: 'thisEmailAddressInvalid',
    );
  }

  String get loginInputSSOMessage {
    return Intl.message(
        'Sign-in with my SSO account',
        name: 'loginInputSSOMessage');
  }

  String get canNotVerifySSOConfiguration {
    return Intl.message(
        'Can not verify SSO configuration, please check with your system administrator',
        name: 'canNotVerifySSOConfiguration');
  }

  String get canNotGetToken {
    return Intl.message(
        'Can not get token, please check with your system administrator',
        name: 'canNotGetToken');
  }

  String get moveFolder {
    return Intl.message(
      'Move folder',
      name: 'moveFolder',
    );
  }

  String get deleteFolder {
    return Intl.message(
        'Delete folder',
        name: 'deleteFolder');
  }

  String toastMessageMarkAsMailboxReadSuccess(String mailboxName) {
    return Intl.message(
        'You’ve marked all messages in "$mailboxName" as read',
        name: 'toastMessageMarkAsMailboxReadSuccess',
        args: [mailboxName]);
  }

  String toastMessageMarkAsMailboxReadHasSomeEmailFailure(String mailboxName, int count) {
    return Intl.message(
        'You’ve marked $count messages in "$mailboxName" as read',
        name: 'toastMessageMarkAsMailboxReadHasSomeEmailFailure',
        args: [mailboxName, count]);
  }

  String get allFolders {
    return Intl.message(
        'All folders',
        name: 'allFolders');
  }

  String get singleSignOn {
    return Intl.message('Single Sign-On',
        name: 'singleSignOn');
  }

  String get ssoNotAvailable {
    return Intl.message('Single sign-on (SSO) is not available',
        name: 'ssoNotAvailable');
  }

  String get noPreviewAvailable {
    return Intl.message(
      'No preview available',
      name: 'noPreviewAvailable',
    );
  }

  String get wrongUrlMessage {
    return Intl.message('Server URL is not valid, please try again',
        name: 'wrongUrlMessage');
  }

  String get subject {
    return Intl.message(
      'Subject',
      name: 'subject',
    );
  }

  String get hasTheWords {
    return Intl.message(
      'Has the words',
      name: 'hasTheWords',
    );
  }

  String get doesNotHave {
    return Intl.message(
      'Doesn’t have',
      name: 'doesNotHave',
    );
  }

  String get folder {
    return Intl.message(
      'Folder',
      name: 'folder',
    );
  }

  String get nameOrEmailAddress {
    return Intl.message(
      'Name or email address',
      name: 'nameOrEmailAddress',
    );
  }

  String get enterSearchTerm {
    return Intl.message(
      'Enter search term',
      name: 'enterSearchTerm',
    );
  }

  String get allTime {
    return Intl.message(
      'All time',
      name: 'allTime',
    );
  }

  String get search {
    return Intl.message(
      'Search',
      name: 'search',
    );
  }

  String get clearFilter {
    return Intl.message(
      'Clear filter',
      name: 'clearFilter',
    );
  }

  String get advancedSearch {
    return Intl.message(
      'Advanced search',
      name: 'advancedSearch',
    );
  }

  String get selectFolder {
    return Intl.message(
      'Select Folder',
      name: 'selectFolder',
    );
  }

  String get messageDuplicateTagFilterMail {
    return Intl.message(
      'you already entered that',
      name: 'messageDuplicateTagFilterMail',
    );
  }

  String get languageAndRegion {
    return Intl.message(
        'Language & Region',
        name: 'languageAndRegion');
  }

  String get languageSubtitle {
    return Intl.message(
        'Set the language you use on Twake Mail.',
        name: 'languageSubtitle');
  }

  String get language {
    return Intl.message(
        'Language',
        name: 'language');
  }

  String get languageEnglish {
    return Intl.message(
        'English',
        name: 'languageEnglish');
  }

  String get languageGerman {
    return Intl.message(
        'German',
        name: 'languageGerman');
  }

  String get languageVietnamese {
    return Intl.message(
        'Vietnamese',
        name: 'languageVietnamese');
  }

  String get languageFrench {
    return Intl.message(
        'French',
        name: 'languageFrench');
  }

  String get languageRussian {
    return Intl.message(
        'Russian',
        name: 'languageRussian');
  }

  String get languageArabic {
    return Intl.message(
        'Arabic',
        name: 'languageArabic');
  }

  String get languageItalian {
    return Intl.message(
      'Italian',
      name: 'languageItalian');
  }

  String get messageDialogSendEmailUploadingAttachment {
    return Intl.message(
        'Your message could not be sent because it uploading attachment',
        name: 'messageDialogSendEmailUploadingAttachment'
    );
  }

  String get saveAndClose {
    return Intl.message(
        'Save & close',
        name: 'saveAndClose');
  }

  String get insertImage {
    return Intl.message(
        'Insert image',
        name: 'insertImage');
  }

  String get selectFromFile {
    return Intl.message(
      'Select from file',
      name: 'selectFromFile',
    );
  }

  String get chooseImage {
    return Intl.message(
      'Choose image',
      name: 'chooseImage',
    );
  }

  String get urlLink {
    return Intl.message(
      'URL',
      name: 'urlLink',
    );
  }

  String get insert {
    return Intl.message(
        'Insert',
        name: 'insert');
  }

  String get insertImageErrorFileEmpty {
    return Intl.message(
        'Please either choose an image or enter an image URL',
        name: 'insertImageErrorFileEmpty');
  }

  String get insertImageErrorDuplicate {
    return Intl.message(
        'Please input either an image or an image URL, not both',
        name: 'insertImageErrorDuplicate');
  }

  String get chooseAColor {
    return Intl.message(
        'Choose a color',
        name: 'chooseAColor');
  }

  String get resetToDefault {
    return Intl.message(
        'Reset to default',
        name: 'resetToDefault');
  }

  String get setColor {
    return Intl.message(
        'Set color',
        name: 'setColor');
  }

  String get formatBold {
    return Intl.message(
        'Bold',
        name: 'formatBold');
  }

  String get formatItalic {
    return Intl.message(
        'Italic',
        name: 'formatItalic');
  }

  String get formatUnderline {
    return Intl.message(
        'Underline',
        name: 'formatUnderline');
  }

  String get formatStrikethrough {
    return Intl.message(
        'Strikethrough',
        name: 'formatStrikethrough');
  }

  String get formatTextColor {
    return Intl.message(
        'Text Color',
        name: 'formatTextColor');
  }

  String get formatTextBackgroundColor {
    return Intl.message(
        'Text Background Color',
        name: 'formatTextBackgroundColor');
  }

  String get headerStyle {
    return Intl.message(
        'Style',
        name: 'headerStyle');
  }

  String get fontFamily {
    return Intl.message(
        'Font Family',
        name: 'fontFamily');
  }

  String get paragraph {
    return Intl.message(
        'Paragraph',
        name: 'paragraph');
  }

  String get alignLeft {
    return Intl.message(
        'Align left',
        name: 'alignLeft');
  }

  String get alignRight {
    return Intl.message(
        'Align right',
        name: 'alignRight');
  }

  String get alignCenter {
    return Intl.message(
        'Align center',
        name: 'alignCenter');
  }

  String get justifyFull {
    return Intl.message(
        'Justify full',
        name: 'justifyFull');
  }

  String get outdent {
    return Intl.message(
        'Outdent',
        name: 'outdent');
  }

  String get indent {
    return Intl.message(
        'Indent',
        name: 'indent');
  }

  String get orderList {
    return Intl.message(
        'Order list',
        name: 'orderList');
  }

  String get numberedList {
    return Intl.message(
        'Numbered list',
        name: 'numberedList');
  }

  String get bulletedList {
    return Intl.message(
        'Bulleted list',
        name: 'bulletedList');
  }

  String get moveTo {
    return Intl.message(
      'Move To',
      name: 'moveTo',
    );
  }

  String get emailRules {
    return Intl.message(
      'Email Rules',
      name: 'emailRules',
    );
  }

  String get addNewRule {
    return Intl.message(
      'Add rule',
      name: 'addNewRule',
    );
  }

  String get headerNameOfRules {
    return Intl.message(
      'Name of Rules',
      name: 'headerNameOfRules',
    );
  }

  String get editRule {
    return Intl.message(
      'Edit rule',
      name: 'editRule',
    );
  }

  String get deleteRule {
    return Intl.message(
      'Delete rule',
      name: 'deleteRule',
    );
  }

  String get createNewRule {
    return Intl.message(
        'Create new rule',
        name: 'createNewRule');
  }

  String get rulesNameHintTextInput {
    return Intl.message(
        'Enter the rule name',
        name: 'rulesNameHintTextInput');
  }

  String get conditionValueHintTextInput {
    return Intl.message(
        'Value',
        name: 'conditionValueHintTextInput');
  }

  String get conditionTitleRulesFilter {
    return Intl.message(
        'If all of the following conditions are met:',
        name: 'conditionTitleRulesFilter');
  }

  String get recipient {
    return Intl.message(
        'Recipient',
        name: 'recipient');
  }

  String get contains {
    return Intl.message(
        'Contains',
        name: 'contains');
  }

  String get notContains {
    return Intl.message(
        'Not contains',
        name: 'notContains');
  }

  String get exactlyEquals {
    return Intl.message(
        'Exactly equals',
        name: 'exactlyEquals');
  }

  String get notExactlyEquals {
    return Intl.message(
        'Not exactly equals',
        name: 'notExactlyEquals');
  }

  String get actionTitleRulesFilter {
    return Intl.message(
        'Perform the following actions:',
        name: 'actionTitleRulesFilter');
  }

  String get toFolder {
    return Intl.message(
        'To folder:',
        name: 'toFolder');
  }

  String get moveMessage {
    return Intl.message(
        'Move message',
        name: 'moveMessage');
  }

  String get ruleFilterAddressFromField {
    return Intl.message(
      'From',
      name: 'ruleFilterAddressFromField',
    );
  }

  String get ruleFilterAddressToField {
    return Intl.message(
      'To',
      name: 'ruleFilterAddressToField',
    );
  }

  String get ruleFilterAddressCcField {
    return Intl.message(
      'Cc',
      name: 'ruleFilterAddressCcField',
    );
  }

  String get newFilterWasCreated {
    return Intl.message(
        'New filter was created',
        name: 'newFilterWasCreated');
  }

  String get yourFilterHasBeenUpdated {
    return Intl.message(
        'Your filter has been updated',
        name: 'yourFilterHasBeenUpdated');
  }

  String get headerRecipients {
    return Intl.message(
      'Recipients',
      name: 'headerRecipients',
    );
  }

  String get forwarding {
    return Intl.message(
      'Forwarding',
      name: 'forwarding',
    );
  }

  String get vacation {
    return Intl.message(
      'Vacation',
      name: 'vacation',
    );
  }

  String get activated {
    return Intl.message(
      'Activated',
      name: 'activated',
    );
  }

  String get deactivated {
    return Intl.message(
      'Deactivated',
      name: 'deactivated',
    );
  }

  String get startDate {
    return Intl.message(
      'Start date',
      name: 'startDate',
    );
  }

  String get endDate {
    return Intl.message(
      'End date',
      name: 'endDate',
    );
  }

  String get vacationStopsAt {
    return Intl.message(
      'Vacation stops at',
      name: 'vacationStopsAt',
    );
  }

  String get message {
    return Intl.message(
      'Message',
      name: 'message',
    );
  }

  String get hintMessageBodyVacation {
    return Intl.message(
      'Vacation messages',
      name: 'hintMessageBodyVacation',
    );
  }

  String get errorMessageWhenStartDateVacationIsEmpty {
    return Intl.message(
      'Please enter a valid start date',
      name: 'errorMessageWhenStartDateVacationIsEmpty',
    );
  }

  String get errorMessageWhenEndDateVacationIsInValid {
    return Intl.message(
      'End date must be greater than start date',
      name: 'errorMessageWhenEndDateVacationIsInValid',
    );
  }

  String get errorMessageWhenMessageVacationIsEmpty {
    return Intl.message(
      'Message body cannot be blank',
      name: 'errorMessageWhenMessageVacationIsEmpty',
    );
  }

  String get vacationSettingSaved {
    return Intl.message(
      'Vacation settings saved',
      name: 'vacationSettingSaved',
    );
  }

  String get yourVacationResponderIsEnabled {
    return Intl.message(
      'Your vacation responder is enabled.',
      name: 'yourVacationResponderIsEnabled',
    );
  }

  String get yourVacationResponderIsDisabledSuccessfully {
    return Intl.message(
      'Your vacation responder is disabled successfully',
      name: 'yourVacationResponderIsDisabledSuccessfully',
    );
  }

  String messageEnableVacationResponderAutomatically(String startDate) {
    return Intl.message(
        'Your vacation responder will be activated on $startDate',
        name: 'messageEnableVacationResponderAutomatically',
        args: [startDate]);
  }

  String messageDisableVacationResponderAutomatically(String endDate) {
    return Intl.message(
        'Your vacation responder stopped on $endDate',
        name: 'messageDisableVacationResponderAutomatically',
        args: [endDate]);
  }

  String messageConfirmationDialogDeleteRecipientForward(String emailAddress) {
    return Intl.message(
        'Do you want to delete email $emailAddress?',
        name: 'messageConfirmationDialogDeleteRecipientForward',
        args: [emailAddress]
    );
  }

  String get deleteRecipient {
    return Intl.message(
        'Remove recipients',
        name: 'deleteRecipient');
  }

  String get toastMessageDeleteRecipientSuccessfully {
    return Intl.message(
        'The email has been removed from the recipient list.',
        name: 'toastMessageDeleteRecipientSuccessfully');
  }

  String get messageConfirmationDialogDeleteAllRecipientForward {
    return Intl.message(
        'Are you sure you want to remove those recipients? Doing this will remove them from the email chain.',
        name: 'messageConfirmationDialogDeleteAllRecipientForward'
    );
  }

  String get addRecipients {
    return Intl.message(
      'Add Recipients',
      name: 'addRecipients',
    );
  }

  String get hintInputAutocompleteContact {
    return Intl.message(
      'Enter name or email address',
      name: 'hintInputAutocompleteContact',
    );
  }

  String get toastMessageAddRecipientsSuccessfully {
    return Intl.message(
        'The emails has been added from the recipient list.',
        name: 'toastMessageAddRecipientsSuccessfully');
  }

  String get toastMessageLocalCopyEnable {
    return Intl.message(
        'Keep local copy enable.',
        name: 'toastMessageLocalCopyEnable');
  }

  String get toastMessageLocalCopyDisable {
    return Intl.message(
        'Keep local copy disable.',
        name: 'toastMessageLocalCopyDisable');
  }

  String get emailRuleSettingExplanation {
    return Intl.message(
      'Creating rules to handle incoming messages. You choose both the condition that triggers a rule and the actions the rule will take.',
      name: 'emailRuleSettingExplanation');
  }

  String messageConfirmationDialogDeleteEmailRule(String ruleName) {
    return Intl.message(
        'Do you want to delete rule "$ruleName"?',
        name: 'messageConfirmationDialogDeleteEmailRule',
        args: [ruleName]
    );
  }

  String get deleteEmailRule {
    return Intl.message(
        'Delete rule',
        name: 'deleteEmailRule');
  }

  String get toastMessageDeleteEmailRuleSuccessfully {
    return Intl.message(
        'The rule has been removed.',
        name: 'toastMessageDeleteEmailRuleSuccessfully');
  }

  String get vacationSettingExplanation {
    return Intl.message(
        'Sends an automated reply to incoming messages.',
        name: 'vacationSettingExplanation');
  }

  String get vacationSettingToggleButtonAutoReply {
    return Intl.message(
        'Automatically reply to messages when they are received.',
        name: 'vacationSettingToggleButtonAutoReply');
  }

  String get startTime {
    return Intl.message(
      'Start time',
      name: 'startTime',
    );
  }

  String get endTime {
    return Intl.message(
      'End time',
      name: 'endTime',
    );
  }

  String get hintSubjectInputVacationSetting {
    return Intl.message(
      'Enter subject',
      name: 'hintSubjectInputVacationSetting',
    );
  }

  String get saveChanges {
    return Intl.message(
      'Save changes',
      name: 'saveChanges',
    );
  }

  String get messageIsRequired {
    return Intl.message(
      'Message is required',
      name: 'messageIsRequired',
    );
  }

  String get endNow {
    return Intl.message(
      'End now',
      name: 'endNow',
    );
  }

  String get vacationSetting {
    return Intl.message(
      'Vacation setting',
      name: 'vacationSetting',
    );
  }

  String get backToSearchResults {
    return Intl.message(
      'Back to Search Results',
      name: 'backToSearchResults',
    );
  }

  String get clearAll {
    return Intl.message(
      'Clear all',
      name: 'clearAll',
    );
  }

  String get contact {
    return Intl.message(
        'Contact',
        name: 'contact');
  }

  String get hintSearchInputContact {
    return Intl.message(
        'Enter name or email',
        name: 'hintSearchInputContact'
    );
  }

  String get quickStyles {
    return Intl.message(
        'Quick styles',
        name: 'quickStyles'
    );
  }

  String get format {
    return Intl.message(
        'Format',
        name: 'format'
    );
  }

  String get background {
    return Intl.message(
        'Background',
        name: 'background'
    );
  }

  String get foreground {
    return Intl.message(
        'Foreground',
        name: 'foreground'
    );
  }

  String get titleFormat {
    return Intl.message(
        'Format',
        name: 'titleFormat'
    );
  }

  String get titleQuickStyles {
    return Intl.message(
        'Quick styles',
        name: 'titleQuickStyles'
    );
  }

  String get titleBackground {
    return Intl.message(
        'Background',
        name: 'titleBackground'
    );
  }

  String get titleForeground {
    return Intl.message(
        'Foreground',
        name: 'titleForeground'
    );
  }

  String get selectDate {
    return Intl.message(
      'Select date',
      name: 'selectDate',
    );
  }

  String get setDate {
    return Intl.message(
      'Set date',
      name: 'setDate',
    );
  }

  String get toastMessageErrorWhenSelectStartDateIsEmpty {
    return Intl.message(
      'The start date cannot be null.',
      name: 'toastMessageErrorWhenSelectStartDateIsEmpty',
    );
  }

  String get toastMessageErrorWhenSelectEndDateIsEmpty {
    return Intl.message(
      'The end date cannot be null.',
      name: 'toastMessageErrorWhenSelectEndDateIsEmpty',
    );
  }

  String get toastMessageErrorWhenSelectDateIsInValid {
    return Intl.message(
      'The end time cannot be less than the start time.',
      name: 'toastMessageErrorWhenSelectDateIsInValid',
    );
  }

  String dateRangeAdvancedSearchFilter(String startDate, String endDate) {
    return Intl.message(
        'From $startDate to $endDate',
        name: 'dateRangeAdvancedSearchFilter',
        args: [startDate, endDate]
    );
  }

  String get customRange {
    return Intl.message(
        'Custom range',
        name: 'customRange');
  }

  String get selectParentFolder {
    return Intl.message(
        'Select parent folder',
        name: 'selectParentFolder');
  }

  String get allowSubaddressing {
    return Intl.message(
        'Allow subaddressing',
        name: 'allowSubaddressing');
  }

  String get allow {
    return Intl.message(
        'Allow',
        name: 'allow');
  }

  String get disallowSubaddressing {
    return Intl.message(
        'Disallow subaddressing',
        name: 'disallowSubaddressing');
  }

  String get toastMessageAllowSubaddressingSuccess {
    return Intl.message(
        'You have successfully allowed subaddressing for this folder',
        name: 'toastMessageAllowSubaddressingSuccess');
  }

  String get toastMessageDisallowSubaddressingSuccess {
    return Intl.message(
        'You have successfully disallowed subaddressing for this folder',
        name: 'toastMessageDisallowSubaddressingSuccess');
  }

  String get toastMessageSubaddressingFailure {
    return Intl.message(
        'There was an error dealing with the request',
        name: 'toastMessageSubaddressingFailure');
  }

  String get requestReadReceipt {
    return Intl.message(
      'Request read receipt',
      name: 'requestReadReceipt'
    );
  }

  String get appGridTittle {
    return Intl.message(
      'Go to applications',
      name: 'appGridTittle'
    );
  }

  String get titleReadReceiptRequestNotificationMessage {
    return Intl.message(
      'Read receipt request',
      name: 'titleReadReceiptRequestNotificationMessage',
    );
  }

  String get contactSupport {
    return Intl.message(
      'Contact support',
      name: 'contactSupport',
    );
  }

  String get subTitleReadReceiptRequestNotificationMessage {
    return Intl.message(
      'The sender has requested a Read receipt for this email. Send Read receipt?',
      name: 'subTitleReadReceiptRequestNotificationMessage',
    );
  }

  String get yes {
    return Intl.message(
        'Yes',
        name: 'yes');
  }

  String get no {
    return Intl.message(
        'No',
        name: 'no');
  }

  String get toastMessageNotSupportMdnWhenSendReceipt {
    return Intl.message(
        'Your account does not support the MDN capability',
        name: 'toastMessageNotSupportMdnWhenSendReceipt');
  }

  String get toastMessageCannotFoundIdentityWhenSendReceipt {
    return Intl.message(
        'Identity id given cannot be found',
        name: 'toastMessageCannotFoundIdentityWhenSendReceipt');
  }

  String get toastMessageCannotFoundEmailIdWhenSendReceipt {
    return Intl.message(
        'Email id given cannot be found',
        name: 'toastMessageCannotFoundEmailIdWhenSendReceipt');
  }

  String subjectSendReceiptToSender(String subject) {
    return Intl.message(
        'Read: $subject',
        name: 'subjectSendReceiptToSender',
        args: [subject]);
  }

  String textBodySendReceiptToSender(String receiver, String subject, String time) {
    return Intl.message(
        'Message was read by $receiver on $time \n\nSubject: $subject \n\nNote: This Return Read Receipt only acknowledges that the message was displayed on the recipient\'s computer. There is no guarantee that the recipient has read or understood the message contents.',
        name: 'textBodySendReceiptToSender',
        args: [receiver, subject, time]);
  }

  String get toastMessageSendReceiptSuccess {
    return Intl.message(
        'A read receipt has been sent.',
        name: 'toastMessageSendReceiptSuccess');
  }

  String moveConversation(int numberOfConversation) {
    return Intl.message(
        'Move $numberOfConversation conversation',
        name: 'moveConversation',
        args: [numberOfConversation]
    );
  }

  String messageConfirmationDialogDeleteMultipleFolder(int numberOfMailbox) {
    return Intl.message(
        '$numberOfMailbox folder and all of the sub-folders and messages it contains will be deleted and won\'t be able to recover. Do you want to continue to delete?',
        name: 'messageConfirmationDialogDeleteMultipleFolder',
        args: [numberOfMailbox]
    );
  }

  String get toastMessageErrorNotSelectedFolderWhenCreateNewMailbox {
    return Intl.message(
        'You have not selected a save folder to save',
        name: 'toastMessageErrorNotSelectedFolderWhenCreateNewMailbox');
  }

  String get createNewFolder {
    return Intl.message(
        'Create new folder',
        name: 'createNewFolder');
  }

  String get newer {
    return Intl.message(
        'Newer',
        name: 'newer');
  }

  String get older {
    return Intl.message(
        'Older',
        name: 'older');
  }

  String get forwardingSettingExplanation {
    return Intl.message(
      'Emails addresses listed below will receive your emails.',
      name: 'forwardingSettingExplanation');
  }

  String get addRecipientButton {
    return Intl.message(
      'Add recipient',
      name: 'addRecipientButton');
  }

  String get incorrectEmailFormat {
    return Intl.message(
      'Incorrect email format',
      name: 'incorrectEmailFormat');
  }

  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove');
  }

  String totalEmailSelected(int count) {
    return Intl.message(
        'Deselect all ($count)',
        name: 'totalEmailSelected',
        args: [count]
    );
  }

  String get storageQuotas {
    return Intl.message(
      'Storage',
      name: 'storageQuotas',
    );
  }

  String get textQuotasOutOfStorage {
    return Intl.message(
      'Out of storage',
      name: 'textQuotasOutOfStorage',
    );
  }

  String get quickCreatingRule {
    return Intl.message(
        'Create a rule with this email',
        name: 'quickCreatingRule');
  }

  String get titlePageNotFound {
    return Intl.message(
      'Oops, we can’t find that page',
      name: 'titlePageNotFound');
  }

  String get subTitlePageNotFound {
    return Intl.message(
      'It is possible that your destination page has disappeared or belongs to another account.',
      name: 'subTitlePageNotFound');
  }

  String get page404 {
    return Intl.message(
        'Page 404',
        name: 'page404');
  }

  String get openInNewTab {
    return Intl.message(
      'Open in new tab',
      name: 'openInNewTab',
    );
  }

  String get copySubaddress {
    return Intl.message(
      'Copy subaddress',
      name: 'copySubaddress',
    );
  }

  String get regards {
    return Intl.message(
      'Regards',
      name: 'regards',
    );
  }

  String get youHaveNewMessages {
    return Intl.message(
      'You have new messages',
      name: 'youHaveNewMessages',
    );
  }

  String get appTitlePushNotification {
    return Intl.message(
      'Twake Mail',
      name: 'appTitlePushNotification');
  }

  String totalNewMessagePushNotification(int count) {
    return Intl.message(
      '$count new emails',
      name: 'totalNewMessagePushNotification',
      args: [count]);
  }

  String get privacyPolicy {
    return Intl.message(
      'Privacy policy',
      name: 'privacyPolicy',
    );
  }
  
  String countNewSpamEmails(String count) {
    return Intl.message(
        'You have $count new spam emails!',
        name: 'countNewSpamEmails',
        args: [count]
    );
  }

  String get showDetails {
    return Intl.message(
      'Show Details',
      name: 'showDetails',
    );
  }

  String get dismiss {
    return Intl.message(
      'Dismiss',
      name: 'dismiss',
    );
  }

  String get disableSpamReport {
    return Intl.message(
      'Disable Spam report',
      name: 'disableSpamReport',
    );
  }

  String get enableSpamReport {
    return Intl.message(
      'Enable Spam report',
      name: 'enableSpamReport',
    );
  }
  
  String get required {
    return Intl.message(
      'required',
      name: 'required');
  }

  String get noEmailInYourCurrentFolder {
    return Intl.message(
      'There are no emails in your current folder',
      name: 'noEmailInYourCurrentFolder');
  }

  String get noEmailMatchYourCurrentFilter {
    return Intl.message(
      'There are no emails that match your current filter.',
      name: 'noEmailMatchYourCurrentFilter');
  }

  String get sendMessageFailure {
    return Intl.message(
      'Failure to send your message.',
      name: 'sendMessageFailure',
    );
  }

  String get sendMessageFailureWithSetErrorTypeTooLarge {
    return Intl.message(
      'Failure to send your message, because it is too large.',
      name: 'sendMessageFailureWithSetErrorTypeTooLarge',
    );
  }

  String get sendMessageFailureWithSetErrorTypeOverQuota {
    return Intl.message(
      'Failure to send your message, because it is over quota.',
      name: 'sendMessageFailureWithSetErrorTypeOverQuota',
    );
  }

  String get saveEmailAsDraftFailure {
    return Intl.message(
      'Failure to save your message as drafts.',
      name: 'saveEmailAsDraftFailure',
    );
  }

  String get saveEmailAsDraftFailureWithSetErrorTypeTooLarge {
    return Intl.message(
      'Failure to save your message as drafts, because it is too large.',
      name: 'saveEmailAsDraftFailureWithSetErrorTypeTooLarge',
    );
  }

  String get saveEmailAsDraftFailureWithSetErrorTypeOverQuota {
    return Intl.message(
      'Failure to save your message as drafts, because it is over quota.',
      name: 'saveEmailAsDraftFailureWithSetErrorTypeOverQuota',
    );
  }

  String get teamMailBoxes {
    return Intl.message(
      'Team-mailboxes',
      name: 'teamMailBoxes');
  }

  String get hideFolder {
    return Intl.message(
      'Hide folder',
      name: 'hideFolder');
  }

  String get thisImageCannotBeAdded {
    return Intl.message(
      'This image cannot be added.',
      name: 'thisImageCannotBeAdded'
    );
  }

  String get toastMsgHideFolderSuccess {
    return Intl.message(
      'This folder has been hidden from your primary folder',
      name: 'toastMsgHideFolderSuccess');
  }

  String get searchForFolders {
    return Intl.message(
      'Search for folders',
      name: 'searchForFolders'
    );
  }

  String get showFolder {
    return Intl.message(
      'Show folder',
      name: 'showFolder'
    );
  }

  String get toastMessageShowFolderSuccess {
    return Intl.message(
      'This folder is already displayed in your primary folder',
      name: 'toastMessageShowFolderSuccess');
  }

  String get folderVisibility {
    return Intl.message(
      'Folder visibility',
      name: 'folderVisibility',
    );
  }

  String get folderVisibilitySubtitle {
    return Intl.message(
      'Show/ hide your folders, including your personal folders and team mailboxes.',
      name: 'folderVisibilitySubtitle',
    );
  }

  String get emptyListEmailForward {
    return Intl.message(
      'Please input at least one recipient',
      name: 'emptyListEmailForward');
  }

  String get forwardedMessage {
    return Intl.message(
      'Forwarded message',
      name: 'forwardedMessage');
  }

  String get repliedMessage {
    return Intl.message(
      'Replied message',
      name: 'repliedMessage');
  }

  String get repliedAndForwardedMessage {
    return Intl.message(
      'Replied and Forwarded message',
      name: 'repliedAndForwardedMessage');
  }

  String get emptyTrash {
    return Intl.message(
      'Empty Trash',
      name: 'emptyTrash');
  }

  String get cannotSelectThisImage {
    return Intl.message(
      'Cannot select this image.',
      name: 'cannotSelectThisImage');
  }

  String get messageHasBeenSavedToTheSendingQueue {
    return Intl.message(
      'Temporary network issue. Messages queued for retry when connected.',
      name: 'messageHasBeenSavedToTheSendingQueue',
    );
  }

  String get sendingQueue {
    return Intl.message(
      'Sending queue',
      name: 'sendingQueue'
    );
  }

  String get bannerMessageSendingQueueView {
    return Intl.message(
      'Messages in Sending queue folder will be sent or scheduled when online.',
      name: 'bannerMessageSendingQueueView'
    );
  }

  String get proceed {
    return Intl.message(
      'Proceed',
      name: 'proceed'
    );
  }

  String get youAreInOfflineMode {
    return Intl.message(
      'You\'re in offline mode',
      name: 'youAreInOfflineMode'
    );
  }

  String get messageDialogWhenStoreSendingEmailFirst {
    return Intl.message(
      'Fortunately, you can still',
      name: 'messageDialogWhenStoreSendingEmailFirst'
    );
  }

  String get messageDialogWhenStoreSendingEmailSecond {
    return Intl.message(
      ' send, reply, or forward ',
      name: 'messageDialogWhenStoreSendingEmailSecond'
    );
  }

  String get messageDialogWhenStoreSendingEmailThird {
    return Intl.message(
      'emails. They will be delivered when you connect to the internet. To edit these emails before sending, go to the ',
      name: 'messageDialogWhenStoreSendingEmailThird'
    );
  }

  String get messageDialogWhenStoreSendingEmailTail {
    return Intl.message(
      ' folder.',
      name: 'messageDialogWhenStoreSendingEmailTail'
    );
  }

  String titleRecipientSendingEmail(String recipients) {
    return Intl.message(
      'To: $recipients',
      name: 'titleRecipientSendingEmail',
      args: [recipients]);
  }

  String get openFolderMenu {
    return Intl.message(
      'Open Folder menu',
      name: 'openFolderMenu'
    );
  }

  String get messageHasBeenSentSuccessfully {
    return Intl.message(
      'Message has been sent successfully.',
      name: 'messageHasBeenSentSuccessfully',
    );
  }

  String get deleteOfflineEmail {
    return Intl.message(
        'Delete offline email',
        name: 'deleteOfflineEmail'
    );
  }

  String get messageDialogDeleteSendingEmail {
    return Intl.message(
      'Deleting an offline email will erase its content permanently. You won\'t be able to undo this action or recover the email from the Trash folder.',
      name: 'messageDialogDeleteSendingEmail'
    );
  }

  String get messageHaveBeenDeletedSuccessfully {
    return Intl.message(
      'Messages have been deleted successfully',
      name: 'messageHaveBeenDeletedSuccessfully',
    );
  }

  String get delivering {
    return Intl.message(
      'Delivering',
      name: 'delivering',
    );
  }

  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
    );
  }

  String get error {
    return Intl.message(
      'Error',
      name: 'error',
    );
  }

  String get errorWhileFetchingSubaddress {
    return Intl.message(
      'Error while fetching the subaddress',
      name: 'errorWhileFetchingSubaddress',
    );
  }

  String get connectedToTheInternet {
    return Intl.message(
      'Connected to the internet',
      name: 'connectedToTheInternet'
    );
  }

  String get resend {
    return Intl.message(
      'Resend',
      name: 'resend');
  }

  String get messagesHaveBeenResent {
    return Intl.message(
      'Messages have been resent',
      name: 'messagesHaveBeenResent');
  }

  String get connectionError {
    return Intl.message(
      'Connection error',
      name: 'connectionError'
    );
  }

  String get inboxMailboxDisplayName {
    return Intl.message(
      'Inbox',
      name: 'inboxMailboxDisplayName',
    );
  }

  String get sentMailboxDisplayName {
    return Intl.message(
      'Sent',
      name: 'sentMailboxDisplayName',
    );
  }

  String get outboxMailboxDisplayName {
    return Intl.message(
      'Outbox',
      name: 'outboxMailboxDisplayName',
    );
  }

  String get spamMailboxDisplayName {
    return Intl.message(
      'Spam',
      name: 'spamMailboxDisplayName',
    );
  }

  String get draftsMailboxDisplayName {
    return Intl.message(
      'Drafts',
      name: 'draftsMailboxDisplayName',
    );
  }

  String get trashMailboxDisplayName {
    return Intl.message(
      'Trash',
      name: 'trashMailboxDisplayName',
    );
  }

  String get templatesMailboxDisplayName {
    return Intl.message(
      'Templates',
      name: 'templatesMailboxDisplayName',
    );
  }

  String get archiveMailboxDisplayName {
    return Intl.message(
      'Archive',
      name: 'archiveMailboxDisplayName',
    );
  }

  String pleaseChooseAnImageSizeCorrectly(int maxSize) {
    return Intl.message(
      'Please choose an image with size less than ${maxSize}KB',
      name: 'pleaseChooseAnImageSizeCorrectly',
      args: [maxSize]);
  }

  String get messageEventActionBannerOrganizerInvited {
    return Intl.message(
      ' has invited you in to a meeting',
      name: 'messageEventActionBannerOrganizerInvited');
  }

  String get messageEventActionBannerOrganizerUpdated {
    return Intl.message(
      ' has updated a meeting',
      name: 'messageEventActionBannerOrganizerUpdated');
  }

  String get messageEventActionBannerOrganizerCanceled {
    return Intl.message(
      ' has canceled a meeting',
      name: 'messageEventActionBannerOrganizerCanceled');
  }

  String get anAttendee {
    return Intl.message(
      'An attendee',
      name: 'anAttendee');
  }

  String get you {
    return Intl.message(
      'You',
      name: 'you');
  }

  String get messageEventActionBannerAttendeeAccepted {
    return Intl.message(
      ' has accepted this invitation',
      name: 'messageEventActionBannerAttendeeAccepted');
  }

  String get messageEventActionBannerAttendeeTentative {
    return Intl.message(
      ' has replied "Maybe" to this invitation',
      name: 'messageEventActionBannerAttendeeTentative');
  }

  String get messageEventActionBannerAttendeeDeclined {
    return Intl.message(
      ' has declined this invitation',
      name: 'messageEventActionBannerAttendeeDeclined');
  }

  String get messageEventActionBannerAttendeeCounter {
    return Intl.message(
      ' has proposed changes to the event',
      name: 'messageEventActionBannerAttendeeCounter');
  }

  String get messageEventActionBannerAttendeeCounterDeclined {
    return Intl.message(
      'Your counter proposal was declined',
      name: 'messageEventActionBannerAttendeeCounterDeclined');
  }

  String get invitationMessageCalendarInformation {
    return Intl.message(
      ' has invited you in to a meeting:',
      name: 'invitationMessageCalendarInformation');
  }

  String get when {
    return Intl.message(
      'When',
      name: 'when');
  }

  String get where {
    return Intl.message(
      'Where',
      name: 'where');
  }

  String get who {
    return Intl.message(
      'Who',
      name: 'who');
  }

  String get organizer {
    return Intl.message(
      'Organizer',
      name: 'organizer');
  }

  String get time {
    return Intl.message(
      'Time',
      name: 'time',
    );
  }

  String get location {
    return Intl.message(
      'Location',
      name: 'location');
  }

  String get attendees {
    return Intl.message(
      'Attendees',
      name: 'attendees');
  }

  String get seeAllAttendees {
    return Intl.message(
      'See all attendees',
      name: 'seeAllAttendees');
  }

  String get link {
    return Intl.message(
      'Link',
      name: 'link');
  }

  String get deleteAllSpamEmails {
    return Intl.message(
      'Delete all spam emails',
      name: 'deleteAllSpamEmails');
  }

  String get emptySpamFolder {
    return Intl.message(
      'Empty Spam folder',
      name: 'emptySpamFolder');
  }

  String get emptySpamMessageDialog {
    return Intl.message(
      'You are about to permanently delete all items in Spam. Do you want to continue?',
      name: 'emptySpamMessageDialog');
  }

  String get bannerDeleteAllSpamEmailsMessage {
    return Intl.message(
      'All messages in Spam will be deleted if you reach limited storage.',
      name: 'bannerDeleteAllSpamEmailsMessage');
  }

  String get deleteAllSpamEmailsNow {
    return Intl.message(
      'Delete all spam emails now',
      name: 'deleteAllSpamEmailsNow');
  }

  String quotaStateLabel(String used, String limit) {
    return Intl.message(
      '$used of $limit Used',
      name: 'quotaStateLabel',
      args: [used, limit],
    );
  }

  String get quotaErrorBannerTitle {
    return Intl.message(
      'You have run out of storage space',
      name: 'quotaErrorBannerTitle'
    );
  }

  String createFolderSuccessfullyMessage(String folderName) {
    return Intl.message(
      'You successfully created $folderName folder',
      name: 'createFolderSuccessfullyMessage',
      args: [folderName]
    );
  }

  String get createFilters {
    return Intl.message(
      'Create filters',
      name: 'createFilters');
  }


  String get maybe {
    return Intl.message(
      'Maybe',
      name: 'maybe');
  }

  String get enterASubject {
    return Intl.message(
      'Enter a subject',
      name: 'enterASubject',
    );
  }

  String get enterSomeSuggestions {
    return Intl.message(
      'Enter some suggestions',
      name: 'enterSomeSuggestions',
    );
  }

  String markedSingleMessageToast(String action) {
    return Intl.message(
        'Message has been marked as $action',
        name: 'markedSingleMessageToast',
        args: [action]
    );
  }

  String get clean {
    return Intl.message(
      'Clean',
      name: 'clean',
    );
  }

  String get clearFolder {
    return Intl.message(
      'Clear folder',
      name: 'clearFolder',
    );
  }

  String messageEmptyFolderDialog(String folder) {
    return Intl.message(
      'The messages in $folder folder will be permanently deleted and you will not be able to restore them',
      name: 'messageEmptyFolderDialog',
      args: [folder]
    );
  }

  String get addCondition {
    return Intl.message(
      'Add condition',
      name: 'addCondition',
    );
  }

  String get formattingOptions {
    return Intl.message(
      'Formatting options',
      name: 'formattingOptions'
    );
  }

  String get embedCode {
    return Intl.message(
      'Embed code',
      name: 'embedCode'
    );
  }

  String showMoreAttachment(int count) {
    return Intl.message(
      'Show more (+$count)',
      name: 'showMoreAttachment',
      args: [count]
    );
  }

  String get saveAsDraft {
    return Intl.message(
      'Save as draft',
      name: 'saveAsDraft',
    );
  }

  String get dropFileHereToAttachThem {
    return Intl.message(
      'Drop file here to attach them',
      name: 'dropFileHereToAttachThem',
    );
  }

  String get canceled {
    return Intl.message(
      'Canceled',
      name: 'canceled',
    );
  }

  String get newSubfolder {
    return Intl.message(
      'New subfolder',
      name: 'newSubfolder',
    );
  }

  String get textSize {
    return Intl.message(
      'Text Size',
      name: 'textSize'
    );
  }

  String get messageDialogOfflineModeOnIOS {
    return Intl.message(
      'The message will be in Sending Queue. You can try again when being online.',
      name: 'messageDialogOfflineModeOnIOS'
    );
  }

  String get bannerMessageSendingQueueViewOnIOS {
    return Intl.message(
      'Your messages were not sent due to network issues. They\'re safely stored. When you\'re back online, you can resend, edit, or delete them.',
      name: 'bannerMessageSendingQueueViewOnIOS'
    );
  }

  String get attachmentList {
    return Intl.message(
      'Attachment list',
      name: 'attachmentList',
    );
  }

  String get files {
    return Intl.message(
      'files',
      name: 'files',
    );
  }

  String get downloadAll {
    return Intl.message(
      'Download all',
      name: 'downloadAll',
    );
  }

  String toastMessageMarkAsReadFolderAllFailure(String folderName) {
    return Intl.message(
      'Folder "$folderName" could not be marked as read',
      name: 'toastMessageMarkAsReadFolderAllFailure',
      args: [folderName]
    );
  }

  String get sending {
    return Intl.message(
      'Sending',
      name: 'sending',
    );
  }

  String get all {
    return Intl.message(
      'All',
      name: 'all',
    );
  }

  String get any {
    return Intl.message(
      'Any',
      name: 'any',
    );
  }

  String get conditionTitleRulesFilterBeforeCombiner {
    return Intl.message(
      'If',
      name: 'conditionTitleRulesFilterBeforeCombiner',
    );
  }

  String get conditionTitleRulesFilterAfterCombiner {
    return Intl.message(
      'of the following conditions are met:',
      name: 'conditionTitleRulesFilterAfterCombiner',
    );
  }

  String get maskAsSeen {
    return Intl.message(
      'Mark as seen',
      name: 'maskAsSeen',
    );
  }

  String get starIt {
    return Intl.message(
      'Star it',
      name: 'starIt',
    );
  }

  String get rejectIt {
    return Intl.message(
      'Reject it',
      name: 'rejectIt',
    );
  }

  String get markAsSpam {
    return Intl.message(
      'Mark as spam',
      name: 'markAsSpam',
    );
  }

  String get forwardTo {
    return Intl.message(
      'Forward to',
      name: 'forwardTo',
    );
  }

  String get selectAction {
    return Intl.message(
      'Select action',
      name: 'selectAction',
    );
  }

  String get forwardEmailHintText {
    return Intl.message(
      'Add forwarding address',
      name: 'forwardEmailHintText',
    );
  }

  String get addAction {
    return Intl.message(
      'Add action',
      name: 'addAction',
    );
  }

  String get duplicatedActionError {
    return Intl.message(
      'This action is already added',
      name: 'duplicatedActionError',
    );
  }

  String get notSelectedMailboxToMoveMessage {
    return Intl.message(
      'Please select a mailbox to move the message',
      name: 'notSelectedMailboxToMoveMessage',
    );
  }

  String get confirmAllEmailHereAreSpam {
    return Intl.message(
      'Confirm all email here are Spam',
      name: 'confirmAllEmailHereAreSpam'
    );
  }

  String get yourIdentities {
    return Intl.message(
      'Your identities',
      name: 'yourIdentities',
    );
  }

  String get searchForIdentities {
    return Intl.message(
      'Search for identities',
      name: 'searchForIdentities',
    );
  }

  String get sortBy {
    return Intl.message(
      'Sort by',
      name: 'sortBy',
    );
  }

  String get mostRecent {
    return Intl.message(
      'Most recent',
      name: 'mostRecent',
    );
  }

  String get oldest {
    return Intl.message(
      'Oldest',
      name: 'oldest',
    );
  }

  String get relevance {
    return Intl.message(
      'Relevance',
      name: 'relevance',
    );
  }

  String get senderAscending {
    return Intl.message(
      'Sender name: A - Z',
      name: 'senderAscending',
    );
  }

  String get senderDescending {
    return Intl.message(
      'Sender name: Z - A',
      name: 'senderDescending',
    );
  }

  String get subjectAscending {
    return Intl.message(
      'Subject: A - Z',
      name: 'subjectAscending',
    );
  }

  String get subjectDescending {
    return Intl.message(
      'Subject: Z - A',
      name: 'subjectDescending',
    );
  }

  String get notFoundSession {
    return Intl.message(
      'Session not found',
      name: 'notFoundSession',
    );
  }

  String get dnsLookupLoginMessage {
    return Intl.message(
      'To login and access your message please enter your email',
      name: 'dnsLookupLoginMessage'
    );
  }

  String get enterYourPasswordToSignIn {
    return Intl.message(
      'Enter your password to sign in',
      name: 'enterYourPasswordToSignIn'
    );
  }

  String get unsubscribe {
    return Intl.message(
      'Unsubscribe',
      name: 'unsubscribe',
    );
  }

  String get unsubscribeMail {
    return Intl.message(
      'Unsubscribe mail',
      name: 'unsubscribeMail',
    );
  }

  String get unsubscribeMailDialogMessage {
    return Intl.message(
      'Are you sure you\'d like to stop receiving similar messages from',
      name: 'unsubscribeMailDialogMessage',
    );
  }

  String get unsubscribedFromThisMailingList {
    return Intl.message(
      'Unsubscribed from this mailing list',
      name: 'unsubscribedFromThisMailingList',
    );
  }

  String mailUnsubscribedMessage(String senderName) {
    return Intl.message(
      'You unsubscribe from $senderName',
      name: 'mailUnsubscribedMessage',
      args: [senderName]
    );
  }

  String get cannotCompressInlineImage {
    return Intl.message(
      'Cannot compress image',
      name: 'cannotCompressInlineImage',
    );
  }

  String get me {
    return Intl.message(
      'Me',
      name: 'me',
    );
  }

  String get byContinuingYouAreAgreeingToOur {
    return Intl.message(
      'By continuing, you\'re agreeing to our',
      name: 'byContinuingYouAreAgreeingToOur',
    );
  }

  String get archiveMessage {
    return Intl.message(
      'Archive message',
      name: 'archiveMessage',
    );
  }

  String get recoverDeletedMessages {
    return Intl.message(
      'Recover deleted messages',
      name: 'recoverDeletedMessages',
    );
  }

  String recoverDeletedMessagesBannerContent(String period) {
    return Intl.message(
      'You can recover messages deleted during the past $period',
      name: 'recoverDeletedMessagesBannerContent',
      args: [period]
    );
  }

  String get deletionDate {
    return Intl.message(
      'Deletion date',
      name: 'deletionDate',
    );
  }

  String get receptionDate {
    return Intl.message(
      'Reception date',
      name: 'receptionDate',
    );
  }

  String get sender {
    return Intl.message(
      'Sender',
      name: 'sender',
    );
  }

  String get addSender {
    return Intl.message(
      'Add sender',
      name: 'addSender',
    );
  }

  String get last1Year {
    return Intl.message(
      'Last 1 year',
      name: 'last1Year',
    );
  }

  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
    );
  }

  String get recoveredMailboxDisplayName {
    return Intl.message(
      'Recovered',
      name: 'recoveredMailboxDisplayName',
    );
  }

  String get restoreDeletedMessageFailed {
    return Intl.message(
      'Restore deleted message failed',
      name: 'restoreDeletedMessageFailed',
    );
  }

  String get restoreDeletedMessageSuccess {
    return Intl.message(
      'Recover deleted messages successfully',
      name: 'restoreDeletedMessageSuccess',
    );
  }

  String get open {
    return Intl.message(
      'Open',
      name: 'open',
    );
  }

  String get bannerProgressingRecoveryMessage {
    return Intl.message(
      'The recovery is in progress. You can continue using Twake Mail',
      name: 'bannerProgressingRecoveryMessage',
    );
  }

  String get restoreDeletedMessageCanceled {
    return Intl.message(
      'Restore deleted message canceled',
      name: 'restoreDeletedMessageCanceled',
    );
  }

  String get loadMore {
    return Intl.message(
      'Load more',
      name: 'loadMore',
    );
  }

  String get messageWarningDialogForForwardsToOtherDomains {
    return Intl.message(
      'You are redirecting emails to another domain. This could be a security threat or considered illegal data extraction.',
      name: 'messageWarningDialogForForwardsToOtherDomains'
    );
  }

  String get externalDomain {
    return Intl.message(
      'External domain',
      name: 'externalDomain');
  }

  String get printAll {
    return Intl.message(
      'Print all',
      name: 'printAll');
  }

  String get replyToEmailAddressPrefix {
    return Intl.message(
      'Reply-To',
      name: 'replyToEmailAddressPrefix',
    );
  }

  String get printingInProgress {
    return Intl.message(
      'Printing in progress',
      name: 'printingInProgress'
    );
  }

  String get printingFailed {
    return Intl.message(
      'Printing failed',
      name: 'printingFailed'
    );
  }

  String get emailReadReceipts {
    return Intl.message(
      'Email read receipts',
      name: 'emailReadReceipts');
  }

  String get emailReadReceiptsSettingExplanation {
    return Intl.message(
      'Read receipts are notifications that can be sent to and from your users to verify that mail has been read.',
      name: 'emailReadReceiptsSettingExplanation');
  }

  String get emailReadReceiptsToggleDescription {
    return Intl.message(
      'Always request read receipts with outgoing messages',
      name: 'emailReadReceiptsToggleDescription');
  }

  String get selectAllMessagesOfThisPage {
    return Intl.message(
      'Select all messages of this page',
      name: 'selectAllMessagesOfThisPage',
    );
  }

  String get noSuitableBrowserForOIDC {
    return Intl.message(
      'No suitable browser for OIDC, please check with your system administrator',
      name: 'noSuitableBrowserForOIDC'
    );
  }

  String get eventReplyWasSentUnsuccessfully {
    return Intl.message(
      'Event reply was sent unsuccessfully!',
      name: 'eventReplyWasSentUnsuccessfully',
    );
  }

  String get youWillAttendThisMeeting {
    return Intl.message(
      'You will attend this meeting',
      name: 'youWillAttendThisMeeting',
    );
  }

  String get youWillNotAttendThisMeeting {
    return Intl.message(
      'You will not attend this meeting',
      name: 'youWillNotAttendThisMeeting',
    );
  }

  String get youMayAttendThisMeeting {
    return Intl.message(
      'You may attend this meeting',
      name: 'youMayAttendThisMeeting',
    );
  }

  String get youAcceptedTheProposedTimeForThisMeeting {
    return Intl.message(
      'You accepted the proposed time for this meeting',
      name: 'youAcceptedTheProposedTimeForThisMeeting',
    );
  }

  String get downloadMessageAsEML {
    return Intl.message(
      'Download message as EML',
      name: 'downloadMessageAsEML',
    );
  }

  String get downloadMessageAsEMLFailed {
    return Intl.message(
      'Download message as EML failed',
      name: 'downloadMessageAsEMLFailed',
    );
  }

  String get download {
    return Intl.message(
      'Download',
      name: 'download',
    );
  }

  String get print {
    return Intl.message(
      'Print',
      name: 'print',
    );
  }

  String get page {
    return Intl.message(
      'Page',
      name: 'page',
    );
  }

  String get zoomIn {
    return Intl.message(
      'Zoom In',
      name: 'zoomIn',
    );
  }

  String get zoomOut {
    return Intl.message(
      'Zoom Out',
      name: 'zoomOut',
    );
  }

  String get warningMessageWhenExceedGenerallySizeInComposer {
    return Intl.message(
      'Your message is larger than the size generally accepted by third party email systems. If you confirm sending this mail, there is a risk that it gets rejected by your recipient system.',
      name: 'warningMessageWhenExceedGenerallySizeInComposer',
    );
  }

  String get continueAction {
    return Intl.message(
      'Continue',
      name: 'continueAction',
    );
  }

  String get thisFileCannotBePicked {
    return Intl.message(
      'This file cannot be picked.',
      name: 'thisFileCannotBePicked',
    );
  }

  String get loadingPleaseWait {
    return Intl.message(
      'Loading... Please wait!',
      name: 'loadingPleaseWait',
    );
  }

  String get status {
    return Intl.message(
      'Status',
      name: 'status');
  }

  String get progress {
    return Intl.message(
      'Progress',
      name: 'progress');
  }

  String get sendingMessage {
    return Intl.message(
      'Sending message',
      name: 'sendingMessage');
  }

  String get warningMessageWhenSendEmailFailure {
    return Intl.message(
      'Sending of the message failed.\nAn error occurred while sending mail.',
      name: 'warningMessageWhenSendEmailFailure');
  }

  String get closeAnyway {
    return Intl.message(
      'Close anyway',
      name: 'closeAnyway');
  }

  String get saveMessage {
    return Intl.message(
      'Save message',
      name: 'saveMessage');
  }

  String get discardChanges {
    return Intl.message(
      'Discard changes',
      name: 'discardChanges');
  }

  String get warningMessageWhenClickCloseComposer {
    return Intl.message(
      'Save this message to your drafts folder and close composer?',
      name: 'warningMessageWhenClickCloseComposer');
  }

  String get savingMessage {
    return Intl.message(
      'Saving message',
      name: 'savingMessage');
  }

  String get creatingMessage {
    return Intl.message(
      'Creating message',
      name: 'creatingMessage');
  }

  String get savingMessageToDraftFolder {
    return Intl.message(
      'Saving message to draft folder',
      name: 'savingMessageToDraftFolder');
  }

  String get warningMessageWhenSaveEmailToDraftsFailure {
    return Intl.message(
      'Saving of the message to drafts folder failed.\nAn error occurred while saving mail.',
      name: 'warningMessageWhenSaveEmailToDraftsFailure');
  }

  String get canceling {
    return Intl.message(
      'Canceling',
      name: 'canceling'
    );
  }

  String get mailToAttendees {
    return Intl.message(
      'Mail to attendees',
      name: 'mailToAttendees'
    );
  }

  String get showLess {
    return Intl.message(
      'Show less',
      name: 'showLess');
  }

  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
    );
  }

  String get notificationsDisabled {
    return Intl.message(
      'Notifications disabled',
      name: 'notificationsDisabled',
    );
  }

  String get pleaseAllowNotifications {
    return Intl.message(
      'Please allow notifications from Twake Mail in the device\'s Settings',
      name: 'pleaseAllowNotifications',
    );
  }

  String get goToSettings {
    return Intl.message(
      'Go to Settings',
      name: 'goToSettings',
    );
  }

  String get allowsTwakeMailToNotifyYouWhenANewMessageArrivesOnYourPhone {
    return Intl.message(
      'Allows Twake Mail to notify you when a new message arrives on your phone',
      name: 'allowsTwakeMailToNotifyYouWhenANewMessageArrivesOnYourPhone',
    );
  }

  String get showNotifications {
    return Intl.message(
      'Show Notifications',
      name: 'showNotifications',
    );
  }

  String get turnOnRequestReadReceipt {
    return Intl.message(
      'Turn on request read receipt',
      name: 'turnOnRequestReadReceipt'
    );
  }

  String get turnOffRequestReadReceipt {
    return Intl.message(
      'Turn off request read receipt',
      name: 'turnOffRequestReadReceipt'
    );
  }

  String get requestReadReceiptHasBeenEnabled {
    return Intl.message(
      'Request read receipt has been enabled',
      name: 'requestReadReceiptHasBeenEnabled'
    );
  }

  String get requestReadReceiptHasBeenDisabled {
    return Intl.message(
      'Request read receipt has been disabled',
      name: 'requestReadReceiptHasBeenDisabled'
    );
  }

  String get reconnect {
    return Intl.message(
      'Reconnect',
      name: 'reconnect',
    );
  }

  String get sMimeGoodSignatureMessage {
    return Intl.message(
      'The authenticity of this message had been verified with SMime signature.',
      name: 'sMimeGoodSignatureMessage',
    );
  }

  String get sMimeBadSignatureMessage {
    return Intl.message(
      'This message failed SMime signature verification.',
      name: 'sMimeBadSignatureMessage',
    );
  }

  String get emptySpamFolderFailed {
    return Intl.message(
      'Empty spam folder failed',
      name: 'emptySpamFolderFailed');
  }

  String get emptyTrashFolderFailed {
    return Intl.message(
      'Empty trash folder failed',
      name: 'emptyTrashFolderFailed');
  }

  String get markAsSpamFailed {
    return Intl.message(
      'Mark as spam failed',
      name: 'markAsSpamFailed');
  }

  String get canNotUploadFileToSignature {
    return Intl.message(
      'Can not upload this file to signature',
      name: 'canNotUploadFileToSignature'
    );
  }

  String get generalSignatureImageUploadError {
    return Intl.message(
      'There was an error while uploading the image. Please try again.',
      name: 'generalSignatureImageUploadError');
  }

  String get thisImageCannotBePastedIntoTheEditor {
    return Intl.message(
      'This image cannot be pasted into the editor.',
      name: 'thisImageCannotBePastedIntoTheEditor');
  }

  String get spamFolderNotFound {
    return Intl.message(
      'Spam folder not found',
      name: 'spamFolderNotFound',
    );
  }

  String get youHaveNotAddedConditionToRule {
    return Intl.message(
      'You have not added a condition to the rule.',
      name: 'youHaveNotAddedConditionToRule');
  }

  String get youHaveNotAddedActionToRule {
    return Intl.message(
      'You have not added a action to the rule.',
      name: 'youHaveNotAddedActionToRule');
  }

  String get youHaveNotSelectedAnyActionForRule {
    return Intl.message(
      'You have not selected any action for the rule.',
      name: 'youHaveNotSelectedAnyActionForRule');
  }

  String get tryAgain {
    return Intl.message(
      'Try again',
      name: 'tryAgain',
    );
  }

  String get youAreOffline {
    return Intl.message(
      'You are offline. It looks like you are not connected.',
      name: 'youAreOffline',
    );
  }

  String get findEmails {
    return Intl.message(
      'Find emails',
      name: 'findEmails');
  }

  String get thisFieldCannotContainOnlySpaces {
    return Intl.message(
      'This field cannot contain only spaces',
      name: 'thisFieldCannotContainOnlySpaces',
    );
  }

  String get descriptionWelcomeTo {
    return Intl.message(
      'The new Open Source standard for\n secure professional e-mail',
      name: 'descriptionWelcomeTo',
    );
  }

  String get createTwakeId {
    return Intl.message(
      'Create Twake ID',
      name: 'createTwakeId',
    );
  }

  String get useCompanyServer {
    return Intl.message(
      'Use company server',
      name: 'useCompanyServer',
    );
  }

  String get sigInSaasFailed {
    return Intl.message(
      'Login failed. Please check again.',
      name: 'sigInSaasFailed',
    );
  }

  String get createTwakeIdFailed {
    return Intl.message(
      'Create Twake Id failed. Please check again.',
      name: 'createTwakeIdFailed',
    );
  }

  String get yesLogout {
    return Intl.message(
      'Yes, Log out',
      name: 'yesLogout',
    );
  }

  String get logoutConfirmation {
    return Intl.message(
      'Logout Confirmation',
      name: 'logoutConfirmation',
    );
  }

  String get messageConfirmationLogout {
    return Intl.message(
      'Do you want to log out of',
      name: 'messageConfirmationLogout',
    );
  }

  String get switchAccountConfirmation {
    return Intl.message(
      'Switch Account Confirmation',
      name: 'switchAccountConfirmation',
    );
  }

  String get youAreCurrentlyLoggedInWith {
    return Intl.message(
      'You are currently logged in with',
      name: 'youAreCurrentlyLoggedInWith',
    );
  }

  String get doYouWantToLogOutAndSwitchTo {
    return Intl.message(
      'Do you want to log out and switch to',
      name: 'doYouWantToLogOutAndSwitchTo',
    );
  }

  String get getHelpOrReportABug {
    return Intl.message(
      'Get help or report a bug',
      name: 'getHelpOrReportABug',
    );
  }

  String get replyToList {
    return Intl.message(
      'Reply to list',
      name: 'replyToList',
    );
  }

  String get parseEmailByBlobIdFailed {
    return Intl.message(
      'Cannot parse email by blob id',
      name: 'parseEmailByBlobIdFailed',
    );
  }

  String get previewEmailFromEMLFileFailed {
    return Intl.message(
      'Cannot preview this eml file',
      name: 'previewEmailFromEMLFileFailed',
    );
  }

  String get cannotOpenNewWindow {
    return Intl.message(
      'Cannot open new window',
      name: 'cannotOpenNewWindow',
    );
  }

  String get downloadAttachmentInEMLPreviewWarningMessage {
    return Intl.message(
      'Downloading attachment. You can only download one file at a time.',
      name: 'downloadAttachmentInEMLPreviewWarningMessage',
    );
  }

  String get editAsNewEmail {
    return Intl.message(
      'Edit as new email',
      name: 'editAsNewEmail',
    );
  }

  String get thisHtmlAttachmentCannotBePreviewed {
    return Intl.message(
      'This html attachment cannot be previewed',
      name: 'thisHtmlAttachmentCannotBePreviewed',
    );
  }

  String get downloadAttachmentHasBeenCancelled {
    return Intl.message(
      'Download attachment has been cancelled',
      name: 'downloadAttachmentHasBeenCancelled',
    );
  }

  String get sizeDescending {
    return Intl.message(
      'Size descending',
      name: 'sizeDescending',
    );
  }

  String get sizeAscending {
    return Intl.message(
      'Size ascending',
      name: 'sizeAscending',
    );
  }

  String get markAsImportant {
    return Intl.message(
      'Mark as important',
      name: 'markAsImportant',
    );
  }

  String get markAsImportantIsEnabled {
    return Intl.message(
      'Mark as important is enabled',
      name: 'markAsImportantIsEnabled',
    );
  }

  String get markAsImportantIsDisabled {
    return Intl.message(
      'Mark as important is disabled',
      name: 'markAsImportantIsDisabled',
    );
  }

  String get turnOnMarkAsImportant {
    return Intl.message(
      'Turn on mark as important',
      name: 'turnOnMarkAsImportant',
    );
  }

  String get turnOffMarkAsImportant {
    return Intl.message(
      'Turn off mark as important',
      name: 'turnOffMarkAsImportant',
    );
  }

  String get preferences {
    return Intl.message(
      'Preferences',
      name: 'preferences',
    );
  }

  String get senderSetImportantFlag {
    return Intl.message(
      'Sender-set important flag',
      name: 'senderSetImportantFlag',
    );
  }

  String get senderImportantSettingExplanation {
    return Intl.message(
      'Enables display of important emails flag in your inbox. This feature is controlled by the sender and thus could result in abuses.',
      name: 'senderImportantSettingExplanation',
    );
  }

  String get senderImportantSettingToggleDescription {
    return Intl.message(
    'Display sender-set important flag',
    name: 'senderImportantSettingToggleDescription',
    );
  }

  String get hideAll {
    return Intl.message(
      'Hide all',
      name: 'hideAll',
    );
  }

  String get youHaveAnotherEventAtThatSameTime {
    return Intl.message(
      'You have another event at that same time',
      name: 'youHaveAnotherEventAtThatSameTime',
    );
  }

  String get exitFullscreen {
    return Intl.message(
      'Exit fullscreen',
      name: 'exitFullscreen',
    );
  }

  String get messageClipped {
    return Intl.message(
      '[Message clipped]',
      name: 'messageClipped',
    );
  }

  String get viewEntireMessage {
    return Intl.message(
      'View entire message',
      name: 'viewEntireMessage',
    );
  }

  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
    );
  }

  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
    );
  }

  String get deepRefresh {
    return Intl.message(
      'Deep refresh',
      name: 'deepRefresh',
    );
  }

  String get pullDownToRefresh {
    return Intl.message(
      'Pull down to refresh',
      name: 'pullDownToRefresh',
    );
  }

  String get releaseTo {
    return Intl.message(
      'Release to',
      name: 'releaseTo',
    );
  }

  String get pullHarderFor {
    return Intl.message(
      'Pull harder for',
      name: 'pullHarderFor',
    );
  }

  String get saveAsTemplate {
    return Intl.message(
      'Save as template',
      name: 'saveAsTemplate',
    );
  }

  String get savingTemplate {
    return Intl.message(
      'Saving template',
      name: 'savingTemplate',
    );
  }

  String get savingMessageToTemplateFolder {
    return Intl.message(
      'Saving message to template folder',
      name: 'savingMessageToTemplateFolder',
    );
  }

  String get saveMessageToTemplateSuccess {
    return Intl.message(
      'Save message to template folder successfully',
      name: 'saveMessageToTemplateSuccess',
    );
  }

  String get updateMessageToTemplateSuccess {
    return Intl.message(
      'Update message to template folder successfully',
      name: 'updateMessageToTemplateSuccess',
    );
  }

  String get saveMessageToTemplateFailed {
    return Intl.message(
      'Save message to template folder failed',
      name: 'saveMessageToTemplateFailed',
    );
  }

  String get saveMessageToTemplateCancelled {
    return Intl.message(
      'Save message to template folder has been cancelled',
      name: 'saveMessageToTemplateCancelled',
    );
  }

  String invalidArguments(String description) {
    return Intl.message(
      'Invalid arguments: "$description"',
      name: 'invalidArguments',
      args: [description],
    );
  }

  String get exportTraceLog {
    return Intl.message(
      'Export trace log',
      name: 'exportTraceLog',
    );
  }

  String get messageExportTraceLogDialog {
    return Intl.message(
      'The mobile API error message log has been tracked. Do you want to export it?',
      name: 'messageExportTraceLogDialog',
    );
  }

  String get youNeedToGrantFilesPermissionToExportFile {
    return Intl.message(
      'You need to grant files permission to export files',
      name: 'youNeedToGrantFilesPermissionToExportFile',
    );
  }

  String exportTraceLogSuccess(String path) {
    return Intl.message(
      'Export successful tracking logs at "$path"',
      name: 'exportTraceLogSuccess',
      args: [path],
    );
  }

  String get noLogsHaveBeenRecordedYet {
    return Intl.message(
      'No logs have been recorded yet.',
      name: 'noLogsHaveBeenRecordedYet',
    );
  }

  String get thread {
    return Intl.message(
      'Thread',
      name: 'thread',
    );
  }

  String get threadSettingExplanation {
    return Intl.message(
      'View multiple related emails like a conversation',
      name: 'threadSettingExplanation',
    );
  }

  String get threadToggleDescription {
    return Intl.message(
      'Enable thread',
      name: 'threadToggleDescription',
    );
  }

  String get exportTraceLogFailed {
    return Intl.message(
      'Export trace log failed',
      name: 'exportTraceLogFailed',
    );
  }

  String get support {
    return Intl.message(
      'Support',
      name: 'support',
    );
  }

  String get addRecipientsFailed {
    return Intl.message(
      'Adding recipient failed.',
      name: 'addRecipientsFailed',
    );
  }

  String get editLocalCopyInForwardFailed {
    return Intl.message(
      'Edit local copy in forward failed.',
      name: 'editLocalCopyInForwardFailed',
    );
  }

  String get deleteRecipientsFailed {
    return Intl.message(
      'Delete recipients failed.',
      name: 'deleteRecipientsFailed',
    );
  }

  String get youDoNotHaveAnyEmailInYourCurrentFolder {
    return Intl.message(
      'You don’t have any emails\n in this folder.',
      name: 'youDoNotHaveAnyEmailInYourCurrentFolder',
    );
  }

  String get startToComposeEmails {
    return Intl.message(
      'Start to compose emails.',
      name: 'startToComposeEmails',
    );
  }

  String get createFilter {
    return Intl.message(
      'Create filter',
      name: 'createFilter',
    );
  }

  String get createFilterRuleFailed {
    return Intl.message(
      'Create filter rule failed',
      name: 'createFilterRuleFailed',
    );
  }

  String get youAreNotInvitedToThisEventPleaseContactTheOrganizer {
    return Intl.message(
      'You are not invited to this event. Please contact the organizer.',
      name: 'youAreNotInvitedToThisEventPleaseContactTheOrganizer',
    );
  }

  String countMessageInSpam(String count) {
    return Intl.message(
      '$count message in spam',
      name: 'countMessageInSpam',
      args: [count],
    );
  }

  String get view {
    return Intl.message(
      'View',
      name: 'view',
    );
  }

  String daysAgo(int days) {
    return Intl.plural(
      days,
      zero: '',
      one: ' (1 day ago)',
      other: ' ($days days ago)',
      name: 'daysAgo',
      args: [days],
    );
  }

  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
    );
  }

  String get editEmail {
    return Intl.message(
      'Edit email',
      name: 'editEmail',
    );
  }

  String get createARule {
    return Intl.message(
      'Create a rule',
      name: 'createARule',
    );
  }

  String get enterSubjectKeywords {
    return Intl.message(
      'Enter subject keywords...',
      name: 'enterSubjectKeywords',
    );
  }

  String get addAnEmailAddress {
    return Intl.message(
      'Add an email address',
      name: 'addAnEmailAddress',
    );
  }

  String dialogRecoverDeletedMessagesDescription(String period) {
    return Intl.message(
      'You can recover messages deleted within the last $period days. Recovered emails will be restored to your recovered folder.',
      name: 'dialogRecoverDeletedMessagesDescription',
      args: [period],
    );
  }

  String get enterName {
    return Intl.message(
      'Enter name',
      name: 'enterName',
    );
  }

  String get enterEmailAddress {
    return Intl.message(
      'Enter email address',
      name: 'enterEmailAddress',
    );
  }

  String get creatingAnArchiveForDownloading {
    return Intl.message(
      'Creating an archive for downloading',
      name: 'creatingAnArchiveForDownloading',
    );
  }

  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
    );
  }

  String get keepACopyInInbox {
    return Intl.message(
      'Keep a copy in Inbox',
      name: 'keepACopyInInbox',
    );
  }

  String get keepACopyInInboxDescription {
    return Intl.message(
      'Store forwarded emails in your inbox as well as sending them to recipients',
      name: 'keepACopyInInboxDescription',
    );
  }

  String get dialogWarningTitleForForwardsToOtherDomains {
    return Intl.message(
      'You are redirecting emails to another domain.',
      name: 'dialogWarningTitleForForwardsToOtherDomains',
    );
  }

  String get dialogWarningMessageForForwardsToOtherDomains {
    return Intl.message(
      'This could be a security threat or considered illegal data extraction. Do you want to proceed?',
      name: 'dialogWarningMessageForForwardsToOtherDomains',
    );
  }

  String get hideSignature {
    return Intl.message(
      'Hide signature',
      name: 'hideSignature',
    );
  }

  String get showSignature {
    return Intl.message(
      'Show signature',
      name: 'showSignature',
    );
  }

  String get archiveMessagesFailed {
    return Intl.message(
      'Archive messages failed',
      name: 'archiveMessagesFailed',
    );
  }

  String get increaseYourSpace {
    return Intl.message(
      'Increase your space',
      name: 'increaseYourSpace',
    );
  }

  String quotaAvailableLabel(String count) {
    return Intl.message(
      '$count available',
      name: 'quotaAvailableLabel',
      args: [count],
    );
  }

  String get paywallUrlNotAvailable {
    return Intl.message(
      'Paywall url not available',
      name: 'paywallUrlNotAvailable',
    );
  }

  String get quotaBannerWarningTitle {
    return Intl.message(
      'You are running low on storage (90%)',
      name: 'quotaBannerWarningTitle',
    );
  }

  String get quotaBannerWarningSubtitleWithPremium {
    return Intl.message(
      'To keep sending messages and enjoying all Twake Mail features, please consider cleaning up or upgrading your storage.',
      name: 'quotaBannerWarningSubtitleWithPremium',
    );
  }

  String get quotaBannerWarningSubtitleWithoutPremium {
    return Intl.message(
      'To keep sending messages and enjoying all Twake Mail features, please consider cleaning up.',
      name: 'quotaBannerWarningSubtitleWithoutPremium',
    );
  }

  String get manageMyStorage {
    return Intl.message(
      'Manage my storage',
      name: 'manageMyStorage',
    );
  }

  String get addARule {
    return Intl.message(
      'Add a rule',
      name: 'addARule',
    );
  }

  String get noRulesConfigured {
    return Intl.message(
      'No Rules Configured',
      name: 'noRulesConfigured',
    );
  }

  String get messageExplanationNoRulesConfigured {
    return Intl.message(
      'Start by creating your first rule to automate\n email management.',
      name: 'messageExplanationNoRulesConfigured',
    );
  }

  String get createMyFirstRule {
    return Intl.message(
      'Create My First Rule',
      name: 'createMyFirstRule',
    );
  }

  String get createANewRule {
    return Intl.message(
      'Create a New Rule',
      name: 'createANewRule',
    );
  }

  String get ruleName {
    return Intl.message(
      'Rule Name',
      name: 'ruleName',
    );
  }

  String get condition {
    return Intl.message(
      'Condition',
      name: 'condition',
    );
  }

  String get addACondition {
    return Intl.message(
      'Add a condition',
      name: 'addACondition',
    );
  }

  String get actionsToPerform {
    return Intl.message(
      'Actions to Perform',
      name: 'actionsToPerform',
    );
  }

  String get addAnAction {
    return Intl.message(
      'Add an action',
      name: 'addAnAction',
    );
  }

  String get createRule {
    return Intl.message(
      'Create Rule',
      name: 'createRule',
    );
  }

  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
    );
  }

  String ruleFilterConditionPreviewMessage(String conditionCombinerName, String conditionValue) {
    return Intl.message(
      '$conditionCombinerName of the conditions: $conditionValue',
      name: 'ruleFilterConditionPreviewMessage',
      args: [
        conditionCombinerName,
        conditionValue,
      ],
    );
  }

  String get actions {
    return Intl.message(
      'Actions',
      name: 'actions',
    );
  }

  String get createANewFolder {
    return Intl.message(
      'Create a New Folder',
      name: 'createANewFolder',
    );
  }

  String subtitleDisplayTheFolderNameLocationInFolderCreationModal(String folderName) {
    return Intl.message(
      'New folder will be created inside $folderName',
      name: 'subtitleDisplayTheFolderNameLocationInFolderCreationModal',
      args: [folderName]
    );
  }

  String get folderName {
    return Intl.message(
      'Folder Name',
      name: 'folderName',
    );
  }

  String get enterTheFolderName {
    return Intl.message(
      'Enter the folder name',
      name: 'enterTheFolderName',
    );
  }

  String get selectTheFolderLocation {
    return Intl.message(
      'Select the folder location',
      name: 'selectTheFolderLocation',
    );
  }

  String get createFolder {
    return Intl.message(
      'Create folder',
      name: 'createFolder',
    );
  }

  String get sendMessage {
    return Intl.message(
      'Send message',
      name: 'sendMessage',
    );
  }

  String get attachmentReminderModalTitle {
    return Intl.message(
      'Forgot to attach a file?',
      name: 'attachmentReminderModalTitle',
    );
  }

  String attachmentReminderModalMessage(String keyword) {
    return Intl.message(
      'You wrote $keyword in your message but did not add any attachments. Do you still want to send?',
      name: 'attachmentReminderModalMessage',
      args: [keyword],
    );
  }

  String get spamReports {
    return Intl.message(
      'Spam reports',
      name: 'spamReports',
    );
  }

  String get spamReportsSettingExplanation {
    return Intl.message(
      'Reminds you that you need to moderate your spam emails recurringly',
      name: 'spamReportsSettingExplanation',
    );
  }

  String get spamReportToggleDescription {
    return Intl.message(
      'Enable spam report',
      name: 'spamReportToggleDescription',
    );
  }

  String get aiScribe {
    return Intl.message(
      'AI Scribe',
      name: 'aiScribe',
    );
  }

  String get aiScribeSettingExplanation {
    return Intl.message(
      'Use AI to help write and improve your emails',
      name: 'aiScribeSettingExplanation',
    );
  }

  String get aiScribeToggleDescription {
    return Intl.message(
      'Enable AI Scribe',
      name: 'aiScribeToggleDescription',
    );
  }

  String showMoreAttachmentButton(int count) {
    return Intl.message(
      'Show +$count more',
      name: 'showMoreAttachmentButton',
      args: [count],
    );
  }

  String hideAttachmentButton(int count) {
    return Intl.message(
      'Hide $count',
      name: 'hideAttachmentButton',
      args: [count],
    );
  }

  String get defaultIdentitySetupSuccessful {
    return Intl.message(
      'Default identity setup successful',
      name: 'defaultIdentitySetupSuccessful',
    );
  }

  String get storageSettingExplanation {
    return Intl.message(
      'Monitor your available space.',
      name: 'storageSettingExplanation',
    );
  }

  String get storageIsAlmostFullMessage {
    return Intl.message(
      'The storage is almost full. You can free up space by deleting unnecessary files or subscribe to get extra space.',
      name: 'storageIsAlmostFullMessage',
    );
  }

  String get upgradeStorage {
    return Intl.message(
      'Upgrade storage',
      name: 'upgradeStorage',
    );
  }

  String storageUsedMessage(String limit) {
    return Intl.message(
      'of $limit used',
      name: 'storageUsedMessage',
      args: [limit],
    );
  }

  String storageAvailableMessage(String count) {
    return Intl.message(
      'Available: $count',
      name: 'storageAvailableMessage',
      args: [count],
    );
  }

  String get mailHasBeenStarred {
    return Intl.message(
      'Mail has been starred',
      name: 'mailHasBeenStarred',
    );
  }

  String get mailHasBeenUnstarred {
    return Intl.message(
      'Mail has been unstarred',
      name: 'mailHasBeenUnstarred',
    );
  }

  String get keyboardShortcuts {
    return Intl.message(
      'Keyboard shortcuts',
      name: 'keyboardShortcuts',
    );
  }

  String get keyboardShortcutsSettingExplanation {
    return Intl.message(
      'Mailbox & email actions',
      name: 'keyboardShortcutsSettingExplanation',
    );
  }

  String get navigationAndClosing {
    return Intl.message(
      'Navigation & Closing',
      name: 'navigationAndClosing',
    );
  }

  String get readingAndReplying {
    return Intl.message(
      'Reading & Replying',
      name: 'readingAndReplying',
    );
  }

  String get messageManagementAndSelection {
    return Intl.message(
      'Message Management & Selection',
      name: 'messageManagementAndSelection',
    );
  }

  String get navigation {
    return Intl.message(
      'Navigation',
      name: 'navigation',
    );
  }

  String get reading {
    return Intl.message(
      'Reading',
      name: 'reading',
    );
  }

  String get closeMailComposer {
    return Intl.message(
      'Close mail composer',
      name: 'closeMailComposer',
    );
  }

  String get removeFocusFromSearch {
    return Intl.message(
      'Remove focus from search',
      name: 'removeFocusFromSearch',
    );
  }

  String get closeModalWindow {
    return Intl.message(
      'Close modal window',
      name: 'closeModalWindow',
    );
  }

  String get openNewMessage {
    return Intl.message(
      'Open new message',
      name: 'openNewMessage',
    );
  }

  String get mailComposer {
    return Intl.message(
      'Mail composer',
      name: 'mailComposer',
    );
  }

  String get focusOnSearch {
    return Intl.message(
      'Focus on search',
      name: 'focusOnSearch',
    );
  }

  String get openedModal {
    return Intl.message(
      'Opened modal',
      name: 'openedModal',
    );
  }

  String get mailboxList {
    return Intl.message(
      'Mailbox list',
      name: 'mailboxList',
    );
  }

  String get openedMailView {
    return Intl.message(
      'Opened mail view',
      name: 'openedMailView',
    );
  }

  String get mailboxListWithSelectedMail {
    return Intl.message(
      'Mailbox list (selected mail)',
      name: 'mailboxListWithSelectedMail',
    );
  }

  String get replyToAll {
    return Intl.message(
      'Reply to all',
      name: 'replyToAll',
    );
  }

  String get deleteMessage {
    return Intl.message(
      'Delete message',
      name: 'deleteMessage',
    );
  }

  String get moveFolderContent {
    return Intl.message(
      'Move folder content',
      name: 'moveFolderContent',
    );
  }

  String get moveFolderContentToastMessage {
    return Intl.message(
      'Failed to move all emails from this folder to another folder.',
      name: 'moveFolderContentToastMessage',
    );
  }

  String get favoriteMailboxDisplayName {
    return Intl.message(
      'Starred',
      name: 'favoriteMailboxDisplayName',
    );
  }

  String get insertLink {
    return Intl.message(
      'Insert link',
      name: 'insertLink',
    );
  }

  String get goTo {
    return Intl.message(
      'Go to',
      name: 'goTo',
    );
  }

  String get change {
    return Intl.message(
      'Change',
      name: 'change',
    );
  }

  String get removeLink {
    return Intl.message(
      'Remove link',
      name: 'removeLink',
    );
  }

  String get text {
    return Intl.message(
      'Text',
      name: 'text',
    );
  }

  String get typeOrPasteLink {
    return Intl.message(
      'Type or paste a link',
      name: 'typeOrPasteLink',
    );
  }

  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
    );
  }

  String get manageYourTwakeAccount {
    return Intl.message(
      'Manage your Twake account',
      name: 'manageYourTwakeAccount',
    );
  }

  String get youDoNotHaveAnyFavoritesEmails {
    return Intl.message(
      'You don’t have any favorites emails.',
      name: 'youDoNotHaveAnyFavoritesEmails',
    );
  }

  String get startToAddFavoritesEmails {
    return Intl.message(
      'Start to add favorites emails',
      name: 'startToAddFavoritesEmails',
    );
  }

  String get labels {
    return Intl.message(
      'Labels',
      name: 'labels',
    );
  }

  String get newLabel {
    return Intl.message(
      'New label',
      name: 'newLabel',
    );
  }

  String get labelName {
    return Intl.message(
      'Label name',
      name: 'labelName',
    );
  }

  String get pleaseEnterNameYourNewLabel {
    return Intl.message(
      'Please enter the name of your new label',
      name: 'pleaseEnterNameYourNewLabel',
    );
  }

  String get chooseALabelColor {
    return Intl.message(
      'Choose a label color',
      name: 'chooseALabelColor',
    );
  }

  String get createLabel {
    return Intl.message(
      'Create label',
      name: 'createLabel',
    );
  }

  String get createANewLabel {
    return Intl.message(
      'Create a new label',
      name: 'createANewLabel',
    );
  }

  String get organizeYourInboxWithACustomCategory {
    return Intl.message(
      'Organize your inbox with a custom category',
      name: 'organizeYourInboxWithACustomCategory',
    );
  }

  String get tagNameAlreadyExists {
    return Intl.message(
      'A tag with this name already exists. Please choose a different name.',
      name: 'tagNameAlreadyExists',
    );
  }

  String get chooseCustomColour {
    return Intl.message(
      'Choose custom colour',
      name: 'chooseCustomColour',
    );
  }

  String get chooseAColourForThisLabel {
    return Intl.message(
      'Choose a colour for this label',
      name: 'chooseAColourForThisLabel',
    );
  }

  String createLabelSuccessfullyMessage(String labelName) {
    return Intl.message(
      'You successfully created the $labelName label',
      name: 'createLabelSuccessfullyMessage',
      args: [labelName],
    );
  }

  String get createNewLabelFailure {
    return Intl.message(
      'Create new label failure',
      name: 'createNewLabelFailure',
    );
  }

  String get labelVisibility {
    return Intl.message(
      'Label visibility',
      name: 'labelVisibility',
    );
  }

  String get labelVisibilitySettingExplanation {
    return Intl.message(
      'Show labels assigned to emails directly in your message list for easier categorization.',
      name: 'labelVisibilitySettingExplanation',
    );
  }

  String get labelVisibilityToggleDescription {
    return Intl.message(
      'Display labels',
      name: 'labelVisibilityToggleDescription',
    );
  }

  String get theLabelFeatureIsNowAvailable {
    return Intl.message(
      'The label feature is now available.',
      name: 'theLabelFeatureIsNowAvailable',
    );
  }

  String get labelAs {
    return Intl.message(
      'Label as',
      name: 'labelAs',
    );
  }

  String addLabelToEmailSuccessfullyMessage(String labelName) {
    return Intl.message(
      'Email added to the "$labelName" label',
      name: 'addLabelToEmailSuccessfullyMessage',
      args: [labelName],
    );
  }

  String addLabelToEmailFailureMessage(String labelName) {
    return Intl.message(
      'Cannot add email to the "$labelName" label',
      name: 'addLabelToEmailFailureMessage',
      args: [labelName],
    );
  }

  String get addLabel {
    return Intl.message(
      'Add label',
      name: 'addLabel',
    );
  }

  String addLabelToThreadSuccessfullyMessage(String labelName) {
    return Intl.message(
      'All emails in thread added to the "$labelName" label',
      name: 'addLabelToThreadSuccessfullyMessage',
      args: [labelName],
    );
  }

  String addLabelToThreadFailureMessage(String labelName) {
    return Intl.message(
      'Cannot add all emails in thread to the "$labelName" label',
      name: 'addLabelToThreadFailureMessage',
      args: [labelName],
    );
  }

  String removeLabelFromEmailSuccessfullyMessage(String labelName) {
    return Intl.message(
      'Email removed from the "$labelName" label',
      name: 'removeLabelFromEmailSuccessfullyMessage',
      args: [labelName],
    );
  }

  String removeLabelFromEmailFailureMessage(String labelName) {
    return Intl.message(
      'Cannot remove email from the "$labelName" label',
      name: 'removeLabelFromEmailFailureMessage',
      args: [labelName],
    );
  }

  String removeLabelFromThreadSuccessfullyMessage(String labelName) {
    return Intl.message(
      'All emails in thread removed from the "$labelName" label',
      name: 'removeLabelFromThreadSuccessfullyMessage',
      args: [labelName],
    );
  }

  String removeLabelFromThreadFailureMessage(String labelName) {
    return Intl.message(
      'Cannot remove all emails from thread to the "$labelName" label',
      name: 'removeLabelFromThreadFailureMessage',
      args: [labelName],
    );
  }
}
