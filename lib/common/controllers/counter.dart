import '../common.dart';

class Counter extends ChangeNotifier {
  int _counter = 0;
  get counter => _counter;

  increment() {
    _counter++;
    notifyListeners();
  }

  decrement() {
    _counter--;
    notifyListeners();
  }
}
