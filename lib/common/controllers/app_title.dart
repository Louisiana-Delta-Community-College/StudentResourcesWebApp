import 'package:schedule/common/common.dart';

class AppTitle extends ChangeNotifier {
  String _titleBase = "LDCC";
  String _title = "LDCC";

  String get title => _title;

  set title(String s) {
    _title = "$_titleBase - $s";
    notifyListeners();
  }
}
