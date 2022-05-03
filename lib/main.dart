import 'package:schedule/common/common.dart';

import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  await GetStorage.init();
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
        Bind.singleton((i) => AppTheme()),
        Bind.singleton((i) => Persistence()),
        Bind.singleton((i) => Schedule()),
        Bind.singleton((i) => ScheduleTermsMenu()),
        Bind.singleton((i) => ScheduleCampusMenu()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => const SchedulePage(),
            transition: TransitionType.fadeIn),
        ChildRoute('/:isStaff',
            child: (context, args) => SchedulePage(
                  isStaff: args.params["isStaff"],
                ),
            transition: TransitionType.fadeIn),
        ChildRoute('/other',
            child: (context, args) => const Other(),
            transition: TransitionType.fadeIn),
      ];
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Modular.get<Persistence>().init();
    Modular.get<AppTheme>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppTheme>();
    return MaterialApp.router(
      title: 'LDCC',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: themeProvider.light,
      darkTheme: themeProvider.dark,
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      builder: (context, widget) => ResponsiveWrapper.builder(
        ClampingScrollWrapper.builder(context, widget!),
        maxWidth: double.infinity,
        minWidth: 480,
        defaultScale: true,
        breakpoints: [
          const ResponsiveBreakpoint.resize(480, name: MOBILE),
          const ResponsiveBreakpoint.resize(800, name: TABLET),
          const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          const ResponsiveBreakpoint.resize(2460, name: '4K'),
        ],
      ),
    );
    // OR WITHOUT RESPONSIVE WRAPPER
    // return MaterialApp.router(
    //   title: 'Flutter Modular Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   routeInformationParser: Modular.routeInformationParser,
    //   routerDelegate: Modular.routerDelegate,
    // );
  }
}
