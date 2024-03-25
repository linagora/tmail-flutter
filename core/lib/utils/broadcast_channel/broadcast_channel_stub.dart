class BroadcastChannel {
  final String name;

  BroadcastChannel(this.name);

  Stream<dynamic> get onMessage => const Stream.empty();
}