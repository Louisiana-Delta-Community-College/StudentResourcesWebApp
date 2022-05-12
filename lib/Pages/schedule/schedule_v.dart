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
    Modular.get<Schedule>().getScheduleData();
    Modular.get<ScheduleTermsMenu>().getMenuData();
    // Schedule app title to run in the future to allow `MyApp.build()`
    // to finish before updating.
    Future.delayed(const Duration(seconds: 1)).then((r) {
      // log.info("setting title");
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

    // final myTableController = context.watch<MyTableController>();

    final _groupButtonCampusMenuController =
        scheduleCampusMenuProvider.groupButtonCampusMenuController;

    final _groupButtonTermMenuController =
        scheduleTermsMenuProvider.groupButtonTermMenuController;

    // double _tableFontSize = 10;

    // print(_viewPortWidth);

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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.dark_mode_sharp,
                    color: AppColor.navy,
                  ),
                ),
                // REMOVE ONE PADDING-ICON DUE TO NAV BAR HAMBURGER MENU
                // Padding(
                //   padding: EdgeInsets.all(8.0),
                //   child: Icon(
                //     Icons.search,
                //     color: AppColor.navy,
                //   ),
                // ),
                Text("Schedule of Classes"),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  // onTap: () {
                  //   globalKey.currentState!.openDrawer();
                  // },
                  child: Image.asset(
                      isSmallFormFactor(context)
                          ? "assets/images/mark.png"
                          : "assets/images/logo.png",
                      fit: BoxFit.fitHeight),
                )
              ],
            )
          ],
        ),
        backgroundColor: AppColor.navy,
        foregroundColor: AppColor.white,
        searchCursorColor: themeProvider.text,
        searchBackIconTheme: IconThemeData(
          color: themeProvider.text,
        ),
        // centerTitle: true,
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
        onSearch: (value) {
          scheduleProvider.searchString = value;
          // log.verbose("Searching for: $value");
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
                            controller: _groupButtonCampusMenuController,
                            buttons: scheduleCampusMenuProvider.campusList,
                            isRadio: true,
                            onSelected: (selected, index, ___) {
                              if (!scheduleProvider.isLoading) {
                                scheduleProvider.campus = selected.toString();
                              }
                            },
                            options: const GroupButtonOptions(
                              unselectedColor: AppColor.navy,
                              unselectedTextStyle: TextStyle(
                                color: AppColor.white,
                              ),
                              selectedColor: AppColor.bronze2,
                              runSpacing: 2,
                              spacing: 2,
                              // borderRadius:
                              //     BorderRadius.all(Radius.circular(10)),
                            ),
                            buttonIndexedBuilder: (isSelected, index, context) {
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
                                  scheduleCampusMenuProvider.campusList[index]
                                      .toString()
                                      .replaceAll("LDCC", "")
                                      .replaceAll("CAMPUS", "")
                                      .titleCase
                                      .trim(),
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
            // TERMS MENU
            Expanded(
              flex: 10,
              child: Container(
                  padding: const EdgeInsets.only(
                    // top: 10,
                    bottom: 10,
                    left: 20,
                    right: 20,
                  ),
                  child: scheduleTermsMenuProvider.isLoading
                      ? const SkeletonLine(
                          style: SkeletonLineStyle(
                              alignment: Alignment.center,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
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
                              controller: _groupButtonTermMenuController,
                              buttons: scheduleTermsMenuProvider.termsList,
                              isRadio: true,
                              onSelected: (selectedTermDesc, index, ___) {
                                if (!scheduleProvider.isLoading) {
                                  // log.info(selectedTermDesc.toString());
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
                                  // log.info(
                                  //     "${scheduleProvider.term} / ${scheduleProvider.termType}");
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
              // COURSES
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
                    ? const Center(
                        child: CircularProgressIndicator(
                            // color:
                            //     themeProvider.dark.colorScheme.secondary.withOpacity(1),
                            ),
                      )
                    : scheduleProvider.hasError
                        ? Center(
                            child:
                                SelectableText(scheduleProvider.errorMessage))
                        // : SelectableText(scheduleProvider.data[0].toString()),
                        : scheduleProvider.filteredData.isNotEmpty
                            ? isSmallFormFactor(context)
                                // MOBILE STYLE CARDS
                                ? ListView.builder(
                                    itemCount:
                                        scheduleProvider.filteredData.length,
                                    itemBuilder: (context, index) {
                                      final _course =
                                          scheduleProvider.filteredData[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4, bottom: 4),
                                        child: ListTile(
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                          title: CourseCard(
                                            course: _course,
                                          ),
                                          onTap: () => scheduleProvider
                                              .showMoreInfoDialog(
                                                  context, _course),
                                        ),
                                      );
                                    },
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
                backgroundColor: themeProvider.surface,
                foregroundColor: AppColor.white,
              ),
            ),
          ],
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
    // final _doFitTableColumns = MediaQuery.of(context).size.width >= 1750;

    // final _viewPortWidth = MediaQuery.of(context).size.width;

    final _rows = scheduleProvider.filteredData;

    return Center(
      child: EasyTableTheme(
        data: EasyTableThemeData(
          headerCell: const HeaderCellThemeData(padding: EdgeInsets.all(5)),
          row: RowThemeData(
            hoveredColor: (index) => themeProvider.rowColorHover,
            columnDividerColor: themeProvider.text,
            color: (index) => index % 2 == 0
                ? themeProvider.rowColorHighlighted
                : themeProvider.rowColorNormal,
          ),
        ),
        child: EasyTable(
          EasyTableModel(
            rows: _rows,
            columns: [
              EasyTableColumn(
                name: "Controls",
                width: 140,
                // pinned: true,
                cellBuilder: (context, row) => EasyTableCell(
                  child: Row(
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
                        tooltip: "Copy to Clipboard",
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
          // columnsFit: _viewPortWidth >= 1950 ? true : false,
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
    // final String _courseName = "${course["SC"]} ${course["CN"]}";
    // final borderColor = AppColor.bronze2.withOpacity(.7);
    final Color _borderColor = Theme.of(context).colorScheme.primary;
    // final Color _color = Theme.of(context).colorScheme.primary;
    final Color _borderTextColor = Theme.of(context).colorScheme.onPrimary;
    final Color _textColor = Theme.of(context).colorScheme.onBackground;

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
            child: SelectableText(
              friendlyName,
              style: TextStyle(
                color: _borderTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            height: 30,
            // width: 300,
            decoration: BoxDecoration(
              color: _borderColor,
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
            color: _borderColor,
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
                      color: _textColor,
                    ),
                    const SizedBox(width: 10),
                    SelectableText(
                      buildingAndRoom,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 35, color: _textColor),
                    const SizedBox(width: 10),
                    SelectableText(
                      days,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.watch_later_outlined,
                        size: 35, color: _textColor),
                    const SizedBox(width: 10),
                    SelectableText(
                      meetingTimes,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
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
