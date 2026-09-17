/// Metadata for a NexaBiz capability.
///
/// MUST NOT contain presentation-specific or framework-specific objects such as
/// Flutter Widgets, BuildContext, GoRoute instances, or state management providers.
class CapabilityMetadata {
  /// Localizable key for the capability display name.
  final String nameKey;

  /// Identifier for the capability icon.
  final String iconIdentifier;

  /// Relative sort order for display or processing precedence.
  final int sortOrder;

  const CapabilityMetadata({
    required this.nameKey,
    required this.iconIdentifier,
    this.sortOrder = 0,
  });
}
