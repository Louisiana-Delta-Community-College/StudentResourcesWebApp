import 'package:schedule/common/common.dart';
import 'package:schedule/config.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Icon get icon => _themeMode == ThemeMode.dark
      ? const Icon(Icons.light_mode_sharp)
      : const Icon(Icons.dark_mode_sharp);

  toggle() {
    _themeMode == ThemeMode.dark
        ? _themeMode = ThemeMode.light
        : _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  ThemeData light = ThemeData.light().copyWith(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColor.navy,
      onPrimary: AppColor.white,
      secondary: AppColor.bronze2,
      onSecondary: AppColor.white,
      error: Colors.red,
      onError: Colors.black,
      background: AppColor.white,
      onBackground: AppColor.navy,
      surface: AppColor.bronze2,
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
        primary: AppColor.bronze2,
        onPrimary: AppColor.white,
        secondary: AppColor.bronze2,
        onSecondary: AppColor.white,
        error: Colors.red,
        onError: Colors.black,
        background: AppColor.navy,
        onBackground: AppColor.white,
        surface: AppColor.navy,
        onSurface: Colors.white,
        tertiary: AppColor.white,
        onTertiary: AppColor.navy),
    primaryColor: AppColor.bronze2,
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: AppColor.bronze2,
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
