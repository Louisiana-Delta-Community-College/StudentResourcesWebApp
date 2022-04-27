import './common/common.dart';

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