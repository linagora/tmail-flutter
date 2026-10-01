/// Represents the priority order and description of different DNS lookup modes.
///
/// DoH first, so a spoofed cleartext reply cannot redirect discovery.
/// System DNS next, so VPN split-horizon `_jmap` records still resolve.
/// Distinct levels keep the order deterministic (`List.sort` is not stable).
/// 1 → Public resolvers over DoH
/// 2 → System default
/// 3 → Public resolvers over UDP/TCP
/// 4 → Cloud resolvers (Google/Cloudflare)
enum DnsLookupPriority {
  /// Uses the device's system-configured DNS (e.g., from ISP or OS settings).
  system(2, 'System Default'),

  /// Uses open DNS resolvers accessible via UDP/TCP (e.g., Quad9, OpenDNS).
  publicUdp(3, 'Public DNS (UDP/TCP)'),

  /// Uses DNS-over-HTTPS (DoH) resolvers for secure name resolution.
  publicDoh(1, 'Public DNS (DoH)'),

  /// Uses Google or Cloudflare DNS resolvers.
  cloud(4, 'Cloud DNS (Google/Cloudflare)');

  /// The lookup priority (lower means higher priority).
  final int priority;

  /// A human-readable description for UI or logging.
  final String label;

  const DnsLookupPriority(this.priority, this.label);
}
