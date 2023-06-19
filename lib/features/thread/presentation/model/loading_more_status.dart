
enum LoadingMoreStatus {
  idle,
  running,
  completed;

  bool get isRunning => this == LoadingMoreStatus.running;
}