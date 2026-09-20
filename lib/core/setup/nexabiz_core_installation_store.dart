import 'initialize_nexabiz_core.dart';
import 'nexabiz_setup_readiness.dart';

/// Storage-neutral access to authoritative Core initialization facts.
abstract interface class NexaBizCoreInstallationStore {
  Future<NexaBizSetupReadiness> readReadiness();

  Future<NexaBizSetupReadiness> initialize(CoreInitializationRecords records);

  Future<void> close();
}
