import 'package:shadcn_flutter/shadcn_flutter.dart' hide Card;
import 'package:nexabiz_ui/nexabiz_ui.dart';

/// Minimal demo page created solely to verify capability registration,
/// navigation contribution, GoRouter adapter translation, and NexaBiz UI package consumption.
class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NexaBiz Demo Capability').h2(),
          const Gap(4),
          const Text('Verified clean architecture capability registration & shadcn_flutter integration').muted(),
        ],
      ),
      child: SurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                AppStatusBadge(
                  label: 'Capability Architecture Verified',
                  tone: AppStatusTone.success,
                  animate: false,
                ),
              ],
            ),
            const Gap(16),
            const Text('NexaBiz Demo Capability').h2(),
            const Gap(8),
            Text(
              'This capability exists to prove capability registration, topological sorting, '
              'navigation registry resolution, GoRouter infrastructure adaptation, and '
              'canonical NexaBiz UI design system integration.',
            ).p(),
            const Gap(24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Architecture Principles').h4(),
                  const Gap(6),
                  const Text('Clean Modular / Ports & Adapters').muted(),
                  const Gap(12),
                  Text('• Capability is the runtime application unit.').p(),
                  Text('• Package is the physical implementation boundary.').p(),
                  Text('• Navigation is declared by capabilities.').p(),
                  Text('• GoRouter is an infrastructure adapter.').p(),
                  Text('• UI components come from canonical NexaBiz UI package.').p(),
                ],
              ),
            ),
            const Gap(24),
            Row(
              spacing: 12,
              children: [
                PrimaryButton(
                  onPressed: () {},
                  child: const Text('System Ready'),
                ),
                OutlineButton(
                  onPressed: () {},
                  child: const Text('Documentation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
