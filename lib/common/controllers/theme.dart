import 'package:schedule/common/common.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Persistence? _persistence;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  Icon get icon => isDark
      ? const Icon(Icons.light_mode_sharp)
      : const Icon(Icons.dark_mode_sharp);

  Color get text => isDark ? AppColor.white : Colors.black;
  Color get background => isDark ? AppColor.primary : AppColor.darkSilver;
  Color get bodyBackground => isDark ? AppColor.darkGray : AppColor.white;
  Color get surface => isDark ? AppColor.darkSilver : AppColor.primary;
  Color get onSurface => isDark ? AppColor.primary : AppColor.white;

  Color get rowColorNormal => isDark ? Colors.transparent : Colors.white54;
  Color get rowColorHighlighted => isDark ? secondary30 : secondary40;
  Color get rowColorHover => isDark ? secondary50 : secondary60;
  Color get daviText => isDark ? AppColor.white : Colors.black;

  Color get menuColor => AppColor.primary;
  Color get menuColorSelected => AppColor.secondary;
  Color get menuColorBorder => isDark ? AppColor.secondary : AppColor.primary;

  Color get mobileCardBorderColor =>
      isDark ? AppColor.primary : AppColor.primary;
  Color get mobileCardBorderTextColor =>
      isDark ? AppColor.white : AppColor.white;
  Color get mobileCardTextColor => isDark ? AppColor.white : AppColor.primary;

  Color get floatingActionButtonBackgroundColor =>
      isDark ? Colors.white : AppColor.primary;
  Color get floatingActionButtonForegroundColor =>
      isDark ? AppColor.primary : Colors.white;

  double _logicalWidth = 1024;
  double _scale = 1.0;
  String _formFactor = "L";
  String _viewportBucket = "desktop";

  double get logicalWidth => _logicalWidth;
  double get scale => _scale;
  String get formFactor => _formFactor;
  String get viewportBucket => _viewportBucket;

  void updateLayoutMetrics(double width) {
    final normalizedWidth = width <= 0 ? 1024.0 : width;
    final nextBucket = _bucketForWidth(normalizedWidth);
    final nextScale = _scaleForWidth(normalizedWidth);
    final nextFormFactor = _formFactorForScale(nextScale);

    if (_logicalWidth == normalizedWidth &&
        _viewportBucket == nextBucket &&
        _scale == nextScale &&
        _formFactor == nextFormFactor) {
      return;
    }

    _logicalWidth = normalizedWidth;
    _viewportBucket = nextBucket;
    _scale = nextScale;
    _formFactor = nextFormFactor;
    notifyListeners();
  }

  String _bucketForWidth(double width) {
    if (width < 600) return "mobile";
    if (width < 900) return "tablet";
    if (width < 1440) return "desktop";
    return "wide";
  }

  double _scaleForWidth(double width) {
    if (width < 600) {
      return 0.85;
    } else if (width < 1024) {
      return 0.85 + (width - 600) * (0.15 / 424);
    } else if (width < 1440) {
      return 1.0 + (width - 1024) * (0.05 / 416);
    } else {
      return (1.05 + (width - 1440) * (0.05 / 480)).clamp(1.05, 1.1);
    }
  }

  String _formFactorForScale(double currentScale) {
    if (currentScale < 0.9) return "S";
    if (currentScale < 1.0) return "M";
    if (currentScale < 1.05) return "L";
    return "XL";
  }

  double _clampFont(double size, double min) {
    return size < min ? min : size;
  }

  double get _fontSizeDelta {
    final baseDelta = (scale - 1.0) * 18;
    if (formFactor == "XL") return baseDelta + 1.0;
    return baseDelta;
  }

  double get daviRowHeight {
    final base = 25.0 * scale;
    if (formFactor == "S") return base - 4;
    if (formFactor == "XL") return base + 2;
    return base;
  }

  double get daviFontSize => fontSizeXS < 12 ? 12 : fontSizeXS;
  double get daviHeaderFontSize => fontSizeS < 13 ? 13 : fontSizeS;

  double get fontSizeXXS => _clampFont(13 + _fontSizeDelta, 10);
  double get fontSizeXS => _clampFont(13 + _fontSizeDelta, 11);
  double get fontSizeS => _clampFont(14 + _fontSizeDelta, 12);
  double get fontSizeM => _clampFont(20 + _fontSizeDelta, 16);
  double get fontSizeL => _clampFont(40 + _fontSizeDelta, 28);
  double get fontSizeXL => _clampFont(48 + _fontSizeDelta, 34);
  double get fontSizeXXL => _clampFont(80 + _fontSizeDelta, 56);

  void init([Persistence? persistence]) {
    _persistence = persistence ?? _persistence;

    if (_persistence != null) {
      _themeMode = _persistence!.isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _themeMode =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }

    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _persistence?.isDark = mode == ThemeMode.dark;
    notifyListeners();
  }

  void toggle() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _persistence?.isDark = _themeMode == ThemeMode.dark;
    notifyListeners();
  }

  ThemeData light = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: AppColor.primary,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColor.primary,
      onPrimary: AppColor.white,
      secondary: AppColor.secondary,
      onSecondary: AppColor.white,
      error: Colors.red,
      onError: Colors.white,
      surface: AppColor.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: AppColor.white,
  );

  ThemeData dark = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: AppColor.primary,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColor.primary,
      onPrimary: AppColor.white,
      secondary: AppColor.secondary,
      onSecondary: AppColor.white,
      error: Colors.red,
      onError: Colors.white,
      surface: AppColor.darkGray,
      onSurface: AppColor.white,
    ),
    scaffoldBackgroundColor: AppColor.darkGray,
  );

  static const primary = AppColor.primary;
  static final primary90 = primary.withValues(alpha: .9);
  static final primary80 = primary.withValues(alpha: .8);
  static final primary70 = primary.withValues(alpha: .7);
  static final primary60 = primary.withValues(alpha: .6);
  static final primary50 = primary.withValues(alpha: .5);
  static final primary40 = primary.withValues(alpha: .4);
  static final primary30 = primary.withValues(alpha: .3);
  static final primary20 = primary.withValues(alpha: .2);
  static final primary10 = primary.withValues(alpha: .1);

  static const secondary = AppColor.secondary;
  static final secondary90 = secondary.withValues(alpha: .9);
  static final secondary80 = secondary.withValues(alpha: .8);
  static final secondary70 = secondary.withValues(alpha: .7);
  static final secondary60 = secondary.withValues(alpha: .6);
  static final secondary50 = secondary.withValues(alpha: .5);
  static final secondary40 = secondary.withValues(alpha: .4);
  static final secondary30 = secondary.withValues(alpha: .3);
  static final secondary20 = secondary.withValues(alpha: .2);
  static final secondary10 = secondary.withValues(alpha: .1);

  static const tertiary = AppColor.tertiary;
  static final tertiary90 = tertiary.withValues(alpha: .9);
  static final tertiary80 = tertiary.withValues(alpha: .8);
  static final tertiary70 = tertiary.withValues(alpha: .7);
  static final tertiary60 = tertiary.withValues(alpha: .6);
  static final tertiary50 = tertiary.withValues(alpha: .5);
  static final tertiary40 = tertiary.withValues(alpha: .4);
  static final tertiary30 = tertiary.withValues(alpha: .3);
  static final tertiary20 = tertiary.withValues(alpha: .2);
  static final tertiary10 = tertiary.withValues(alpha: .1);

  static const quaternary = AppColor.quaternary;
  static final quaternary90 = quaternary.withValues(alpha: .9);
  static final quaternary80 = quaternary.withValues(alpha: .8);
  static final quaternary70 = quaternary.withValues(alpha: .7);
  static final quaternary60 = quaternary.withValues(alpha: .6);
  static final quaternary50 = quaternary.withValues(alpha: .5);
  static final quaternary40 = quaternary.withValues(alpha: .4);
  static final quaternary30 = quaternary.withValues(alpha: .3);
  static final quaternary20 = quaternary.withValues(alpha: .2);
  static final quaternary10 = quaternary.withValues(alpha: .1);
}
