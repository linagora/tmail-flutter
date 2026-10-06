/// How a Workplace call authenticates: same shape for callers,
/// diverse implementation per variant.
sealed class WorkplaceAccessMode {
  const WorkplaceAccessMode();
}

/// Container app already holds the stack session; no token needed.
final class BridgeAccessMode extends WorkplaceAccessMode {
  const BridgeAccessMode();
}

/// Direct REST call authenticated with an exchanged Drive access token.
final class BearerTokenAccessMode extends WorkplaceAccessMode {
  final String accessToken;
  const BearerTokenAccessMode(this.accessToken);
}
