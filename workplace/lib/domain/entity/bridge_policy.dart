/// How a [WorkplaceCall] may ride the Cozy bridge.
enum BridgePolicy {
  /// Always bearer token: the bridge has no implementation for this call.
  never,

  /// Bridge when available; a bridge failure is the call's failure.
  noBearerReplay,

  /// Bridge when available; a bridge failure replays over bearer token. Idempotent calls only.
  bearerReplay,
}
