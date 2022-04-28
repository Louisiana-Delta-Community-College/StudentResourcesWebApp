import 'package:schedule/common/common.dart';

class Other extends StatelessWidget {
  const Other({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counterProvider = context.watch<Counter>();
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
                  // Modular.to.pop();
                  Modular.to.navigate('/');
                },
                tooltip: 'Back',
                child: const Icon(Icons.arrow_left),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
