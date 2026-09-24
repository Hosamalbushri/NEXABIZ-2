import 'package:flutter/widgets.dart';

import '../utils/digit_normalization.dart';

/// Authoritative canonical selection option model for NexaBiz ERP.
///
/// Encapsulates the selectable [value] of generic type [T], its display [label],
/// optional [subtitle], optional leading [icon], and search keywords for filtering.
@immutable
class AppSelectOption<T> {
  const AppSelectOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.enabled = true,
    this.keywords = const [],
    this.searchKey,
  });

  /// The underlying value represented by this option.
  final T value;

  /// The primary human-readable display label.
  final String label;

  /// Optional secondary descriptive text displayed beneath [label].
  final String? subtitle;

  /// Optional leading icon or avatar widget.
  final Widget? icon;

  /// Whether this option is enabled for user selection.
  final bool enabled;

  /// Additional keywords used for fuzzy and text-based search queries.
  final List<String> keywords;

  /// An explicit search key if different from [label].
  final String? searchKey;

  /// Evaluates whether this option matches the given [query].
  ///
  /// Performs case-insensitive, Unicode-aware, and digit-normalized matching
  /// against [label], [subtitle], [searchKey], and [keywords].
  bool matchesQuery(String query) {
    final cleanQuery = normalizeDigitsToWestern(query).trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    final normLabel = normalizeDigitsToWestern(label).toLowerCase();
    if (normLabel.contains(cleanQuery)) return true;

    if (subtitle != null) {
      final normSub = normalizeDigitsToWestern(subtitle!).toLowerCase();
      if (normSub.contains(cleanQuery)) return true;
    }

    if (searchKey != null) {
      final normKey = normalizeDigitsToWestern(searchKey!).toLowerCase();
      if (normKey.contains(cleanQuery)) return true;
    }

    for (final kw in keywords) {
      final normKw = normalizeDigitsToWestern(kw).toLowerCase();
      if (normKw.contains(cleanQuery)) return true;
    }

    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSelectOption<T> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          label == other.label;

  @override
  int get hashCode => Object.hash(value, label);

  @override
  String toString() => 'AppSelectOption($value: $label)';
}
