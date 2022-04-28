import 'package:schedule/common/common.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final c = Modular.get<Counter>();
    final counterProvider = context.watch<Counter>();
    final themeProvider = context.watch<AppTheme>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          FadeInDown(
            preferences: const AnimationPreferences(
              autoPlay: AnimationPlayStates.Forward,
              duration: Duration(
                milliseconds: 500,
              ),
            ),
            child: IconButton(
                onPressed: () {
                  themeProvider.toggle();
                },
                icon: themeProvider.icon),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Counter Value:',
            ),
            FadeInUp(
              preferences: const AnimationPreferences(
                duration: Duration(
                  milliseconds: 500,
                ),
              ),
              child: Text(
                "${counterProvider.counter}",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FadeInRight(
        preferences: const AnimationPreferences(
          duration: Duration(
            milliseconds: 500,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              child: FloatingActionButton(
                onPressed: () {
                  counterProvider.increment();
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
                  counterProvider.decrement();
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
                  // Modular.to.pushNamed('/other');
                  Modular.to.navigate("/other");
                },
                tooltip: 'Go to Other Page',
                child: const Icon(Icons.arrow_right),
                heroTag: "btnGoToOtherPage",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
