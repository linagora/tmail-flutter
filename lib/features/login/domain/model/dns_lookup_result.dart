import 'package:equatable/equatable.dart';

/// A JMAP server found through a DNS SRV lookup, and whether the answer came
/// over an encrypted resolver (DNS-over-HTTPS).
///
/// A plaintext answer (system or public UDP resolver) can be spoofed by anyone
/// on the network path, so the user confirms that server before the app
/// sends anything to it.
class DnsLookupResult with EquatableMixin {
  final String target;
  final bool isEncrypted;

  const DnsLookupResult({required this.target, required this.isEncrypted});

  @override
  List<Object?> get props => [target, isEncrypted];
}
