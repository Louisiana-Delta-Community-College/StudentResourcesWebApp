import 'package:schedule/common/common.dart';

class SchedulePage extends StatefulWidget {
  final String isStaff;
  const SchedulePage({Key? key, this.isStaff = ""}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  initState() {
    // Pull in schedule data on page initialization.
    // If one were to try to issue this command in the Widget build method,
    // errors would ensue due to trying to rebuild while build is being executed.
    // This is due to Modular's notifyListeners() method which is used to update
    // isLoading status at the beginning of Schedule.getScheduleData()
    Modular.get<Schedule>().getScheduleData();
    Modular.get<ScheduleMenu>().getMenuData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<Schedule>();
    final scheduleMenuProvider = context.watch<ScheduleMenu>();
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              child: scheduleMenuProvider.isLoading
                  ? const CircularProgressIndicator()
                  : scheduleMenuProvider.hasError
                      ? Text(scheduleMenuProvider.errorMessage)
                      : Text(
                          scheduleMenuProvider.data.toString(),
                        ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: scheduleProvider.isLoading
                  ? const CircularProgressIndicator(
                      // color:
                      //     themeProvider.dark.colorScheme.secondary.withOpacity(1),
                      )
                  : scheduleProvider.hasError
                      ? Text(scheduleProvider.errorMessage)
                      : SelectableText(scheduleProvider.data[0].toString()),
            )
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
                  // Modular.to.pushNamed('/other');
                  scheduleProvider.getScheduleData();
                },
                tooltip: 'Refresh',
                child: const Icon(Icons.refresh),
                heroTag: "btnRefresh",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
