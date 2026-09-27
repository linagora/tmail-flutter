/// Represents the priority order and description of different DNS lookup modes.
///
/// Priority level increases with fallback order. Authenticated, integrity-
/// protected transports (DNS-over-HTTPS, over TLS) are tried FIRST, because
/// the cleartext UDP/TCP resolvers do not validate the DNS transaction id or
/// the answered name and are therefore spoofable by an off-path attacker on a
/// hostile network. Cleartext is kept only as a last-resort fallback for
/// networks that block DoH.
/// 1 → Public DNS-over-HTTPS
/// 2 → Cloud resolvers (Google/Cloudflare, over DoH)
/// 3 → System default (cleartext, last resort)
/// 4 → Public resolvers over cleartext UDP/TCP (last resort)
enum DnsLookupPriority {
  /// Uses DNS-over-HTTPS (DoH) resolvers for secure name resolution.
  publicDoh(1, 'Public DNS (DoH)'),

  /// Uses Google or Cloudflare DNS resolvers (over DoH).
  cloud(2, 'Cloud DNS (Google/Cloudflare)'),

  /// Uses the device's system-configured DNS (e.g., from ISP or OS settings).
  system(3, 'System Default'),

  /// Uses open DNS resolvers accessible via cleartext UDP/TCP (e.g., Quad9, OpenDNS).
  publicUdp(4, 'Public DNS (UDP/TCP)');

  /// The lookup priority (lower means higher priority).
  final int priority;

  /// A human-readable description for UI or logging.
  final String label;

  const DnsLookupPriority(this.priority, this.label);
}
