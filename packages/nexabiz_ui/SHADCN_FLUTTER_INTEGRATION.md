# NEXABIZ UI FOUNDATION: SHADCN_FLUTTER COMPONENT INTEGRATION GUIDE

This document serves as the authoritative developer reference for UI component usage within the NexaBiz ERP system.

---

## 1. ARCHITECTURAL PRINCIPLE

```text
shadcn_flutter (v0.0.53)
        ↓
NexaBiz UI Integration Layer (packages/nexabiz_ui)
        ↓
NexaBiz Application Pages
        ↓
NexaBiz Packages
```

`shadcn_flutter` is the primary and single visual authority.
Do NOT create parallel custom button, input, or container systems. Use the verified package primitives directly or compose them inside `packages/nexabiz_ui`.

---

## 2. THEME & INITIALIZATION

Initialize your application root using `ShadcnApp` (or `ShadcnApp.router` for GoRouter):

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  runApp(
    ShadcnApp.router(
      title: 'NexaBiz ERP',
      routerConfig: appRouter,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        ShadcnLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
    ),
  );
}
```

---

## 3. CANONICAL COMPONENT USAGE MATRIX

| ERP Requirement | Canonical Primitive | Code Example | Notes |
| --- | --- | --- | --- |
| Primary Action Button | `PrimaryButton` | `PrimaryButton(onPressed: _save, child: Text('Save'))` | Use for main form save/submit |
| Secondary Action Button | `SecondaryButton` | `SecondaryButton(onPressed: _cancel, child: Text('Cancel'))` | Low-emphasis options |
| Destructive Action | `DestructiveButton` | `DestructiveButton(onPressed: _delete, child: Text('Delete'))` | Critical record deletion |
| Text Field | `TextField` | `TextField(controller: _ctrl, placeholder: Text('Name'))` | Standard single-line input |
| Dropdown Selection | `Select<T>` | `Select(value: _val, children: [...])` | Popover item picker |
| Date Selection | `DatePicker` | `DatePicker(value: _date, onChanged: _onDate)` | ERP voucher date picker |
| Data Grid / Table | `Table` | `Table(columns: [...], rows: [...])` | Ledger / transaction rows |
| Card Container | `Card` | `Card(header: Text('Header'), child: ...)` | Standard surface panel |
| Modal Popup | `AlertDialog` | `showDialog(context: context, builder: ...)` | Action confirmations |
| Toast Notification | `showToast` | `showToast(context: context, builder: ...)` | Operation status feedback |

---

## 4. DENSITY & RTL GUIDELINES

1. **RTL Support**: All text styles automatically inherit the Cairo font family. Directionality is set ambiently by `ShadcnApp` or `Directionality`.
2. **Density**: Use `DensityContentPadding` or `DensityContainerPadding` when creating dense ERP tables or compact forms.
3. **Typography Extensions**:
   - `.h1()` for main page title
   - `.h2()` for section headers
   - `.h3()` for card titles
   - `.p()` for standard body text
   - `.muted()` for caption / secondary details

---

## 5. COMMON MISTAKES TO AVOID

- ❌ **Do NOT** instantiate `ElevatedButton`, `OutlinedButton`, or `TextButton` from Material. Use `PrimaryButton`, `OutlineButton`, or `SecondaryButton` from `shadcn_flutter`.
- ❌ **Do NOT** wrap `shadcn_flutter` buttons in custom `NexaBizButton` classes.
- ❌ **Do NOT** create custom global color constants for primary/border colors—access them via `Theme.of(context).colorScheme`.
- ❌ **Do NOT** fork component source code into `packages/nexabiz_ui`.
