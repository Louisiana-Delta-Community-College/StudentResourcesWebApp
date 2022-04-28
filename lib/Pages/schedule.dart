import 'package:group_button/group_button.dart';
import 'package:schedule/common/common.dart';
import 'package:schedule/config.dart';

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
        title: const Text("Schedule of Classes"),
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
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 15,
              child: Container(
                  padding: EdgeInsets.all(20),
                  child: scheduleMenuProvider.isLoading
                      ? Center(child: const CircularProgressIndicator())
                      : scheduleMenuProvider.hasError
                          ? Text(scheduleMenuProvider.errorMessage)
                          // : Text(
                          //     scheduleMenuProvider.data.toString(),
                          //   ),
                          : GroupButton(
                              buttons: [
                                for (final item in scheduleMenuProvider.data)
                                  item["Term"].toString(),
                              ],
                              isRadio: true,
                              options: const GroupButtonOptions(
                                unselectedColor: AppColor.navy,
                                unselectedTextStyle: TextStyle(
                                  color: AppColor.white,
                                ),
                                selectedColor: AppColor.bronze,
                              ),
                              onSelected: (selected, __, ___) {
                                if (!scheduleProvider.isLoading) {
                                  scheduleProvider.term = selected.toString();
                                  scheduleProvider.getScheduleData();
                                }
                              },
                            )
                  // isSelected: [
                  //     for (final item in scheduleMenuProvider.data) true
                  //   ])
                  ),
            ),
            Expanded(
              flex: 85,
              child: Container(
                // color: Colors.green,
                padding: EdgeInsets.all(20),
                child: scheduleProvider.isLoading
                    ? Center(
                        child: const CircularProgressIndicator(
                            // color:
                            //     themeProvider.dark.colorScheme.secondary.withOpacity(1),
                            ),
                      )
                    : scheduleProvider.hasError
                        ? Text(scheduleProvider.errorMessage)
                        : SelectableText(scheduleProvider.data[0].toString()),
              ),
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
