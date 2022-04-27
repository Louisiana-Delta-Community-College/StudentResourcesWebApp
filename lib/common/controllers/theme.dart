import 'package:fmtest/common/common.dart';

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
      primary: Colors.orange,
      onPrimary: Colors.black,
      secondary: Colors.orange,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.black,
      background: Colors.black,
      onBackground: Colors.black,
      surface: Colors.orange,
      onSurface: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      bodyText2: TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
      button: TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      headline4: TextStyle(
        color: Colors.black,
      ),
    ),
  );

  ThemeData dark = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.orange,
      onPrimary: Colors.black,
      secondary: Colors.orange,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.black,
      background: Colors.black,
      onBackground: Colors.white,
      surface: Colors.orange,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      bodyText2: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
      button: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
    ),
  );
}
