import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../theme/tokens/tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_form.dart';
import '../../widgets/app_form_sheet.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_tree.dart';

class AccountNodeData {
  AccountNodeData({
    required this.code,
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    this.isParent = false,
    this.balance,
    this.level = 0,
    List<AccountNodeData>? children,
  }) : children = children ?? [];

  String code;
  String titleAr;
  String titleEn;
  IconData icon;
  bool isParent;
  String? balance;
  int level;
  final List<AccountNodeData> children;

  void sortChildren() {
    children.sort((a, b) => a.code.compareTo(b.code));
    for (final child in children) {
      child.sortChildren();
    }
  }
}

class TreeScenario extends StatefulWidget {
  const TreeScenario({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<TreeScenario> createState() => _TreeScenarioState();
}

class _TreeScenarioState extends State<TreeScenario> {
  final Set<String> _expandedCodes = {'1000', '1100', '1110', '2000'};
  String? _selectedCode;

  late final List<AccountNodeData> _accountsTree = [
    AccountNodeData(
      code: '1000',
      titleAr: 'الأصول',
      titleEn: 'Assets',
      icon: shadcn.LucideIcons.folder,
      isParent: true,
      level: 0,
      children: [
        AccountNodeData(
          code: '1100',
          titleAr: 'الأصول المتداولة',
          titleEn: 'Current Assets',
          icon: shadcn.LucideIcons.folderOpen,
          isParent: true,
          level: 1,
          children: [
            AccountNodeData(
              code: '1110',
              titleAr: 'النقدية وما في حكمها',
              titleEn: 'Cash & Banks',
              icon: shadcn.LucideIcons.wallet,
              isParent: true,
              level: 2,
              children: [
                AccountNodeData(
                  code: '1111',
                  titleAr: 'صندوق النقدية الرئيسي',
                  titleEn: 'Main Cash Safe',
                  icon: shadcn.LucideIcons.banknote,
                  isParent: false,
                  balance: '150,000 ر.س',
                  level: 3,
                ),
                AccountNodeData(
                  code: '1112',
                  titleAr: 'البنك الأهلي السعودي (SNB)',
                  titleEn: 'SNB Bank Account',
                  icon: shadcn.LucideIcons.landmark,
                  isParent: false,
                  balance: '1,250,000 ر.س',
                  level: 3,
                ),
              ],
            ),
            AccountNodeData(
              code: '1120',
              titleAr: 'العملاء وحسابات المدينين',
              titleEn: 'Receivables',
              icon: shadcn.LucideIcons.users,
              isParent: true,
              level: 2,
              children: [
                AccountNodeData(
                  code: '1121',
                  titleAr: 'شركة الأمل للتجارة',
                  titleEn: 'Al-Amal Trading Co.',
                  icon: shadcn.LucideIcons.userCheck,
                  isParent: false,
                  balance: '45,000 ر.س',
                  level: 3,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    AccountNodeData(
      code: '2000',
      titleAr: 'الالتزامات',
      titleEn: 'Liabilities',
      icon: shadcn.LucideIcons.folder,
      isParent: true,
      level: 0,
      children: [
        AccountNodeData(
          code: '2100',
          titleAr: 'الموردين والحسابات الدائنة',
          titleEn: 'Payables',
          icon: shadcn.LucideIcons.shoppingBag,
          isParent: true,
          level: 1,
          children: [
            AccountNodeData(
              code: '2110',
              titleAr: 'موردو المواد الخام',
              titleEn: 'Raw Material Suppliers',
              icon: shadcn.LucideIcons.truck,
              isParent: false,
              balance: '88,500 ر.س',
              level: 2,
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sortTree();
  }

  void _sortTree() {
    _accountsTree.sort((a, b) => a.code.compareTo(b.code));
    for (final root in _accountsTree) {
      root.sortChildren();
    }
  }

  bool _insertNode(List<AccountNodeData> list, String parentCode, AccountNodeData newNode) {
    for (final node in list) {
      if (node.code == parentCode) {
        node.isParent = true;
        node.children.add(newNode);
        node.sortChildren();
        return true;
      }
      if (node.children.isNotEmpty) {
        if (_insertNode(node.children, parentCode, newNode)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _deleteNode(List<AccountNodeData> list, String targetCode) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].code == targetCode) {
        list.removeAt(i);
        return true;
      }
      if (list[i].children.isNotEmpty) {
        if (_deleteNode(list[i].children, targetCode)) {
          return true;
        }
      }
    }
    return false;
  }


  List<AppDropdownItem<String>> _getParentDropdownItems() {
    final items = <AppDropdownItem<String>>[];
    void collect(List<AccountNodeData> list) {
      for (final node in list) {
        if (node.isParent) {
          items.add(AppDropdownItem(
            value: node.code,
            label: '${node.code} - ${widget.isArabic ? node.titleAr : node.titleEn}',
          ));
          collect(node.children);
        }
      }
    }
    collect(_accountsTree);
    return items;
  }

  int _findParentLevel(List<AccountNodeData> list, String parentCode) {
    for (final node in list) {
      if (node.code == parentCode) return node.level;
      if (node.children.isNotEmpty) {
        final lvl = _findParentLevel(node.children, parentCode);
        if (lvl != -1) return lvl;
      }
    }
    return -1;
  }

  void _toggleExpand(String code) {
    setState(() {
      if (_expandedCodes.contains(code)) {
        _expandedCodes.remove(code);
      } else {
        _expandedCodes.add(code);
      }
    });
  }

  void _expandAll() {
    setState(() {
      void addAll(AccountNodeData node) {
        if (node.isParent) {
          _expandedCodes.add(node.code);
          for (final child in node.children) {
            addAll(child);
          }
        }
      }
      for (final root in _accountsTree) {
        addAll(root);
      }
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedCodes.clear();
    });
  }

  shadcn.TreeNode<AccountNodeData> _buildTreeNode(AccountNodeData data) {
    return shadcn.TreeItemNode<AccountNodeData>(
      data: data,
      expanded: _expandedCodes.contains(data.code),
      children: data.children.map(_buildTreeNode).toList(),
    );
  }

  void _openAddTreeNodeSheet({String? defaultParentCode}) {
    final isAr = widget.isArabic;
    final targetParent = defaultParentCode ?? _selectedCode ?? '1110';

    AppFormSheet.show<void>(
      context: context,
      title: isAr ? 'إضافة حساب جديد بالدليل' : 'Add New Chart Account',
      subtitle: isAr
          ? 'إضافة حساب فرعي أو رئيسي تدرجياً تحت المجموعة المُحددة'
          : 'Create sub-account or parent node under target group',
      onSubmit: (ctx, values) {},
      child: AppTreeCreationForm(
        isArabic: isAr,
        parentGroups: _getParentDropdownItems(),
        initialParentCode: targetParent,
        onAddAccount: (newAcc, parentCode) {
          setState(() {
            final parentLvl = _findParentLevel(_accountsTree, parentCode);
            final createdNode = AccountNodeData(
              code: newAcc.code,
              titleAr: newAcc.titleAr,
              titleEn: newAcc.titleEn,
              icon: newAcc.isParent
                  ? shadcn.LucideIcons.folderOpen
                  : shadcn.LucideIcons.fileText,
              isParent: newAcc.isParent,
              balance: newAcc.balance,
              level: parentLvl != -1 ? parentLvl + 1 : 1,
            );

            final inserted = _insertNode(_accountsTree, parentCode, createdNode);
            if (!inserted) {
              _accountsTree.add(createdNode);
            }
            _sortTree();
            _expandedCodes.add(parentCode);
            _selectedCode = newAcc.code;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAr
                    ? 'تمت إضافة الحساب (${newAcc.code} - ${newAcc.titleAr}) وتنسيقه بالدليل المحاسبي بنجاح!'
                    : 'Account (${newAcc.code} - ${newAcc.titleEn}) added & sorted successfully!',
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleDeleteNode(AccountNodeData node) {
    final isAr = widget.isArabic;
    if (node.children.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'لا يمكن حذف حساب رئيسي يتضمن حسابات فرعية!'
                : 'Cannot delete a parent account with sub-accounts!',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _deleteNode(_accountsTree, node.code);
      if (_selectedCode == node.code) _selectedCode = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? 'تم حذف الحساب (${node.code} - ${node.titleAr}) من الدليل المحاسبي.'
              : 'Deleted account (${node.code} - ${node.titleEn}).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final treeNodes = _accountsTree.map(_buildTreeNode).toList();

    return Column(
      children: [
        // Scenario Header Toolbar
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.card,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.border.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr
                              ? 'دليل الحسابات الشجري التفاعلي'
                              : 'Interactive Chart of Accounts Tree',
                          style: theme.typography.h4.copyWith(
                            fontFamily: AppTypography.fontFamilyName,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr
                              ? 'حدد أي فرع لإضافة حسابات عليه مع الترتيب والطي والفتح التفاعلي'
                              : 'Select any node branch to add accounts with instant sorting & toggle',
                          style: theme.typography.small.copyWith(
                            color: colorScheme.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    label: isAr ? 'إضافة حساب' : 'Add Account',
                    icon: shadcn.LucideIcons.plus,
                    isCompact: true,
                    onPressed: () => _openAddTreeNodeSheet(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  shadcn.OutlineButton(
                    onPressed: _expandAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(shadcn.LucideIcons.chevronsDown, size: 14),
                        const SizedBox(width: 4),
                        Text(isAr ? 'توسيع الكل' : 'Expand All'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  shadcn.OutlineButton(
                    onPressed: _collapseAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(shadcn.LucideIcons.chevronsUp, size: 14),
                        const SizedBox(width: 4),
                        Text(isAr ? 'طي الكل' : 'Collapse All'),
                      ],
                    ),
                  ),
                  if (_selectedCode != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(shadcn.LucideIcons.circleCheck, size: 12, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${isAr ? "المُحدد:" : "Selected:"} $_selectedCode',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Interactive Tree Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppTree<AccountNodeData>(
              nodes: treeNodes,
              shrinkWrap: true,
              branchLine: shadcn.BranchLine.path,
              builder: (ctx, node) {
                final item = node.data;
                final isExpanded = _expandedCodes.contains(item.code);
                final isSelected = _selectedCode == item.code;

                Color levelBg;
                if (isSelected) {
                  levelBg = colorScheme.primary.withValues(alpha: 0.15);
                } else if (item.level == 0) {
                  levelBg = colorScheme.primary.withValues(alpha: 0.05);
                } else if (item.level == 1) {
                  levelBg = colorScheme.muted.withValues(alpha: 0.12);
                } else {
                  levelBg = Colors.transparent;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCode = item.code;
                      if (item.isParent) {
                        _toggleExpand(item.code);
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: levelBg,
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected
                          ? Border.all(color: colorScheme.primary, width: 1.2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Chevron expand/collapse toggle button
                        if (item.isParent)
                          GestureDetector(
                            onTap: () => _toggleExpand(item.code),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              child: Icon(
                                isExpanded
                                    ? shadcn.LucideIcons.chevronDown
                                    : (isAr
                                        ? shadcn.LucideIcons.chevronLeft
                                        : shadcn.LucideIcons.chevronRight),
                                size: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 24),

                        Expanded(
                          child: AppTreeNodeRow<String>(
                            title: Text(
                              isAr ? item.titleAr : item.titleEn,
                              style: TextStyle(
                                fontWeight: item.isParent ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.foreground,
                              ),
                            ),
                            leading: Icon(
                              item.icon,
                              size: item.isParent ? 18 : 16,
                              color: isSelected
                                  ? colorScheme.primary
                                  : (item.isParent
                                      ? colorScheme.primary
                                      : colorScheme.mutedForeground),
                            ),
                            level: item.level,
                            badges: [
                              if (item.balance != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.balance!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                            trailing: Text(
                              item.code,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: AppTypography.fontFamilyName,
                                fontWeight: item.isParent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            onAddChild: () => _openAddTreeNodeSheet(defaultParentCode: item.code),
                            onDelete: () => _handleDeleteNode(item),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Form Widget for Creating a Tree Node (Account / Group)
class AppTreeCreationForm extends StatefulWidget {
  const AppTreeCreationForm({
    super.key,
    required this.isArabic,
    required this.parentGroups,
    required this.initialParentCode,
    required this.onAddAccount,
  });

  final bool isArabic;
  final List<AppDropdownItem<String>> parentGroups;
  final String initialParentCode;
  final void Function(AccountNodeData account, String parentCode) onAddAccount;

  @override
  State<AppTreeCreationForm> createState() => _AppTreeCreationFormState();
}

class _AppTreeCreationFormState extends State<AppTreeCreationForm> {
  late final TextEditingController _codeController;
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _balanceController;
  late String _parentAccount;
  String _accountType = 'sub';
  String _category = 'asset';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _parentAccount = widget.initialParentCode;
    _codeController = TextEditingController(text: '${_parentAccount}1');
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _balanceController = TextEditingController(text: '0.00');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final code = _codeController.text.trim();
    final nameAr = _nameArController.text.trim();
    final nameEn = _nameEnController.text.trim();
    final bal = _balanceController.text.trim();

    if (code.isEmpty || nameAr.isEmpty) {
      return;
    }

    final isParentNode = _accountType == 'parent';
    final formattedBalance = !isParentNode && bal.isNotEmpty ? '$bal ر.س' : null;

    final newAcc = AccountNodeData(
      code: code,
      titleAr: nameAr,
      titleEn: nameEn.isNotEmpty ? nameEn : nameAr,
      icon: isParentNode ? shadcn.LucideIcons.folderOpen : shadcn.LucideIcons.fileText,
      isParent: isParentNode,
      balance: formattedBalance,
    );

    widget.onAddAccount(newAcc, _parentAccount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFormSection(
          title: isAr ? 'معلومات العقدة والحساب' : 'Account Node Info',
          children: [
            AppFormRow(
              children: [
                AppTextField(
                  label: isAr ? 'رمز الحساب' : 'Account Code',
                  controller: _codeController,
                  required: true,
                  hint: 'e.g. 1113',
                ),
                AppDropdown<String>(
                  label: isAr ? 'الحساب الأب (المجموعة)' : 'Parent Group',
                  value: _parentAccount,
                  required: true,
                  items: widget.parentGroups,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _parentAccount = val;
                        _codeController.text = '${val}1';
                      });
                    }
                  },
                ),
              ],
            ),
            AppFormRow(
              children: [
                AppTextField(
                  label: isAr ? 'اسم الحساب (عربي)' : 'Account Name (Arabic)',
                  controller: _nameArController,
                  required: true,
                  hint: isAr ? 'مثال: بنك الراجحي' : 'e.g. Al-Rajhi Bank',
                ),
                AppTextField(
                  label: isAr ? 'اسم الحساب (إنجليزي)' : 'Account Name (English)',
                  controller: _nameEnController,
                  hint: 'e.g. Al Rajhi Bank',
                ),
              ],
            ),
            AppFormRow(
              children: [
                AppDropdown<String>(
                  label: isAr ? 'نوع العقدة' : 'Node Type',
                  value: _accountType,
                  items: [
                    AppDropdownItem(
                      value: 'parent',
                      label: isAr ? 'حساب رئيسي (مجموعة)' : 'Parent Group',
                    ),
                    AppDropdownItem(
                      value: 'sub',
                      label: isAr ? 'حساب فرعي (تفصيلي)' : 'Sub Account',
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _accountType = val);
                  },
                ),
                AppDropdown<String>(
                  label: isAr ? 'تصنيف القائمة' : 'Financial Statement',
                  value: _category,
                  items: [
                    AppDropdownItem(
                      value: 'asset',
                      label: isAr ? 'الميزانية - الأصول' : 'Balance Sheet - Assets',
                    ),
                    AppDropdownItem(
                      value: 'liability',
                      label: isAr ? 'الميزانية - الالتزامات' : 'Balance Sheet - Liabilities',
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ],
            ),
            if (_accountType == 'sub') ...[
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                label: isAr ? 'الرصيد الافتتاحي (ر.س)' : 'Opening Balance (SAR)',
                controller: _balanceController,
                hint: '0.00',
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppSwitch(
              label: isAr ? 'حساب نشط ومتاح للعمليات' : 'Active Account Node',
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: isAr ? 'حفظ العقدة وإضافتها للدليل' : 'Save & Insert Account Node',
              icon: shadcn.LucideIcons.check,
              onPressed: _submitForm,
            ),
          ],
        ),
      ],
    );
  }
}
