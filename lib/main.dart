import 'package:schedule/common/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initLog();

  final persistence = Persistence();
  await persistence.init();

  final appTheme = AppTheme();
  appTheme.init(persistence);

  runApp(
    ModularApp(
      module: ModularConfig(
        persistence: persistence,
        appTheme: appTheme,
      ),
      child: const StyledToast(
        child: MyApp(),
      ),
    ),
  );
}

class ModularConfig extends Module {
  final Persistence persistence;
  final AppTheme appTheme;

  ModularConfig({
    required this.persistence,
    required this.appTheme,
  });

  @override
  List<Bind> get binds => [
        Bind.singleton((i) => AppTitle()),
        Bind.singleton((i) => appTheme),
        Bind.singleton((i) => persistence),
        Bind.singleton((i) => Schedule()),
        Bind.singleton((i) => ScheduleTermsMenu()),
        Bind.singleton((i) => ScheduleCampusMenu()),
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppTheme>();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'LDCC',
      routerDelegate: Modular.routerDelegate,
      routeInformationParser: Modular.routeInformationParser,
      theme: Modular.get<AppTheme>().light,
      darkTheme: Modular.get<AppTheme>().dark,
      themeMode: Modular.get<AppTheme>().themeMode,
    );
  }
}
