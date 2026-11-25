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

  const AddDelegatesForm({
    this.candidates = const [],
    this.step = AddDelegatesStep.pick,
    this.isSubmitting = false,
  });

  bool get canGoNext =>
      candidates.isNotEmpty && candidates.every((candidate) => !candidate.isRejected);

  AddDelegatesForm copyWith({
    List<DelegateCandidate>? candidates,
    AddDelegatesStep? step,
    bool? isSubmitting,
  }) {
    return AddDelegatesForm(
      candidates: candidates ?? this.candidates,
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [candidates, step, isSubmitting];
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
