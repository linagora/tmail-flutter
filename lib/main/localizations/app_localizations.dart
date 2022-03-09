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

  String get login_text_login_to_continue {
    return Intl.message('Please login to continue',
        name: 'login_text_login_to_continue');
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

  String get my_folders {
    return Intl.message(
      'MY FOLDERS',
      name: 'my_folders',
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

  String get your_email_should_have_at_least_one_recipient {
    return Intl.message(
      'Your email should have at least one recipient',
      name: 'your_email_should_have_at_least_one_recipient',
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

  String get move_to_mailbox {
    return Intl.message(
      'Move to mailbox',
      name: 'move_to_mailbox',
    );
  }

  String get mark_as_star {
    return Intl.message(
      'Star',
      name: 'mark_as_star',
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

  String count_attachment(int count) {
    return Intl.message(
        '$count attachments',
        name: 'count_attachment',
        args: [count]
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

  String get undo_action {
    return Intl.message(
        'UNDO',
        name: 'undo_action'
    );
  }

  String get mark_as_unstar {
    return Intl.message(
      'Unstar',
      name: 'mark_as_unstar',
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

  String get logout {
    return Intl.message('Logout',
        name: 'logout');
  }

  String get hint_search_mailboxes {
    return Intl.message(
        'Search for mailboxes',
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

  String get mailbox_location {
    return Intl.message(
      'Mailbox location',
      name: 'mailbox_location',
    );
  }

  String get default_mailbox {
    return Intl.message(
      'Default mailbox',
      name: 'default_mailbox',
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

  String get details {
    return Intl.message(
        'Details',
        name: 'details');
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
}