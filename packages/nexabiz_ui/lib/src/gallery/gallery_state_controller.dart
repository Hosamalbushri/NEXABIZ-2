import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../nexabiz_ui.dart';

/// Categories for component filtering in the gallery.
enum GalleryCategory {
  all('All Components', AppIcons.grid),
  layout('Layout & Structure', AppIcons.box),
  forms('Forms & Inputs', AppIcons.edit),
  actions('Actions & Menus', AppIcons.command),
  feedback('Feedback & Status', AppIcons.check),
  navigation('Navigation & Tabs', AppIcons.compass),
  dataDisplay('Data Display', AppIcons.table),
  overlays('Overlays & Sheets', AppIcons.layers),
  dateTime('Date & Time', AppIcons.calendar),
  other('Other Components', AppIcons.settings);

  final String label;
  final IconData icon;

  const GalleryCategory(this.label, this.icon);
}

/// Simulated viewport dimensions for responsive playground preview.
enum GalleryViewportSize {
  auto('Auto (Real Window)', 0),
  compact('Compact (Mobile 375px)', 375),
  medium('Medium (Tablet 768px)', 768),
  expanded('Expanded (Desktop 1024px)', 1024),
  wide('Wide (Large Desktop 1440px)', 1440);

  final String label;
  final double width;

  const GalleryViewportSize(this.label, this.width);
}

/// State controller for the Component Gallery & Playground.
class GalleryStateController extends ChangeNotifier {
  String _searchQuery = '';
  GalleryCategory _selectedCategory = GalleryCategory.all;
  GalleryViewportSize _viewportSize = GalleryViewportSize.auto;
  TextDirection _directionality = TextDirection.rtl;
  shadcn.ThemeMode _themeMode = shadcn.ThemeMode.system;

  String get searchQuery => _searchQuery;
  GalleryCategory get selectedCategory => _selectedCategory;
  GalleryViewportSize get viewportSize => _viewportSize;
  TextDirection get directionality => _directionality;
  shadcn.ThemeMode get themeMode => _themeMode;

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void setCategory(GalleryCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setViewportSize(GalleryViewportSize size) {
    _viewportSize = size;
    notifyListeners();
  }

  void toggleDirectionality() {
    _directionality = _directionality == TextDirection.rtl
        ? TextDirection.ltr
        : TextDirection.rtl;
    notifyListeners();
  }

  void setThemeMode(shadcn.ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  bool isComponentMatching(String name, String description, GalleryCategory category) {
    if (_selectedCategory != GalleryCategory.all && _selectedCategory != category) {
      return false;
    }
    if (_searchQuery.isEmpty) return true;
    final term = _searchQuery.toLowerCase();
    return name.toLowerCase().contains(term) ||
        description.toLowerCase().contains(term) ||
        category.label.toLowerCase().contains(term);
  }
}
