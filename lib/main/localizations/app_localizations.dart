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
    return Intl.message('Team Mail',
        name: 'login_text_slogan');
  }

  String get loginInputUrlMessage {
    return Intl.message('To login and access your message please connect to your JMAP server', name: 'loginInputUrlMessage');
  }

  String get loginInputCredentialMessage {
    return Intl.message('Enter your credentials to sign in', name: 'loginInputCredentialMessage');
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

  String get unknown_error_login_message {
    return Intl.message('Unknown error occurred, please try again',
        name: 'unknown_error_login_message');
  }

  String get search_folder {
    return Intl.message(
      'Search folder',
      name: 'search_folder',
    );
  }

  String get storage {
    return Intl.message(
      'STORAGE',
      name: 'storage',
    );
  }

  String get myFolders {
    return Intl.message(
      'My Folders',
      name: 'myFolders',
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

  String get no_emails {
    return Intl.message(
      'No emails in this mailbox',
      name: 'no_emails',
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
        '$count Attachments ($totalSize):',
        name: 'titleHeaderAttachment',
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

  String moved_to_mailbox(String destinationMailboxPath) {
    return Intl.message(
        'Moved to $destinationMailboxPath',
        name: 'moved_to_mailbox',
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

  String get hint_search_mailboxes {
    return Intl.message(
        'Search mailboxes',
        name: 'hint_search_mailboxes');
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

  String get message_has_been_sent_failure {
    return Intl.message(
      'Message has been sent failure',
      name: 'message_has_been_sent_failure',
    );
  }

  String get done {
    return Intl.message(
        'Done',
        name: 'done'
    );
  }

  String get new_mailbox {
    return Intl.message(
      'New mailbox',
      name: 'new_mailbox',
    );
  }

  String get name_of_mailbox_is_required {
    return Intl.message(
      'Name of mailbox is required',
      name: 'name_of_mailbox_is_required',
    );
  }

  String get mailbox_name_cannot_contain_special_characters {
    return Intl.message(
      'Mailbox name cannot contain special characters',
      name: 'mailbox_name_cannot_contain_special_characters',
    );
  }

  String get this_folder_name_is_already_taken {
    return Intl.message(
      'This folder name is already taken',
      name: 'this_folder_name_is_already_taken',
    );
  }

  String new_mailbox_is_created(String nameMailbox) {
    return Intl.message(
        '$nameMailbox is created',
        name: 'new_mailbox_is_created',
        args: [nameMailbox]
    );
  }

  String get create_new_mailbox_failure {
    return Intl.message(
        'Create new mailbox failure',
        name: 'create_new_mailbox_failure'
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

  String get hint_input_create_new_mailbox {
    return Intl.message(
        'Enter name of mailbox',
        name: 'hint_input_create_new_mailbox'
    );
  }

  String get rename {
    return Intl.message(
        'Rename',
        name: 'rename');
  }

  String get delete_mailboxes_successfully {
    return Intl.message(
        'Delete mailboxes successfully',
        name: 'delete_mailboxes_successfully');
  }

  String get delete_mailboxes_failure {
    return Intl.message(
        'Delete mailboxes failure',
        name: 'delete_mailboxes_failure');
  }

  String get delete_mailboxes {
    return Intl.message(
        'Delete mailboxes',
        name: 'delete_mailboxes');
  }

  String message_confirmation_dialog_delete_mailbox(String nameMailbox) {
    return Intl.message(
        '"$nameMailbox" mailbox and all of the sub-folders and messages it contains will be deleted and won\'t be able to recover. Do you want to continue to delete?',
        name: 'message_confirmation_dialog_delete_mailbox',
        args: [nameMailbox]
    );
  }

  String get rename_mailbox {
    return Intl.message(
        'Rename mailbox',
        name: 'rename_mailbox');
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

  String get copy_email_address {
    return Intl.message(
        'Copy email address',
        name: 'copy_email_address');
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
        'Tmail',
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

  String get mark_all_as_read {
    return Intl.message(
      'Mark all as read',
      name: 'mark_all_as_read',
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

  String get page_name {
    return Intl.message(
        'Team - Mail',
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
        'You are about to permanently delete all items in Trash . Do you want to continue?',
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
        'You are about to permanently delete $count items in $mailboxName . Do you want to continue?',
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

  String get move_message {
    return Intl.message(
      'Move message',
      name: 'move_message',
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

  String get identities {
    return Intl.message('Identities',
        name: 'identities');
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

  String get reply_to_address {
    return Intl.message(
        'Reply to address',
        name: 'reply_to_address');
  }

  String get bcc_to_address {
    return Intl.message(
        'Bcc to address',
        name: 'bcc_to_address');
  }

  String get signature {
    return Intl.message(
        'Signature',
        name: 'signature');
  }

  String get plain_text {
    return Intl.message(
        'Plain text',
        name: 'plain_text');
  }

  String get html_template {
    return Intl.message(
        'Html template',
        name: 'html_template');
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

  String get moveMailbox {
    return Intl.message(
      'Move mailbox',
      name: 'moveMailbox',
    );
  }

  String get deleteMailbox {
    return Intl.message(
        'Delete mailbox',
        name: 'deleteMailbox');
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

  String get allMailboxes {
    return Intl.message(
        'All mailboxes',
        name: 'allMailboxes');
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

  String get form {
    return Intl.message(
      'From',
      name: 'form',
    );
  }

  String get to {
    return Intl.message(
      'To',
      name: 'to',
    );
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

  String get mailbox {
    return Intl.message(
      'Mailbox',
      name: 'mailbox',
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

  String get allMails {
    return Intl.message(
      'All mails',
      name: 'allMails',
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

  String get selectMailbox {
    return Intl.message(
      'Select Mailbox',
      name: 'selectMailbox',
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

  String get languageAndRegionSubtitle {
    return Intl.message(
        'Set the language, time zone, time format you use on TeamMail.',
        name: 'languageAndRegionSubtitle');
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

  String get codeView {
    return Intl.message(
        'Code view',
        name: 'codeView');
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
        'Perform the following action:',
        name: 'actionTitleRulesFilter');
  }

  String get toMailbox {
    return Intl.message(
        'To mailbox:',
        name: 'toMailbox');
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

  String get noStartTime {
    return Intl.message(
      'No start time',
      name: 'noStartTime',
    );
  }

  String get noEndTime {
    return Intl.message(
      'No end time',
      name: 'noEndTime',
    );
  }

  String get noEndDate {
    return Intl.message(
      'No end date',
      name: 'noEndDate',
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
        'Delete recipient',
        name: 'deleteRecipient');
  }

  String get toastMessageDeleteRecipientSuccessfully {
    return Intl.message(
        'The email has been removed from the recipient list.',
        name: 'toastMessageDeleteRecipientSuccessfully');
  }

  String get messageConfirmationDialogDeleteAllRecipientForward {
    return Intl.message(
        'Do you want to delete all email?',
        name: 'messageConfirmationDialogDeleteAllRecipientForward'
    );
  }

  String get addRecipients {
    return Intl.message(
      'Add Recipients',
      name: 'addRecipients',
    );
  }

  String get recipientsLabel {
    return Intl.message(
      'Name or Email address',
      name: 'recipientsLabel',
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

  String get keepLocalCopyForwardLabel {
    return Intl.message(
      'Keep local copy',
      name: 'keepLocalCopyForwardLabel',
    );
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

  String get toastErrorMessageWhenCreateNewRule {
    return Intl.message(
        'You have not filled in the information completely.',
        name: 'toastErrorMessageWhenCreateNewRule');
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

  String get requestReadReceipt {
    return Intl.message(
      'Request read receipt',
      name: 'requestReadReceipt',
    );
  }
}