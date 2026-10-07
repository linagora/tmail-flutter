/// What a Workplace request carries.
class WorkplaceRequestBody {
  final Object? data;
  final Map<String, String> headers;
  final Map<String, dynamic> extra;

  const WorkplaceRequestBody({
    this.data,
    this.headers = const {},
    this.extra = const {},
  });
}
