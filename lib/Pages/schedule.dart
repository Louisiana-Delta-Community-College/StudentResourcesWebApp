import 'package:group_button/group_button.dart';
import 'package:schedule/common/common.dart';
import 'package:schedule/config.dart';

import 'package:easy_table/easy_table.dart';

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

    final _doFitTableColumns = MediaQuery.of(context).size.width >= 1750;

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
                        : EasyTable(
                            EasyTableModel(
                              rows: scheduleProvider.data,
                              columns: [
                                EasyTableColumn(
                                    name: "",
                                    cellBuilder: (context, row) => IconButton(
                                        icon: Icon(Icons.ac_unit),
                                        onPressed: () {
                                          // print("$row pressed");
                                        })),
                                EasyTableColumn(
                                    name: "CRN",
                                    stringValue: (row) => (row as Map)["CRN"]),
                                EasyTableColumn(
                                  name: "Subject",
                                  stringValue: (row) => (row as Map)["SC"],
                                ),
                                EasyTableColumn(
                                  name: "Course",
                                  stringValue: (row) => (row as Map)["CN"],
                                ),
                                EasyTableColumn(
                                  name: "Description",
                                  stringValue: (row) => (row as Map)["CT"],
                                  width: 250,
                                ),
                                EasyTableColumn(
                                  name: "Days",
                                  stringValue: (row) => (row as Map)["D"],
                                ),
                                EasyTableColumn(
                                  name: "Start",
                                  stringValue: (row) => (row as Map)["TB"],
                                ),
                                EasyTableColumn(
                                  name: "End",
                                  stringValue: (row) => (row as Map)["TE"],
                                ),
                                EasyTableColumn(
                                  name: "Building",
                                  stringValue: (row) => (row as Map)["B"],
                                ),
                                EasyTableColumn(
                                  name: "Room",
                                  stringValue: (row) => (row as Map)["R"],
                                ),
                                EasyTableColumn(
                                  name: "Teacher(s)",
                                  stringValue: (row) => (row as Map)["TN"],
                                ),
                                EasyTableColumn(
                                  name: "Enrolled",
                                  stringValue: (row) => (row as Map)["E"],
                                ),
                                EasyTableColumn(
                                  name: "Date Start",
                                  stringValue: (row) => (row as Map)["PTRMDS"],
                                ),
                                EasyTableColumn(
                                  name: "Date End",
                                  stringValue: (row) => (row as Map)["PTRMDE"],
                                ),
                                EasyTableColumn(
                                  name: "Method",
                                  stringValue: (row) => (row as Map)["INSMC"],
                                ),
                                EasyTableColumn(
                                  name: "Added Fees",
                                  stringValue: (row) => (row as Map)["AF"],
                                ),
                              ],
                            ),
                            columnsFit: _doFitTableColumns,
                            visibleRowsCount: 20,
                          ),
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
