import 'package:flutter_test/flutter_test.dart';

/// Centralized Architecture Exception Registry for NexaBiz Phase 03-E.
///
/// Tracks exact legacy debt items.
/// - Any NEW violation not registered here causes a test failure.
/// - Any REMOVED violation (stale exception) causes a test failure to ensure the allowlist shrinks.
class ArchitectureException {
  final String ruleId;
  final String filePath;
  final String reason;
  final String targetPhase;

  const ArchitectureException({
    required this.ruleId,
    required this.filePath,
    required this.reason,
    required this.targetPhase,
  });
}

class ArchitectureExceptionRegistry {
  static const List<ArchitectureException> _exceptions = [
    // Rule 3: Direct shadcn_flutter import
    ArchitectureException(
      ruleId: 'RULE-03-DIRECT-SHADCN',
      filePath: 'lib/presentation/showcase/nexabiz_ui_showcase_page.dart',
      reason: 'Dedicated Showcase / Component Gallery demonstration page',
      targetPhase: 'Phase 04',
    ),

    // Rule 7: Breakpoint bypass (MediaQuery width query)
    ArchitectureException(
      ruleId: 'RULE-07-BREAKPOINT-AUTHORITY',
      filePath: 'lib/presentation/showcase/nexabiz_ui_showcase_page.dart',
      reason: 'Showcase gallery layout width query',
      targetPhase: 'Phase 04',
    ),
  ];

  static List<ArchitectureException> get exceptions =>
      List.unmodifiable(_exceptions);

  /// Verifies if [filePath] is an authorized exception for [ruleId].
  static bool isAllowedException(String ruleId, String filePath) {
    final normalizedPath = _normalizePath(filePath);
    return _exceptions.any(
      (e) => e.ruleId == ruleId && _normalizePath(e.filePath) == normalizedPath,
    );
  }

  /// Evaluates violations found during a scan against registered exceptions.
  /// Asserts:
  /// 1. Zero unallowed new violations (New Violation Regression).
  /// 2. Zero registered exceptions that were NOT found (Stale Exception Failure).
  static void assertExactViolations({
    required String ruleId,
    required List<String> scannedViolatingFiles,
  }) {
    final normalizedScanned = scannedViolatingFiles.map(_normalizePath).toSet();
    final registeredForRule = _exceptions
        .where((e) => e.ruleId == ruleId)
        .map((e) => _normalizePath(e.filePath))
        .toSet();

    // 1. Detect new unallowed violations
    final newViolations = normalizedScanned.difference(registeredForRule);
    expect(
      newViolations,
      isEmpty,
      reason:
          'NEW ARCHITECTURAL REGRESSION DETECTED for [$ruleId]!\n'
          'The following files violate architecture guardrails and are NOT registered in ArchitectureExceptionRegistry:\n'
          '${newViolations.map((p) => '  - $p').join('\n')}\n'
          'Do NOT add broad exemptions. Migrate the file to canonical nexabiz_ui abstractions or register explicit Phase 04 exception with justification.\n',
    );

    // 2. Detect stale exceptions (allowlist entries that no longer violate rule)
    final staleExceptions = registeredForRule.difference(normalizedScanned);
    expect(
      staleExceptions,
      isEmpty,
      reason:
          'STALE ARCHITECTURE EXCEPTION DETECTED for [$ruleId]!\n'
          'The following registered exceptions NO LONGER produce violations:\n'
          '${staleExceptions.map((p) => '  - $p').join('\n')}\n'
          'Please remove these stale entries from ArchitectureExceptionRegistry to shrink migration debt!\n',
    );
  }

  static String _normalizePath(String path) {
    return path.replaceAll('\\', '/').replaceAll(RegExp(r'^\./'), '');
  }
}
