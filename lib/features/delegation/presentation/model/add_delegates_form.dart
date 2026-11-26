import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';

enum AddDelegatesStep { pick, confirm }

/// Why a typed or picked address cannot become a delegate.
enum DelegateAddressRefusal { invalid, yourself, alreadyDelegate, alreadyPicked }

/// An address picked in the add dialog. [isRejected] once the server refused it.
class DelegateCandidate with EquatableMixin {
  final EmailAddress emailAddress;
  final bool isRejected;

  const DelegateCandidate(this.emailAddress, {this.isRejected = false});

  String get username => emailAddress.emailAddress;

  @override
  List<Object?> get props => [emailAddress, isRejected];
}

class AddDelegatesForm with EquatableMixin {
  final List<DelegateCandidate> candidates;
  final AddDelegatesStep step;
  final bool isSubmitting;

  /// Text typed in the field but not yet a chip.
  final String pendingAddress;

  const AddDelegatesForm({
    this.candidates = const [],
    this.step = AddDelegatesStep.pick,
    this.isSubmitting = false,
    this.pendingAddress = '',
  });

  bool get canGoNext =>
      candidates.isNotEmpty && candidates.every((candidate) => !candidate.isRejected);

  /// Next picks the typed address first, so typed text alone is enough to press it.
  bool get canPressNext =>
      candidates.every((candidate) => !candidate.isRejected) &&
      (candidates.isNotEmpty || pendingAddress.trim().isNotEmpty);

  AddDelegatesForm copyWith({
    List<DelegateCandidate>? candidates,
    AddDelegatesStep? step,
    bool? isSubmitting,
    String? pendingAddress,
  }) {
    return AddDelegatesForm(
      candidates: candidates ?? this.candidates,
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      pendingAddress: pendingAddress ?? this.pendingAddress,
    );
  }

  @override
  List<Object?> get props => [candidates, step, isSubmitting, pendingAddress];
}

/// What a tap on Add led to.
sealed class AddDelegatesSubmission {
  const AddDelegatesSubmission();
}

/// A repeat tap while a request runs, or nothing to send.
class AddDelegatesIgnored extends AddDelegatesSubmission {
  const AddDelegatesIgnored();
}

/// The request failed, so its outcome on the server is unknown.
class AddDelegatesFailed extends AddDelegatesSubmission {
  const AddDelegatesFailed();
}

class AddDelegatesSucceeded extends AddDelegatesSubmission {
  final AddDelegatesResult result;

  const AddDelegatesSucceeded(this.result);
}
