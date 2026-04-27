import 'package:shared_preferences/shared_preferences.dart';

class Persistence {
  bool _isDark = false;

  bool get isDark => _isDark;

  set isDark(bool value) {
    _isDark = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDark', value);
    });
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
  }
}
