import '../navigation/nexabiz_navigation_contribution.dart';
import 'capability_metadata.dart';

/// Abstract interface representing a NexaBiz Capability runtime unit.
///
/// A capability represents the application's logical runtime unit.
/// It MUST have exactly one runtime identity (`capabilityId`).
///
/// This contract MUST remain framework-neutral.
/// It MUST NOT import Flutter UI, GoRouter, Riverpod, or shadcn_flutter.
abstract interface class NexaBizCapability {
  /// Unique runtime capability identifier (e.g. 'demo', 'financial').
  String get capabilityId;

  /// Presentation-independent capability metadata.
  CapabilityMetadata get metadata;

  /// List of capability IDs this capability depends on.
  List<String> get dependsOn;

  /// Optional navigation contribution declared by this capability.
  NexaBizNavigationContribution? get navigationContribution;
}
