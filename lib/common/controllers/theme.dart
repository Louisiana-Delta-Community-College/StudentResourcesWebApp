import 'package:schedule/common/common.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  Icon get icon => isDark
      ? const Icon(Icons.light_mode_sharp)
      : const Icon(Icons.dark_mode_sharp);

  Color get text => isDark ? AppColor.white : AppColor.primary;
  Color get background => isDark ? AppColor.primary : AppColor.darkSilver;
  Color get surface => isDark ? AppColor.darkSilver : AppColor.primary;
  Color get onSurface => isDark ? AppColor.primary : AppColor.white;

  Color get rowColorNormal => isDark ? Colors.transparent : Colors.white54;
  Color get rowColorHighlighted =>
      isDark ? AppColor.darkSilver40 : AppColor.darkSilver30;
  Color get rowColorHover =>
      isDark ? AppColor.darkSilver60 : AppColor.darkSilver50;

  Color get menuColor => AppColor.primary;
  // Color get menuColorSelected => AppColor.darkSilver90;
  Color get menuColorSelected => AppColor.secondary;
  Color get menuColorBorder => isDark ? AppColor.secondary : AppColor.primary;

  Color get mobileCardBorderColor =>
      isDark ? AppColor.secondary : AppColor.primary;
  Color get mobileCardBorderTextColor =>
      isDark ? AppColor.navy : AppColor.white;

  Color get floatingActionButtonBackgroundColor =>
      isDark ? Colors.white : AppColor.primary;
  Color get floatingActionButtonForegroundColor =>
      isDark ? AppColor.primary : Colors.white;

  init() {
    Modular.get<Persistence>().isDark
        ? _themeMode = ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  toggle() {
    isDark ? _themeMode = ThemeMode.light : _themeMode = ThemeMode.dark;
    Modular.get<Persistence>().isDark = isDark ? true : false;
    notifyListeners();
  }

  ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: "OpenSans",
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColor.primary,
      onPrimary: AppColor.white,
      secondary: AppColor.secondary,
      onSecondary: AppColor.primary,
      error: Colors.red,
      onError: Colors.black,
      background: AppColor.white,
      onBackground: AppColor.primary,
      surface: AppColor.secondary,
      onSurface: AppColor.primary,
      tertiary: AppColor.primary,
      onTertiary: AppColor.white,
    ),
    primaryTextTheme: Typography().black,
    scrollbarTheme: ScrollbarThemeData(
      isAlwaysShown: true,
      thickness: MaterialStateProperty.all(7),
      thumbColor: MaterialStateProperty.all(AppColor.navy70),
      radius: const Radius.circular(10),
      crossAxisMargin: 0,
      minThumbLength: 50,
    ),
  );

  ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "OpenSans",
    colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColor.secondary,
        onPrimary: AppColor.primary,
        secondary: AppColor.secondary,
        onSecondary: AppColor.primary,
        error: Colors.red,
        onError: Colors.black,
        background: AppColor.primary,
        onBackground: AppColor.white,
        surface: AppColor.primary,
        onSurface: Colors.white,
        tertiary: AppColor.white,
        onTertiary: AppColor.primary),
    primaryColor: AppColor.secondary,
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: AppColor.secondary,
    ),
    primaryTextTheme: Typography().white,
    scrollbarTheme: ScrollbarThemeData(
      isAlwaysShown: true,
      thickness: MaterialStateProperty.all(7),
      thumbColor: MaterialStateProperty.all(AppColor.white50),
      radius: const Radius.circular(10),
      crossAxisMargin: 0,
      minThumbLength: 50,
    ),
  );
}
