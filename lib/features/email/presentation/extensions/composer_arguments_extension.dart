import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

extension ComposerArgumentsExtension on ComposerArguments {

  ComposerArguments withIdentity({List<Identity>? identities, IdentityId? selectedIdentityId}) {
    return copyWith(
      identities: identities,
      selectedIdentityId: selectedIdentityId,
    );
  }
}