import 'package:schedule/common/common.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Icon get icon => _themeMode == ThemeMode.dark
      ? const Icon(Icons.light_mode_sharp)
      : const Icon(Icons.dark_mode_sharp);

  Color get text =>
      _themeMode == ThemeMode.dark ? AppColor.white : AppColor.primary;
  Color get background =>
      _themeMode == ThemeMode.dark ? AppColor.primary : AppColor.darkSilver;
  Color get surface =>
      _themeMode == ThemeMode.dark ? AppColor.darkSilver : AppColor.primary;
  Color get onSurface =>
      _themeMode == ThemeMode.dark ? AppColor.primary : AppColor.white;

  Color get rowColorNormal =>
      _themeMode == ThemeMode.dark ? Colors.transparent : Colors.white54;
  Color get rowColorHighlighted => _themeMode == ThemeMode.dark
      ? AppColor.secondary.withOpacity(.40)
      : AppColor.secondary.withOpacity(.30);
  Color get rowColorHover => _themeMode == ThemeMode.dark
      ? AppColor.secondary.withOpacity(.60)
      : AppColor.secondary.withOpacity(.50);

  Color get menuColor => AppColor.primary;
  // Color get menuColorSelected => AppColor.darkSilver.withOpacity(.9);
  Color get menuColorSelected => AppColor.secondary.withOpacity(.95);

  Color get mobileCardBorderColor => _themeMode == ThemeMode.dark
      ? AppColor.secondary.withAlpha(200)
      : AppColor.primary;
  Color get mobileCardBorderTextColor =>
      mobileCardBorderColor.computeLuminance() >= .5
          ? AppColor.navy
          : AppColor.white;

  Color get floatingActionButtonBackgroundColor =>
      _themeMode == ThemeMode.dark ? Colors.white : AppColor.primary;
  Color get floatingActionButtonForegroundColor =>
      _themeMode == ThemeMode.dark ? AppColor.primary : Colors.white;

  init() {
    Modular.get<Persistence>().isDark
        ? _themeMode = ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  toggle() {
    _themeMode == ThemeMode.dark
        ? _themeMode = ThemeMode.light
        : _themeMode = ThemeMode.dark;
    Modular.get<Persistence>().isDark =
        _themeMode == ThemeMode.dark ? true : false;
    notifyListeners();
  }

  ThemeData light = ThemeData.light().copyWith(
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
      thumbColor: MaterialStateProperty.all(AppColor.primary.withOpacity(.75)),
      radius: const Radius.circular(10),
      crossAxisMargin: 0,
      minThumbLength: 50,
    ),
    // textTheme: const TextTheme(
    //         bodyText1: TextStyle(),
    //         bodyText2: TextStyle(),
    //         headline4: TextStyle())
    //     .apply(
    //   bodyColor: AppColor.navy,
    //   displayColor: AppColor.navy,
    // ),
    // textTheme: const TextTheme(
    //   bodyText1: TextStyle(
    //     fontSize: 20,
    //     color: Colors.black,
    //   ),
    //   bodyText2: TextStyle(
    //     fontSize: 18,
    //     color: Colors.black,
    //   ),
    //   button: TextStyle(
    //     fontSize: 20,
    //     color: Colors.black,
    //   ),
    //   headline4: TextStyle(
    //     color: Colors.black,
    //   ),
    // ),
  );

  ThemeData dark = ThemeData.dark().copyWith(
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
      thumbColor: MaterialStateProperty.all(AppColor.white.withOpacity(.5)),
      radius: const Radius.circular(10),
      crossAxisMargin: 0,
      minThumbLength: 50,
    ),
    // textTheme: const TextTheme(
    //         bodyText1: TextStyle(),
    //         bodyText2: TextStyle(),
    //         headline4: TextStyle())
    //     .apply(
    //   bodyColor: AppColor.navy,
    //   displayColor: AppColor.navy,
    // ),
    // textTheme: const TextTheme(
    //   bodyText1: TextStyle(
    //     fontSize: 20,
    //     color: Colors.white,
    //   ),
    //   bodyText2: TextStyle(
    //     fontSize: 18,
    //     color: Colors.white,
    //   ),
    //   button: TextStyle(
    //     fontSize: 20,
    //     color: Colors.white,
    //   ),
    // ),
  );
}
