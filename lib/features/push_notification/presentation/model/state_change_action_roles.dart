/// Which parts of a push [StateChange] an account may run (ADR-0114 Sync).
class StateChangeActionRoles {
  final bool refreshView;
  final bool storeOfflineBodies;
  final bool updateDeliveryAndNotifications;

  const StateChangeActionRoles({
    this.refreshView = true,
    this.storeOfflineBodies = true,
    this.updateDeliveryAndNotifications = true,
  });

  static const all = StateChangeActionRoles();

  bool get hasForegroundEmailWork =>
      refreshView || storeOfflineBodies || updateDeliveryAndNotifications;
}
