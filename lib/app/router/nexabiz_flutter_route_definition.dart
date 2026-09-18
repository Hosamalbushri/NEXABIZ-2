import 'package:flutter/widgets.dart';

import '../../core/navigation/nexabiz_route_definition.dart';

/// Flutter presentation binding for framework-neutral navigation metadata.
///
/// Every Flutter route requires a callback with a checked widget result.
/// Router implementation types remain inside the router adapter.
class NexaBizFlutterRouteDefinition extends NexaBizRouteDefinition {
  final Widget Function(BuildContext context) pageBuilder;

  const NexaBizFlutterRouteDefinition({
    required super.routeId,
    required super.path,
    required this.pageBuilder,
  });
}
