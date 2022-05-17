import 'package:schedule/common/common.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Icon get icon => _themeMode == ThemeMode.dark
      ? const Icon(Icons.light_mode_sharp)
      : const Icon(Icons.dark_mode_sharp);

  Color get text =>
      _themeMode == ThemeMode.dark ? AppColor.white : AppColor.navy;
  Color get background =>
      _themeMode == ThemeMode.dark ? AppColor.navy : AppColor.bronze3;
  Color get surface =>
      _themeMode == ThemeMode.dark ? AppColor.bronze3 : AppColor.navy;
  Color get onSurface =>
      _themeMode == ThemeMode.dark ? AppColor.navy : AppColor.white;

  Color get rowColorNormal =>
      _themeMode == ThemeMode.dark ? Colors.transparent : Colors.white54;
  Color get rowColorHighlighted => _themeMode == ThemeMode.dark
      ? AppColor.bronze3.withOpacity(.30)
      : AppColor.bronze3.withOpacity(.15);
  Color get rowColorHover => _themeMode == ThemeMode.dark
      ? AppColor.bronze3.withOpacity(.50)
      : AppColor.bronze3.withOpacity(.30);

  Color get floatingActionButtonBackgroundColor =>
      _themeMode == ThemeMode.dark ? Colors.white : AppColor.navy;
  Color get floatingActionButtonForegroundColor =>
      _themeMode == ThemeMode.dark ? AppColor.navy : Colors.white;

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
      primary: AppColor.navy,
      onPrimary: AppColor.white,
      secondary: AppColor.bronze3,
      onSecondary: AppColor.white,
      error: Colors.red,
      onError: Colors.black,
      background: AppColor.white,
      onBackground: AppColor.navy,
      surface: AppColor.bronze3,
      onSurface: Colors.white,
      tertiary: AppColor.navy,
      onTertiary: AppColor.white,
    ),
    primaryTextTheme: Typography().black,
    scrollbarTheme: ScrollbarThemeData(
      isAlwaysShown: true,
      thickness: MaterialStateProperty.all(7),
      thumbColor: MaterialStateProperty.all(AppColor.navy.withOpacity(.75)),
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
        primary: AppColor.bronze3,
        onPrimary: AppColor.white,
        secondary: AppColor.bronze3,
        onSecondary: AppColor.white,
        error: Colors.red,
        onError: Colors.black,
        background: AppColor.navy,
        onBackground: AppColor.white,
        surface: AppColor.navy,
        onSurface: Colors.white,
        tertiary: AppColor.white,
        onTertiary: AppColor.navy),
    primaryColor: AppColor.bronze3,
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: AppColor.bronze3,
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
