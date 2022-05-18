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
  Color get rowColorHighlighted => isDark ? secondary40 : secondary30;
  Color get rowColorHover => isDark ? secondary60 : secondary50;

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
      thumbColor: MaterialStateProperty.all(primary70),
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
      thumbColor: MaterialStateProperty.all(tertiary50),
      radius: const Radius.circular(10),
      crossAxisMargin: 0,
      minThumbLength: 50,
    ),
  );

  static final primary90 = AppColor.primary.withOpacity(.9);
  static final primary80 = AppColor.primary.withOpacity(.8);
  static final primary70 = AppColor.primary.withOpacity(.7);
  static final primary60 = AppColor.primary.withOpacity(.6);
  static final primary50 = AppColor.primary.withOpacity(.5);
  static final primary40 = AppColor.primary.withOpacity(.4);
  static final primary30 = AppColor.primary.withOpacity(.3);
  static final primary20 = AppColor.primary.withOpacity(.2);
  static final primary10 = AppColor.primary.withOpacity(.1);

  static final secondary90 = AppColor.secondary.withOpacity(.9);
  static final secondary80 = AppColor.secondary.withOpacity(.8);
  static final secondary70 = AppColor.secondary.withOpacity(.7);
  static final secondary60 = AppColor.secondary.withOpacity(.6);
  static final secondary50 = AppColor.secondary.withOpacity(.5);
  static final secondary40 = AppColor.secondary.withOpacity(.4);
  static final secondary30 = AppColor.secondary.withOpacity(.3);
  static final secondary20 = AppColor.secondary.withOpacity(.2);
  static final secondary10 = AppColor.secondary.withOpacity(.1);

  static final tertiary90 = AppColor.tertiary.withOpacity(.9);
  static final tertiary80 = AppColor.tertiary.withOpacity(.8);
  static final tertiary70 = AppColor.tertiary.withOpacity(.7);
  static final tertiary60 = AppColor.tertiary.withOpacity(.6);
  static final tertiary50 = AppColor.tertiary.withOpacity(.5);
  static final tertiary40 = AppColor.tertiary.withOpacity(.4);
  static final tertiary30 = AppColor.tertiary.withOpacity(.3);
  static final tertiary20 = AppColor.tertiary.withOpacity(.2);
  static final tertiary10 = AppColor.tertiary.withOpacity(.1);

  static final quaternary90 = AppColor.quaternary.withOpacity(.9);
  static final quaternary80 = AppColor.quaternary.withOpacity(.8);
  static final quaternary70 = AppColor.quaternary.withOpacity(.7);
  static final quaternary60 = AppColor.quaternary.withOpacity(.6);
  static final quaternary50 = AppColor.quaternary.withOpacity(.5);
  static final quaternary40 = AppColor.quaternary.withOpacity(.4);
  static final quaternary30 = AppColor.quaternary.withOpacity(.3);
  static final quaternary20 = AppColor.quaternary.withOpacity(.2);
  static final quaternary10 = AppColor.quaternary.withOpacity(.1);
}
