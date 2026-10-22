const _hideDraftSignatureAppends =
    'HideDraftSignatureTransformer appends display: none; on every pass';

/// Composer rule failures that are product findings, keyed by test name with
/// the reason. A fix deletes its entries.
const knownComposerFailures = <String, String>{
  'forEditDraftsEmail-web sending_clients/twake_signature_drive is idempotent':
      _hideDraftSignatureAppends,
};
