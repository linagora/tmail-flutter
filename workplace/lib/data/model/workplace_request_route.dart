/// What a Workplace request targets on the stack.
class WorkplaceRequestRoute {
  final String method;
  final List<String> pathSegments;
  final Map<String, String> queryParameters;

  const WorkplaceRequestRoute({
    required this.method,
    required this.pathSegments,
    this.queryParameters = const {},
  });
}
