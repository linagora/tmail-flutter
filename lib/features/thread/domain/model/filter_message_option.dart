import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

enum FilterMessageOption {
  all(_NoCriterion()),
  unread(_UnreadCriterion()),
  attachments(_AttachmentCriterion()),
  starred(_StarredCriterion());

  const FilterMessageOption(this._criterion);

  final _SearchCriterion _criterion;

  /// Whether [email] passes this option's client-side filter.
  bool filterEmail(Email email) => _criterion.matchesEmail(email);

  /// Whether this option's criterion is currently set on [filter].
  bool isActiveIn(SearchEmailFilter filter) => _criterion.isActiveIn(filter);

  /// Sets this option's criterion on [filter] (search chips + JMAP query).
  SearchEmailFilter applyTo(SearchEmailFilter filter) =>
      _criterion.write(filter, active: true);

  /// Clears this option's criterion from [filter] (undo of [applyTo]).
  SearchEmailFilter removeFrom(SearchEmailFilter filter) =>
      _criterion.write(filter, active: false);
}

/// The one filter dimension a [FilterMessageOption] maps to, over a cached
/// [Email] and the committed [SearchEmailFilter]. A new option means a new
/// criterion, never editing a switch (Open/Closed).
abstract class _SearchCriterion {
  const _SearchCriterion();

  bool matchesEmail(Email email);

  bool isActiveIn(SearchEmailFilter filter);

  SearchEmailFilter write(SearchEmailFilter filter, {required bool active});
}

class _NoCriterion extends _SearchCriterion {
  const _NoCriterion();

  @override
  bool matchesEmail(Email email) => true;

  @override
  bool isActiveIn(SearchEmailFilter filter) => false;

  @override
  SearchEmailFilter write(SearchEmailFilter filter, {required bool active}) =>
      filter;
}

class _UnreadCriterion extends _SearchCriterion {
  const _UnreadCriterion();

  @override
  bool matchesEmail(Email email) => !email.hasRead;

  @override
  bool isActiveIn(SearchEmailFilter filter) => filter.unread;

  @override
  SearchEmailFilter write(SearchEmailFilter filter, {required bool active}) =>
      filter.copyWith(unreadOption: Some(active));
}

class _AttachmentCriterion extends _SearchCriterion {
  const _AttachmentCriterion();

  @override
  bool matchesEmail(Email email) => email.withAttachments;

  @override
  bool isActiveIn(SearchEmailFilter filter) => filter.hasAttachment;

  @override
  SearchEmailFilter write(SearchEmailFilter filter, {required bool active}) =>
      filter.copyWith(hasAttachmentOption: Some(active));
}

class _StarredCriterion extends _SearchCriterion {
  const _StarredCriterion();

  @override
  bool matchesEmail(Email email) => email.hasStarred;

  @override
  bool isActiveIn(SearchEmailFilter filter) => filter.isContainFlagged;

  @override
  SearchEmailFilter write(SearchEmailFilter filter, {required bool active}) {
    final keywords = Set<String>.of(filter.hasKeyword);
    final flagged = KeyWordIdentifier.emailFlagged.value;
    active ? keywords.add(flagged) : keywords.remove(flagged);
    return filter.copyWith(hasKeywordOption: Some(keywords));
  }
}
