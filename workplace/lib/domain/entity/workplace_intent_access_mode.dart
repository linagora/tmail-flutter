/// How a Drive intent request authenticates: same shape for callers,
/// diverse implementation per variant.
sealed class WorkplaceIntentAccessMode {
  const WorkplaceIntentAccessMode();
}

/// Container app already holds the stack session; no token needed.
class BridgeAccessMode extends WorkplaceIntentAccessMode {
  const BridgeAccessMode();
}

/// Direct REST call authenticated with an exchanged Drive access token.
class BearerTokenAccessMode extends WorkplaceIntentAccessMode {
  final String accessToken;
  const BearerTokenAccessMode(this.accessToken);
}
