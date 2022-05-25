import 'package:schedule/common/common.dart';

class Persistence extends ChangeNotifier {
  final GetStorage _box = GetStorage();
  bool _isDark = false;

  init() {
    _isDark = _box.read("isDark") ?? false;
    notifyListeners();
  }

  bool get isDark => _isDark;

  set isDark(bool val) {
    if (val != _isDark) {
      _isDark = val;
      // persist the change
      _box.write("isDark", val);
      notifyListeners();
    }
  }
}
