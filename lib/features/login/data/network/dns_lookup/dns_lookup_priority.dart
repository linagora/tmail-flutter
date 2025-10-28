/// Represents the priority order and description of different DNS lookup modes.
///
/// Priority level increases with fallback order:
/// 1 → System default
/// 2 → Public resolvers (UDP/TCP or DOH)
/// 3 → Cloud resolvers (Google/Cloudflare)
enum DnsLookupPriority {
  /// Uses the device's system-configured DNS (e.g., from ISP or OS settings).
  system(1, 'System Default'),

  /// Uses open DNS resolvers accessible via UDP/TCP (e.g., Quad9, OpenDNS).
  publicUdp(2, 'Public DNS (UDP/TCP)'),

  /// Uses DNS-over-HTTPS (DoH) resolvers for secure name resolution.
  publicDoh(2, 'Public DNS (DoH)'),

  /// Uses Google or Cloudflare DNS resolvers.
  cloud(3, 'Cloud DNS (Google/Cloudflare)');

  /// The lookup priority (lower means higher priority).
  final int priority;

  /// A human-readable description for UI or logging.
  final String label;

  const DnsLookupPriority(this.priority, this.label);
}
