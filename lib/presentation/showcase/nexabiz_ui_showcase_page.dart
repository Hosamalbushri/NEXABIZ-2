import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

/// NexaBiz UI Foundation Showcase & Verification Reference Surface
///
/// Demonstrates canonical usage of verified `shadcn_flutter` v0.0.53 components,
/// theme integration, Cairo typography, density modes, and RTL/LTR directionality.
class NexaBizUiShowcasePage extends StatefulWidget {
  const NexaBizUiShowcasePage({super.key});

  @override
  State<NexaBizUiShowcasePage> createState() => _NexaBizUiShowcasePageState();
}

class _NexaBizUiShowcasePageState extends State<NexaBizUiShowcasePage> {
  bool _isDark = false;
  bool _isRtl = false;
  Density _density = Density.defaultDensity;
  int _selectedTabIndex = 0;

  // Form State Demo
  final TextEditingController _textController = TextEditingController(text: 'Sample ERP Input');
  final TextEditingController _textAreaController = TextEditingController(text: 'Sample Multi-line Voucher Notes');
  bool _checkboxValue = true;
  bool _switchValue = false;
  String? _selectedSelect = 'sales';

  @override
  void dispose() {
    _textController.dispose();
    _textAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _isDark ? AppTheme.dark(density: _density) : AppTheme.light(density: _density);

    return Theme(
      data: themeData,
      child: Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          headers: [
            AppBar(
              title: const Text('NexaBiz UI Foundation Showcase'),
              subtitle: const Text('Verified shadcn_flutter v0.0.53 Integration Reference'),
              trailing: [
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: () => setState(() => _isRtl = !_isRtl),
                  child: Text(_isRtl ? 'LTR' : 'RTL'),
                ),
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: () => setState(() => _isDark = !_isDark),
                  child: Icon(_isDark ? LucideIcons.sun : LucideIcons.moon),
                ),
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: () {
                    setState(() {
                      _density = _density == Density.defaultDensity
                          ? Density.compactDensity
                          : Density.defaultDensity;
                    });
                  },
                  child: Text(_density == Density.compactDensity ? 'Std' : 'Compact'),
                ),
              ],
            ),
            const Divider(),
          ],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AppContainer.page(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const Gap(24),
                  _buildFoundationOverviewSection(context),
                  const Gap(24),
                  _buildTypographySection(),
                  const Gap(24),
                  _buildButtonsSection(),
                  const Gap(24),
                  _buildFormsSection(),
                  const Gap(24),
                  _buildSurfacesSection(),
                  const Gap(24),
                  _buildTableSection(),
                  const Gap(24),
                  _buildNavigationSection(),
                  const Gap(24),
                  _buildOverlaysSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoundationOverviewSection(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tier = AppBreakpoints.getTier(width);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('0. UI Foundation Primitives (AppContainer & AppResponsive)', style: AppTypography.sectionTitle(context)),
          const Gap(12),
          Text(
            'Current Viewport: ${width.toStringAsFixed(1)}px | Active Tier: ${tier.name.toUpperCase()} '
            '(${AppBreakpoints.isCompact(width) ? 'Compact/Mobile' : 'Expanded/Desktop'})',
            style: AppTypography.body(context),
          ),
          const Gap(16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SecondaryBadge(child: Text('AppContainer.page (1200px)')),
              SecondaryBadge(child: Text('AppContainer.form (640px)')),
              SecondaryBadge(child: Text('AppContainer.details (960px)')),
              SecondaryBadge(child: Text('AppContainer.table (1440px)')),
              SecondaryBadge(child: Text('AppContainer.settings (800px)')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NexaBiz Design System Foundation').h2(),
          const Gap(8),
          const Text(
            'This surface demonstrates direct composition of canonical shadcn_flutter v0.0.53 primitives. '
            'All theme tokens, typography, radii, and density rules adapt seamlessly.',
          ).p(),
          const Gap(16),
          Row(
            spacing: 12,
            children: [
              PrimaryBadge(child: const Text('Version: 0.0.53')),
              SecondaryBadge(child: const Text('Font: Cairo')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypographySection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Typography (Cairo Family)').h3(),
          const Gap(12),
          const Text('Heading 1 - NexaBiz ERP Dashboard').h1(),
          const Text('Heading 2 - Financial Accounting Overview').h2(),
          const Text('Heading 3 - General Ledger Transactions').h3(),
          const Text('Heading 4 - Invoice Line Items').h4(),
          const Text('Paragraph - Standard body text supporting both English and Arabic directionality natively.').p(),
          const Text('Lead Text - High emphasis introductory description text.').lead(),
          const Text('Muted Text - Secondary detail description or footnote caption.').muted(),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('2. Buttons & Actions').h3(),
          const Gap(16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PrimaryButton(
                onPressed: () {},
                child: const Text('Primary Action'),
              ),
              SecondaryButton(
                onPressed: () {},
                child: const Text('Secondary Action'),
              ),
              OutlineButton(
                onPressed: () {},
                child: const Text('Outline Button'),
              ),
              GhostButton(
                onPressed: () {},
                child: const Text('Ghost Action'),
              ),
              DestructiveButton(
                onPressed: () {},
                child: const Text('Destructive Action'),
              ),
              IconButton.outline(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
              ),
              PrimaryButton(
                onPressed: null,
                child: const Text('Disabled Action'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormsSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3. Form Components').h3(),
          const Gap(16),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Text Input').small(),
                    const Gap(6),
                    TextField(
                      controller: _textController,
                      placeholder: const Text('Enter product name...'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select / Dropdown').small(),
                    const Gap(6),
                    Select<String>(
                      value: _selectedSelect,
                      onChanged: (val) => setState(() => _selectedSelect = val),
                      placeholder: const Text('Choose module...'),
                      itemBuilder: (context, item) => Text(item),
                      popup: (context) => SelectGroup(
                        children: [
                          SelectItemButton(value: 'sales', child: const Text('Sales Module')),
                          SelectItemButton(value: 'purchasing', child: const Text('Purchasing Module')),
                          SelectItemButton(value: 'inventory', child: const Text('Inventory Module')),
                          SelectItemButton(value: 'financial', child: const Text('Financial Module')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Text Area').small(),
              const Gap(6),
              TextArea(
                controller: _textAreaController,
                placeholder: const Text('Enter journal entry notes...'),
              ),
            ],
          ),
          const Gap(16),
          Row(
            spacing: 24,
            children: [
              Row(
                spacing: 8,
                children: [
                  Checkbox(
                    state: _checkboxValue ? CheckboxState.checked : CheckboxState.unchecked,
                    onChanged: (state) => setState(() => _checkboxValue = state == CheckboxState.checked),
                  ),
                  const Text('Enable Automatic Posting'),
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  Switch(
                    value: _switchValue,
                    onChanged: (val) => setState(() => _switchValue = val),
                  ),
                  const Text('Multi-Currency Support'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurfacesSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('4. Surfaces & Data Display').h3(),
          const Gap(16),
          Row(
            spacing: 16,
            children: [
              const Avatar(
                initials: 'NB',
              ),
              PrimaryBadge(
                child: const Text('Active Account'),
              ),
              Chip(
                child: const Text('Fiscal Year 2026'),
              ),
              const SizedBox(
                width: 100,
                height: 24,
              ).asSkeleton(),
            ],
          ),
          const Gap(16),
          const Alert(
            leading: Icon(LucideIcons.info),
            title: Text('System Audit Status'),
            content: Text('All financial ledgers and document sequence generators are operating under strict tenant isolation.'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('5. Data Table (ERP Grid)').h3(),
          const Gap(16),
          Table(
            rows: [
              const TableHeader(
                cells: [
                  TableCell(child: Text('Doc #')),
                  TableCell(child: Text('Account')),
                  TableCell(child: Text('Debit')),
                  TableCell(child: Text('Credit')),
                  TableCell(child: Text('Status')),
                ],
              ),
              TableRow(
                cells: [
                  const TableCell(child: Text('JV-2026-001')),
                  const TableCell(child: Text('10100 - Cash on Hand')),
                  const TableCell(child: Text('\$5,000.00')),
                  const TableCell(child: Text('\$0.00')),
                  TableCell(child: PrimaryBadge(child: const Text('POSTED'))),
                ],
              ),
              TableRow(
                cells: [
                  const TableCell(child: Text('JV-2026-002')),
                  const TableCell(child: Text('40100 - Sales Revenue')),
                  const TableCell(child: Text('\$0.00')),
                  const TableCell(child: Text('\$5,000.00')),
                  TableCell(child: PrimaryBadge(child: const Text('POSTED'))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('6. Tabs & Navigation UI').h3(),
          const Gap(16),
          Tabs(
            index: _selectedTabIndex,
            onChanged: (index) => setState(() => _selectedTabIndex = index),
            children: const [
              TabItem(child: Text('Overview')),
              TabItem(child: Text('Transactions')),
              TabItem(child: Text('Settings')),
            ],
          ),
          const Gap(12),
          SurfaceCard(
            child: Text(
              _selectedTabIndex == 0
                  ? 'Overview Panel Content: Financial summary cards & KPIs.'
                  : _selectedTabIndex == 1
                      ? 'Transactions Panel Content: Detailed journal entry rows.'
                      : 'Settings Panel Content: Module parameters configuration.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlaysSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('7. Dialogs & Overlays').h3(),
          const Gap(16),
          Wrap(
            spacing: 12,
            children: [
              OutlineButton(
                onPressed: () {
                  showOverlay(
                    context,
                    DialogConfiguration(
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Confirm Posting'),
                        content: const Text('Are you sure you want to post Voucher JV-2026-001 to the general ledger?'),
                        actions: [
                          GhostButton(
                            onPressed: () => closeOverlay(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          PrimaryButton(
                            onPressed: () => closeOverlay(dialogContext),
                            child: const Text('Post Voucher'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Open Modal Dialog'),
              ),
              OutlineButton(
                onPressed: () {
                  showToast(
                    context: context,
                    builder: (toastContext, overlay) {
                      return SurfaceCard(
                        child: Row(
                          spacing: 8,
                          children: [
                            const Icon(LucideIcons.circleCheck),
                            const Text('Voucher posted successfully.'),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text('Show Toast Feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
