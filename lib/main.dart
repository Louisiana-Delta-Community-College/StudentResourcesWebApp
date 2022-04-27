import 'package:flutter/material.dart';

import 'package:flutter_modular/flutter_modular.dart';

void main() {
  runApp(
    ModularApp(
      module: ModularConfig(),
      child: const MyApp(),
    ),
  );
}

class ModularConfig extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton((i) => Counter()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const Home()),
        ChildRoute('/other', child: (context, args) => const Other()),
      ];
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Modular Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}

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

class Other extends StatelessWidget {
  const Other({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = context.watch<Counter>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Another View"),
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
              '${c.counter}',
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
                Modular.to.pop();
              },
              tooltip: 'Back',
              child: const Icon(Icons.arrow_left),
            ),
          ),
        ],
      ),
    );
  }
}
