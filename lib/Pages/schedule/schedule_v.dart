import 'package:group_button/group_button.dart';
import 'package:schedule/common/common.dart';

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
    // Modular.get<Schedule>().init();
    Modular.get<Schedule>().getScheduleData();
    Modular.get<ScheduleTermsMenu>().getMenuData();
    // Schedule app title to run in the future to allow `MyApp.build()`
    // to finish before updating.
    Future.delayed(const Duration(seconds: 1)).then((r) {
      Modular.get<AppTitle>().title = "Schedule of Classes";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<Schedule>();
    final scheduleTermsMenuProvider = context.watch<ScheduleTermsMenu>();
    final scheduleCampusMenuProvider = context.watch<ScheduleCampusMenu>();
    final themeProvider = context.watch<AppTheme>();

    final groupButtonCampusMenuController =
        scheduleCampusMenuProvider.groupButtonCampusMenuController;

    final groupButtonTermMenuController =
        scheduleTermsMenuProvider.groupButtonTermMenuController;

    final matchCounts = scheduleProvider.matchCounts;

    return Scaffold(
      // key: globalKey,
      drawer: const NavBar(),
      appBar: EasySearchBar(
        title: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // This is here to pad the title to center position
                Icon(
                  Icons.dark_mode_sharp,
                  color: AppColor.primary,
                ),
                Center(
                  child: Text(
                    "Schedule of Classes",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Focus(
                  child: Semantics(
                    image: true,
                    label: "LDCC Logo",
                    excludeSemantics: true,
                    child: Image.asset(
                        isSmallFormFactor(context)
                            ? "assets/images/mark.png"
                            : "assets/images/logo.png",
                        fit: BoxFit.fitHeight),
                  ),
                )
              ],
            )
          ],
        ),
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.white,
        searchCursorColor: themeProvider.text,
        searchBackIconTheme: IconThemeData(
          color: themeProvider.text,
        ),
        // centerTitle: true,
        actions: [
          Semantics(
            button: true,
            value: "toggle brightness mode",
            child: FadeInDown(
              preferences: const AnimationPreferences(
                autoPlay: AnimationPlayStates.Forward,
                duration: Duration(
                  milliseconds: 500,
                ),
              ),
              child: IconButton(
                  tooltip: "Toggle Brightness Mode",
                  onPressed: () {
                    themeProvider.toggle();
                  },
                  icon: themeProvider.icon),
            ),
          ),
        ],
        onSearch: (value) {
          scheduleProvider.searchString = value;
          scheduleProvider.updateMatchCounts();
        },
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // CAMPUS MENU
            Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                child: scheduleCampusMenuProvider.isLoading
                    ? SkeletonLine(
                        style: SkeletonLineStyle(
                          alignment: Alignment.center,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          padding: EdgeInsets.only(
                            left: viewPortWidth(context) * .2,
                            right: viewPortWidth(context) * .2,
                          ),
                          // randomLength: true,
                        ),
                      )
                    : scheduleCampusMenuProvider.hasError
                        ? Center(
                            child: SelectableText(
                                scheduleCampusMenuProvider.errorMessage),
                          )
                        : GroupButton(
                            controller: groupButtonCampusMenuController,
                            buttons: scheduleCampusMenuProvider.campusList,
                            isRadio: true,
                            onSelected:
                                (Object? selected, int index, bool ___) async {
                              if (!scheduleProvider.isLoading) {
                                scheduleProvider.campus = selected.toString();
                              }
                            },
                            options: GroupButtonOptions(
                              unselectedColor: AppColor.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              unselectedTextStyle: const TextStyle(
                                color: AppColor.white,
                              ),
                              selectedColor: themeProvider.menuColorSelected,
                              runSpacing: 2,
                              spacing: 2,
                              // borderRadius:
                              //     BorderRadius.all(Radius.circular(10)),
                            ),
                            buttonIndexedBuilder: (isSelected, index, context) {
                              var matchCount = 0;
                              var matchCountString = "";
                              final campusDisplayName =
                                  scheduleCampusMenuProvider.campusList[index]
                                      .toString()
                                      .replaceAll("LDCC", "")
                                      .replaceAll("CAMPUS", "")
                                      .titleCase
                                      .trim();
                              if (matchCounts.isNotEmpty) {
                                matchCount =
                                    scheduleProvider.matchCounts[index];
                                if (scheduleProvider.searchString.isNotEmpty &&
                                    matchCount > 0) {
                                  matchCountString = " ($matchCount)";
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? themeProvider.menuColorSelected
                                      : AppColor.primary,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  border: Border.all(
                                    color: themeProvider.menuColorBorder,
                                    width: 2,
                                  ),
                                  // borderRadius: index == 0
                                  //     ? const BorderRadius.only(
                                  //         topLeft: Radius.circular(10),
                                  //         bottomLeft: Radius.circular(10))
                                  //     : scheduleCampusMenuProvider
                                  //                 .campusList[index] ==
                                  //             scheduleCampusMenuProvider
                                  //                 .campusList.last
                                  //         ? const BorderRadius.only(
                                  //             topRight: Radius.circular(10),
                                  //             bottomRight: Radius.circular(10))
                                  //         : null,
                                ),
                                child: Text(
                                  "$campusDisplayName$matchCountString",
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColor.primary
                                        : AppColor.white,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          )
                // isSelected: [
                //     for (final item in scheduleMenuProvider.data) true
                //   ])
                ),
            // TERMS MENU
            Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                child: scheduleTermsMenuProvider.isLoading
                    ? const SkeletonLine(
                        style: SkeletonLineStyle(
                            alignment: Alignment.center,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            padding: EdgeInsets.only(
                              left: 200,
                              right: 200,
                            )
                            // randomLength: true,
                            ),
                      )
                    : scheduleTermsMenuProvider.hasError
                        ? Center(
                            child: SelectableText(
                                scheduleTermsMenuProvider.errorMessage),
                          )
                        : GroupButton(
                            controller: groupButtonTermMenuController,
                            buttons: scheduleTermsMenuProvider.termsList,
                            isRadio: true,
                            onSelected: (Object? selectedTermDesc, int index,
                                bool ___) async {
                              if (!scheduleProvider.isLoading) {
                                // final selectedTermData =
                                //     scheduleTermsMenuProvider
                                //         .data
                                //         .where((e) =>
                                //             e["Term"] ==
                                //             selectedTermDesc.toString())
                                //         .toList();
                                scheduleProvider.term =
                                    scheduleTermsMenuProvider.data[index]
                                            ["Term"]
                                        .toString();
                                scheduleProvider.termType =
                                    scheduleTermsMenuProvider.data[index]
                                            ["TermTy"]
                                        .toString();
                                scheduleTermsMenuProvider.selectedTermDesc =
                                    selectedTermDesc.toString();
                                scheduleProvider.getScheduleData();
                              }
                            },
                            options: GroupButtonOptions(
                                unselectedColor: AppColor.primary,
                                unselectedTextStyle: const TextStyle(
                                  color: AppColor.white,
                                ),
                                selectedColor: themeProvider.menuColorSelected,
                                runSpacing: 0,
                                spacing: 0,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            buttonIndexedBuilder: (isSelected, index, context) {
                              return Container(
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                    color: isSelected
                                        ? themeProvider.menuColorSelected
                                        : AppColor.primary,
                                    border: Border.all(
                                      color: themeProvider.menuColorBorder,
                                      width: 2,
                                    ),
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
                                  scheduleTermsMenuProvider.data[index]["Desc"]
                                      .toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColor.primary
                                        : AppColor.white,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          )
                // isSelected: [
                //     for (final item in scheduleMenuProvider.data) true
                //   ])
                ),
            Expanded(
              flex: 80,
              child: Container(
                // color: Colors.green,
                padding: const EdgeInsets.only(
                  // top: 10,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: scheduleProvider.isLoading
                    ? const CustomLoadingIndicator()
                    : scheduleProvider.hasError
                        ? Center(
                            child:
                                SelectableText(scheduleProvider.errorMessage))
                        // : SelectableText(scheduleProvider.data[0].toString()),
                        : scheduleProvider
                                .currentlySelectedCampusFilteredData.isNotEmpty
                            ? isSmallFormFactor(context)
                                // MOBILE STYLE CARDS
                                ? GlowingOverscrollIndicator(
                                    axisDirection: AxisDirection.down,
                                    color: AppColor.secondary,
                                    child: ListView.builder(
                                      itemCount: scheduleProvider
                                          .currentlySelectedCampusFilteredData
                                          .length,
                                      itemBuilder: (context, index) {
                                        final course = scheduleProvider
                                                .currentlySelectedCampusFilteredData[
                                            index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: ListTile(
                                            dense: true,
                                            visualDensity:
                                                VisualDensity.compact,
                                            title: CourseCard(
                                              course: course,
                                            ),
                                            onTap: () => scheduleProvider
                                                .showMoreInfoDialog(
                                                    context, course),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                // SHOW REGULAR TABLE
                                : const ScheduleEasyTable()
                            : Center(
                                child: SelectableText(
                                  scheduleProvider.searchString.isNotEmpty
                                      ? "No results for that search."
                                      : "No courses for this campus / term.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Focus(
        child: Semantics(
          button: true,
          label: "Refresh Table Data",
          child: FadeInUp(
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
                    heroTag: "btnRefresh",
                    backgroundColor:
                        themeProvider.floatingActionButtonBackgroundColor,
                    foregroundColor:
                        themeProvider.floatingActionButtonForegroundColor,
                    child: const Icon(Icons.refresh),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScheduleEasyTable extends StatelessWidget {
  const ScheduleEasyTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<Schedule>();
    final themeProvider = context.watch<AppTheme>();
    final rows = scheduleProvider.currentlySelectedCampusFilteredData;

    return Center(
      child: EasyTableTheme(
        data: EasyTableThemeData(
          headerCell: HeaderCellThemeData(
            padding: const EdgeInsets.all(5),
            sortIconColor: themeProvider.text,
          ),
          row: RowThemeData(
            hoveredColor: (index) => themeProvider.rowColorHover,
            color: (index) => index % 2 == 0
                ? themeProvider.rowColorHighlighted
                : themeProvider.rowColorNormal,
          ),
          scrollbar: const TableScrollbarThemeData(
            thickness: 10,
            thumbColor: AppTheme.primary,
            radius: Radius.circular(10),
          ),
          cell: CellThemeData(
            textStyle: TextStyle(
              color: themeProvider.easyTableText,
            ),
          ),
        ),
        child: EasyTable(
          EasyTableModel(
            rows: rows,
            columns: [
              EasyTableColumn(
                name: "Controls",
                width: 140,
                // pinned: true,
                cellBuilder: (context, row, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // MORE INFO ICON
                    IconButton(
                      tooltip: "More Info",
                      padding: const EdgeInsets.only(
                        left: 1,
                        right: 1,
                      ),
                      icon: const Icon(
                        Icons.info_outline,
                        size: 20,
                      ),
                      onPressed: () {
                        scheduleProvider.showMoreInfoDialog(context, row);
                      },
                    ),
                    // BUY BOOKS ICON
                    IconButton(
                      tooltip: "Buy Materials",
                      padding: const EdgeInsets.only(
                        left: 1,
                        right: 1,
                      ),
                      icon: const Icon(
                        Icons.menu_book_sharp,
                        size: 20,
                      ),
                      onPressed: () {
                        scheduleProvider.launchBookStore(row);
                      },
                    ),
                    IconButton(
                      tooltip: "Copy Course Information",
                      padding: const EdgeInsets.only(
                        left: 1,
                        right: 1,
                      ),
                      icon: const Icon(
                        Icons.copy_all_sharp,
                        size: 20,
                      ),
                      onPressed: () {
                        scheduleProvider.copyRowToClipboard(row);

                        showSnackBar(
                          'Course information copied to clipboard!',
                          isSuccess: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
              EasyTableColumn(
                name: "CRN",
                stringValue: (row) => (row as Map)["CRN"],
                width: 60,
                // pinned: true,
              ),
              EasyTableColumn(
                name: "Subject",
                stringValue: (row) => (row as Map)["SC"],
                width: 70,
              ),
              EasyTableColumn(
                name: "Course",
                stringValue: (row) => (row as Map)["CN"],
                width: 70,
              ),
              EasyTableColumn(
                name: "Description",
                stringValue: (row) => (row as Map)["CT"],
                width: 250,
              ),
              EasyTableColumn(
                name: "Hours",
                stringValue: (row) => (row as Map)["CH"],
                width: 60,
              ),
              EasyTableColumn(
                name: "Days",
                stringValue: (row) => (row as Map)["D"],
                width: 80,
              ),
              EasyTableColumn(
                name: "Start",
                stringValue: (row) => (row as Map)["TB"],
                width: 80,
              ),
              EasyTableColumn(
                name: "End",
                stringValue: (row) => (row as Map)["TE"],
                width: 80,
              ),
              EasyTableColumn(
                name: "Building",
                stringValue: (row) => (row as Map)["B"],
                width: 220,
              ),
              EasyTableColumn(
                name: "Room",
                stringValue: (row) => (row as Map)["R"],
                width: 80,
              ),
              EasyTableColumn(
                name: "Teacher(s)",
                stringValue: (row) => (row as Map)["TN"].toString(),
                width: 240,
              ),
              EasyTableColumn(
                name: "Enrolled",
                stringValue: (row) => "${(row as Map)["E"]} / ${row["MS"]}",
                width: 80,
              ),
              EasyTableColumn(
                name: "Date Start",
                stringValue: (row) => (row as Map)["PTRMDS"],
                width: 100,
              ),
              EasyTableColumn(
                name: "Date End",
                stringValue: (row) => (row as Map)["PTRMDE"],
                width: 100,
              ),
              EasyTableColumn(
                name: "Method",
                stringValue: (row) => (row as Map)["INSMC"],
                width: 80,
              ),
              EasyTableColumn(
                name: "Added Fees",
                stringValue: (row) => (row as Map)["AF"],
                width: 100,
              ),
            ],
          ),
          visibleRowsCount: 20,
        ),
      ),
    );
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
    final themeProvider = context.watch<AppTheme>();
    final Color borderColor = themeProvider.mobileCardBorderColor;
    final Color borderTextColor = themeProvider.mobileCardBorderTextColor;
    final Color textColor = Theme.of(context).colorScheme.onBackground;

    final subjectCode = course["SC"].toString().trim();
    final courseNumber = course["CN"].toString().trim();
    final courseTitle = course["CT"].toString().trim();
    final friendlyName = subjectCode.isNotEmpty && courseNumber.isNotEmpty
        ? "$subjectCode $courseNumber - $courseTitle"
        : "N/A";

    final building = course["B"].toString().trim();
    final room = course["R"].toString().trim();
    var buildingAndRoom =
        "${building.isNotEmpty ? building : "N/A"} - ${room.isNotEmpty ? room : "N/A"}";

    final dateStart = course["PTRMDS"].toString().trim();
    final dateEnd = course["PTRMDE"].toString().trim();
    final days = dateStart.isNotEmpty && dateEnd.isNotEmpty
        ? "$dateStart to $dateEnd"
        : "N/A";

    var meetingTimes = "${course["TB"]} - ${course["TE"]}".trim();
    if (meetingTimes == "-") {
      meetingTimes = "N/A";
    }

    return Column(
      children: [
        Align(
          heightFactor: .9,
          alignment: Alignment.centerLeft,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 15),
            height: 30,
            // width: 300,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 5.0, // soften the shadow
                  spreadRadius: 0.0, // extend the shadow
                  offset: Offset(
                    3.0, // right horizontally
                    3.0, // down Vertically
                  ),
                )
              ],
            ),
            child: Text(
              friendlyName,
              style: TextStyle(
                color: borderTextColor,
                fontSize: 14,
                // fontWeight: FontWeight.w600,
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
                color: Colors.black,
                blurRadius: 5.0, // soften the shadow
                spreadRadius: 0.0, // extend the shadow
                offset: Offset(
                  3.0, // right horizontally
                  3.0, // down Vertically
                ),
              )
            ],
            color: borderColor,
            // borderRadius: const BorderRadius.all(Radius.circular(20)),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),

          //-----------------------------
          // Card Body
          //-----------------------------
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.meeting_room,
                      size: 35,
                      color: textColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      buildingAndRoom,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 35, color: textColor),
                    const SizedBox(width: 10),
                    Text(
                      days,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.watch_later_outlined,
                        size: 35, color: textColor),
                    const SizedBox(width: 10),
                    Text(
                      meetingTimes,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
