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

    // double _tableFontSize = 10;
    final _viewPortWidth = MediaQuery.of(context).size.width;

    final _isSmallFormFactor = _viewPortWidth <= 800;

    // print(_viewPortWidth);

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
                        : !_isSmallFormFactor
                            ? const MyEasyTable()
                            : ListView.builder(
                                itemCount: scheduleProvider.data.length,
                                itemBuilder: (context, index) {
                                  final _course = scheduleProvider.data[index];
                                  return ListTile(
                                    dense: true,
                                    title: CourseCard(
                                      course: _course,
                                    ),
                                  );
                                },
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

class MyEasyTable extends StatelessWidget {
  const MyEasyTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<Schedule>();
    // final _doFitTableColumns = MediaQuery.of(context).size.width >= 1750;

    // final _viewPortWidth = MediaQuery.of(context).size.width;

    return Center(
      child: EasyTable(
        EasyTableModel(
          rows: scheduleProvider.data,
          columns: [
            EasyTableColumn(
              name: "",
              cellBuilder: (context, row) => Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // MORE INFO ICON
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        size: 20,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final feesFlat = (row as Map)["FF"];
                            final feesCredit = row["FC"];
                            var feesTotal = "0.00";
                            try {
                              feesTotal = (double.parse(feesFlat) +
                                      double.parse(feesCredit))
                                  .toStringAsFixed(2);
                            } catch (e) {
                              log.error(e.toString());
                            }
                            return AlertDialog(
                              title: Text(
                                  "${row["CT"]} - ${row["SC"]} ${row["CN"]}"),
                              alignment: Alignment.center,
                              actions: [
                                TextButton(
                                  child: const Text("Close"),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                    foregroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                  onPressed: () {
                                    Modular.to.pop();
                                  },
                                ),
                              ],
                              content: SizedBox(
                                height: MediaQuery.of(context).size.height / 2,
                                width: MediaQuery.of(context).size.width / 2,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Campus:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(row["C"].toString()),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Teacher(s):",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(row["TN"]
                                          .toString()
                                          .replaceAll("<br/>", "; ")),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Enrolled:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(row["E"].toString()),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Building:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(row["B"].toString()),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Room:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(row["R"].toString()),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Dates in Session:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                          "${row["PTRMDS"]} / ${row["PTRMDE"]}"),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Days:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(row["D"].toString()),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Time:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing:
                                          Text("${row["TB"]} - ${row["TE"]}"),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Credit Hours:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(row["CH"].toString()),
                                    ),
                                    // BUY MATERIALS BUTTON
                                    ListTile(
                                      dense: true,
                                      title: TextButton.icon(
                                        onPressed: () => launchBookStore(row),
                                        icon: const Icon(Icons.menu_book_sharp),
                                        label: const Text("Buy Materials"),
                                        style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                            Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                          side: MaterialStateProperty.all(
                                            BorderSide(
                                              width: 1,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // ADDITIONAL FEES
                                    const ListTile(
                                      dense: true,
                                      leading: Text(
                                        "Additional Fees",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Flat:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text("${(row)["FF"]}"),
                                    ),
                                    ListTile(
                                      dense: true,
                                      leading: const Text(
                                        "Credit:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text("${row["FC"]}"),
                                    ),
                                    Divider(
                                      thickness: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    ListTile(
                                      dense: true,
                                      // leading: const Text(
                                      //   "Credit:",
                                      //   style: TextStyle(
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      trailing: Text(feesTotal),
                                    ),
                                    // DESCRIPTION
                                    const ListTile(
                                      dense: true,
                                      leading: Text(
                                        "Description",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      dense: true,
                                      title: Text(
                                        row["N"].toString().trim() != ""
                                            ? row["N"]
                                                .toString()
                                                .replaceAll("<br/>", "\n")
                                                .replaceAll("&lt;", "")
                                                .replaceAll("&gt;", "")
                                                .replaceAll("br/", "")
                                            : "No description.",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // BUY BOOKS ICON
                    IconButton(
                      icon: const Icon(
                        Icons.menu_book_sharp,
                        size: 20,
                      ),
                      onPressed: () {
                        launchBookStore(row);
                      },
                    ),
                  ],
                ),
              ),
            ),
            EasyTableColumn(
                name: "CRN", stringValue: (row) => (row as Map)["CRN"]),
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
              stringValue: (row) =>
                  (row as Map)["TN"].toString().replaceAll("<br/>", "\n"),
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
        // columnsFit: _viewPortWidth >= 1950 ? true : false,
        visibleRowsCount: 20,
      ),
    );
  }

  void launchBookStore(Object? row) {
    Uri bookStoreURI;
    const bookStoreHost = "ladelta.bncollege.com";
    const bookStorePath = "/webapp/wcs/stores/servlet/TBListView";
    var courseXML = "";
    if ((row as Map)["C"] == "MONROE CAMPUS") {
      courseXML =
          '<?xml version="1.0" encoding="UTF-8"?><textbookorder><campus name="MONROE"><courses><course dept="${row["SC"]}" num="${row["CN"]}" sect="${row["CRN"]}" term="${row["T"]}"/></courses></campus></textbookorder>';
    } else {
      courseXML =
          '<?xml version="1.0" encoding="UTF-8"?><textbookorder><campus name="OTHER"><courses><course dept="${row["SC"]}" num="${row["CN"]}" sect="${row["CRN"]}" term="${row["T"]}"/></courses></campus></textbookorder>';
    }
    bookStoreURI = Uri(
      scheme: 'https',
      host: bookStoreHost,
      path: bookStorePath,
      query: encodeQueryParameters(
        <String, String>{
          "cm_mmc": "RI-_-8279-_-1-_-A",
          "catalogId": "10001",
          "storeId": "89011",
          "langId": "-1",
          "termMapping": "Y",
          "courseXML": courseXML
        },
      ),
    );
    launchUrl(bookStoreURI);
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({
    Key? key,
    this.course = const {},
  }) : super(key: key);

  final Map course;

  @override
  Widget build(BuildContext context) {
    // final String _courseName = "${course["SC"]} ${course["CN"]}";
    final borderColor = AppColor.bronze2.withOpacity(.7);
    // final Color _color = Theme.of(context).colorScheme.primary;
    const Color _color = AppColor.navy;

    final friendlyName = "${course["SC"]} ${course["CN"]}";
    final days = "${course["PTRMDS"].toString().trim()} to ${course["PTRMDE"]}";
    final buildingAndRoom = "${course["B"]} - Room ${course["R"]}";
    var meetingTimes = "${course["TB"]} - ${course["TE"]}".trim();
    if (meetingTimes == "-") {
      meetingTimes = "";
    }

    return Column(
      children: [
        Align(
          heightFactor: .9,
          alignment: Alignment.centerLeft,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              friendlyName,
              style: const TextStyle(
                color: _color,
                fontWeight: FontWeight.bold,
              ),
            ),
            height: 30,
            width: 100,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(
                  5.0,
                  5.0,
                ),
                blurRadius: 10.0,
                spreadRadius: 3.0,
              ), //BoxShadow
              BoxShadow(
                color: Colors.black,
                offset: Offset(0.0, 0.0),
                blurRadius: 10.0,
                spreadRadius: 0.0,
              ), //BoxShadow
            ],
            color: borderColor,
            // borderRadius: const BorderRadius.all(Radius.circular(20)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),

          //-----------------------------
          // Card Body
          //-----------------------------
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      size: 40,
                      color: _color,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      buildingAndRoom,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _color,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 40, color: _color),
                    const SizedBox(width: 10),
                    Text(
                      days,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _color,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.watch_later_outlined,
                        size: 40, color: _color),
                    const SizedBox(width: 10),
                    Text(
                      meetingTimes,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _color,
                      ),
                    ),
                  ],
                ),

                // Row(
                //   children: [
                //     const Icon(
                //       Icons.email_outlined,
                //       size: 40,
                //     ),
                //     const SizedBox(width: 10),
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: const [
                //         Text(
                //           "test",
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Colors.deepPurple,
                //           ),
                //         ),
                //         Text(
                //           "test",
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Colors.deepPurple,
                //           ),
                //         ),
                //       ],
                //     )
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
