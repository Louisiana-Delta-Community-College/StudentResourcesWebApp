import 'package:fmtest/common/common.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final c = Modular.get<Counter>();
    final c = context.watch<Counter>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Counter Value:',
            ),
            Text(
              "${c.counter}",
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            child: FloatingActionButton(
              onPressed: () {
                c.increment();
              },
              tooltip: 'Increment',
              child: const Icon(Icons.arrow_upward_sharp),
              heroTag: "btnIncrement",
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: FloatingActionButton(
              onPressed: () {
                c.decrement();
              },
              tooltip: 'Decrement',
              child: const Icon(Icons.arrow_downward_sharp),
              heroTag: "btnDecrement",
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: FloatingActionButton(
              onPressed: () {
                Modular.to.pushNamed('/other');
              },
              tooltip: 'Go to Other Page',
              child: const Icon(Icons.arrow_right),
              heroTag: "btnGoToOtherPage",
            ),
          ),
        ],
      ),
    );
  }
}
