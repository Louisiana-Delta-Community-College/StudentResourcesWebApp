import 'package:schedule/common/common.dart';
import 'package:flutter/rendering.dart';

import 'package:responsive_framework/responsive_framework.dart';

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
  RendererBinding.instance.setSemanticsEnabled(true);
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
        WildcardRoute(
          child: (context, args) => const NotFoundPage(),
          transition: TransitionType.fadeIn,
        ),
        ChildRoute(
          '/',
          child: (context, args) => const HomePage(),
        ),
        ChildRoute(
          '/schedule',
          child: (context, args) => const SchedulePage(),
          transition: TransitionType.fadeIn,
        ),
        ChildRoute(
          '/schedule/:isStaff',
          child: (context, args) => SchedulePage(
            isStaff: args.params["isStaff"],
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
      builder: (context, widget) => ResponsiveWrapper.builder(
        ClampingScrollWrapper.builder(context, widget!),
        maxWidth: double.infinity,
        minWidth: 480,
        defaultScale: true,
        breakpoints: [
          const ResponsiveBreakpoint.resize(480, name: MOBILE),
          const ResponsiveBreakpoint.resize(800, name: TABLET),
          const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          const ResponsiveBreakpoint.autoScale(2460, name: '4K'),
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
