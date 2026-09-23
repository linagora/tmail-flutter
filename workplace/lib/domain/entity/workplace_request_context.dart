import 'workplace_access_mode.dart';

/// The platform origin plus the resolved transport for one request.
class WorkplaceRequestContext {
  final Uri platformUrl;
  final WorkplaceAccessMode accessMode;

  const WorkplaceRequestContext({
    required this.platformUrl,
    required this.accessMode,
  });
}
