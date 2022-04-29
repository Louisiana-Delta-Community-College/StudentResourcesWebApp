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
    Modular.get<ScheduleTermsMenu>().getMenuData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<Schedule>();
    final scheduleTermsMenuProvider = context.watch<ScheduleTermsMenu>();
    final themeProvider = context.watch<AppTheme>();
    // final myTableController = context.watch<MyTableController>();

    final _groupButtonTermMenuController =
        scheduleTermsMenuProvider.groupButtonTermMenuController;

    double _tableFontSize = 10;

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
              flex: 20,
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: scheduleTermsMenuProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : scheduleTermsMenuProvider.hasError
                          ? Text(scheduleTermsMenuProvider.errorMessage)
                          : GroupButton(
                              controller: _groupButtonTermMenuController,
                              buttons: scheduleTermsMenuProvider.termsList,
                              isRadio: true,
                              onSelected: (selected, index, ___) {
                                if (!scheduleProvider.isLoading) {
                                  scheduleProvider.term = selected.toString();
                                  scheduleProvider.getScheduleData();
                                }
                              },
                              options: const GroupButtonOptions(
                                  unselectedColor: AppColor.navy,
                                  unselectedTextStyle: TextStyle(
                                    color: AppColor.white,
                                  ),
                                  selectedColor: AppColor.bronze2,
                                  runSpacing: 0,
                                  spacing: 0,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              buttonIndexedBuilder:
                                  (isSelected, index, context) {
                                return Container(
                                  margin: const EdgeInsets.all(0),
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColor.bronze2
                                          : AppColor.navy,
                                      border: Border.all(
                                          color: AppColor.bronze2, width: 2),
                                      borderRadius: index == 0
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10))
                                          : scheduleTermsMenuProvider
                                                      .termsList[index] ==
                                                  scheduleTermsMenuProvider
                                                      .termsList.last
                                              ? const BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10))
                                              : null),
                                  child: Text(
                                    scheduleTermsMenuProvider.data[index]
                                            ["Desc"]
                                        .toString(),
                                    style: const TextStyle(
                                        color: AppColor.white, fontSize: 12),
                                  ),
                                );
                              },
                            )
                  // isSelected: [
                  //     for (final item in scheduleMenuProvider.data) true
                  //   ])
                  ),
            ),
            Expanded(
              flex: 80,
              child: Container(
                  // color: Colors.green,
                  padding: const EdgeInsets.all(20),
                  child: scheduleProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              // color:
                              //     themeProvider.dark.colorScheme.secondary.withOpacity(1),
                              ),
                        )
                      : scheduleProvider.hasError
                          ? Text(scheduleProvider.errorMessage)
                          // : SelectableText(scheduleProvider.data[0].toString()),
                          : ListView.builder(
                              itemCount: scheduleProvider.data.length,
                              itemBuilder: (context, index) {
                                final course = scheduleProvider.data[index];
                                return ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          course["CRN"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["CN"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["TD"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      // Text(course[""].toString(), style: TextStyle(fontSize: _tableFontSize),),
                                      Expanded(
                                        child: Text(
                                          course["D"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["TB"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["TE"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["B"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["R"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["TN"]
                                              .toString()
                                              .replaceAll("<br/>", "\n"),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["E"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["PTRMDS"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["PTRMDE"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["INSMC"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course["AF"].toString(),
                                          style: TextStyle(
                                              fontSize: _tableFontSize),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )),
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
                mini: true,
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
