import 'package:schedule/common/common.dart';
// import 'package:flutter/rendering.dart';

void main() async {
  initLog();
  await GetStorage.init();
  runApp(
    ModularApp(
      module: ModularConfig(),
      child: StyledToast(
        locale: const Locale("en", "US"),
        child: const MyApp(),
      ),
    ),
  );
  // RendererBinding.instance.setSemanticsEnabled(true);
}

class ModularConfig extends Module {
  @override
  List<Bind> get binds => [
        // APP-WIDE BINDS
        Bind.singleton((i) => AppTitle()),
        Bind.singleton((i) => AppTheme()),
        Bind.singleton((i) => Persistence()),
        // SCHEDULE BINDS
        Bind.singleton((i) => Schedule()),
        Bind.singleton((i) => ScheduleTermsMenu()),
        Bind.singleton((i) => ScheduleCampusMenu()),
        // DIRECTORY BINDS
        Bind.singleton((i) => Directory()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (context, args) => const HomePage(),
        ),
        ChildRoute(
          '/schedule/',
          child: (context, args) => const SchedulePage(),
          transition: TransitionType.fadeIn,
        ),
        ChildRoute(
          '/schedule',
          child: (context, args) => const SchedulePage(),
          transition: TransitionType.fadeIn,
        ),
        ChildRoute(
          '/schedule/:season/:year',
          child: (context, args) => SchedulePage(
            season: args.params["season"],
            year: args.params["year"],
          ),
          transition: TransitionType.fadeIn,
        ),
        ChildRoute(
          '/schedule/:season/:year/:current',
          child: (context, args) => SchedulePage(
            season: args.params["season"],
            year: args.params["year"],
            current: args.params["current"],
          ),
          transition: TransitionType.fadeIn,
        ),
        ChildRoute(
          '/directory',
          child: (context, args) => const DirectoryPage(),
          transition: TransitionType.fadeIn,
        ),
        ChildRoute(
          '/directory/:campus',
          child: (context, args) => DirectoryPage(
            selectedCampus: args.params["campus"],
          ),
          transition: TransitionType.fadeIn,
        ),
        // ChildRoute('/other',
        //     child: (context, args) => const Other(),
        //     transition: TransitionType.fadeIn),
        WildcardRoute(
          child: (context, args) => const NotFoundPage(),
          transition: TransitionType.fadeIn,
        ),
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
    setState(() {
      globalContext = context;
    });
    final themeProvider = context.watch<AppTheme>();
    final titleProvider = context.watch<AppTitle>();
    return MaterialApp.router(
      title: titleProvider.title,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: themeProvider.light,
      darkTheme: themeProvider.dark,
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: ClampingScrollWrapper.builder(context, widget!),
        // maxWidth: double.infinity,
        // minWidth: 480,
        // defaultScale: true,
        breakpoints: [
          const Breakpoint(start: 0, end: 480, name: MOBILE),
          const Breakpoint(start: 481, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
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
