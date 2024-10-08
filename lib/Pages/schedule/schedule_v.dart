import 'package:group_button/group_button.dart';
import 'package:schedule/common/common.dart';

import 'package:davi/davi.dart';

class SchedulePage extends StatefulWidget {
  final String year;
  final String season;
  final String current;
  const SchedulePage(
      {Key? key, this.season = "", this.year = "", this.current = ""})
      : super(key: key);

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

    // If parameters `season` and `year` are populated check their values and
    // set ScheduleTermsMenu.termDesc if necessary
    final season = widget.season.toString().toLowerCase();
    final year = widget.year.toString();

    ScheduleTermsMenu scheduleTermsMenu = Modular.get<ScheduleTermsMenu>();

    bool fetchCurrent =
        (widget.current.isNotEmpty && widget.current == "current");
    Modular.get<Schedule>().fetchCurrent = fetchCurrent;

    String termCode = "";
    String termTy = "";
    Map<String, dynamic> passedInTerm = {};
    if (season.isNotEmpty && year.isNotEmpty && year.length == 4) {
      // is year 4 characters long and is it a number?
      int? intYear = int.tryParse(widget.year);
      if (intYear != null) {
        if (["spring", "summer", "fall", "winter"]
            .any((element) => element.contains(season))) {
          // Build term code
          if (season == "spring") {
            termCode = "${intYear}20";
            termTy = "";
          }
          if (season == "summer") {
            termCode = "${intYear}30";
            termTy = "";
          }
          if (season == "fall") {
            intYear = intYear + 1;
            termCode = "${intYear}10";
            termTy = "";
          }
          if (season == "winter") {
            termCode = "${intYear}20";
            termTy = "JWN";
          }
          if (termCode.isNotEmpty) {
            passedInTerm = {
              "Term": termCode,
              "Desc": "${season.titleCase} $year",
              "TermTy": termTy,
              "default": true
            };
            scheduleTermsMenu.passedInTerm = passedInTerm;
            Modular.get<Schedule>().term = termCode;
            Modular.get<Schedule>().termType = termTy;
          }
        } else {
          log.d("Season not recognized.");
        }
      }
    }

    Modular.get<Schedule>().getScheduleData();
    scheduleTermsMenu.getMenuData();
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

    return LayoutBuilder(builder: (context, constraints) {
      var isSmallFormFactor = constraints.maxWidth < 800;

      return Scaffold(
        // key: globalKey,
        drawer: const NavBar(),
        appBar: EasySearchBar(
          title: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // This is here to pad the title to center position
                  const Icon(
                    Icons.dark_mode_sharp,
                    color: AppColor.primary,
                  ),
                  Center(
                    child: Text(
                      "Schedule of Classes",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: themeProvider.fontSizeM,
                      ),
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
                          isSmallFormFactor
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
                              onSelected: (Object? selected, int index,
                                  bool ___) async {
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
                              buttonIndexedBuilder:
                                  (isSelected, index, context) {
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
                                  if (scheduleProvider
                                          .searchString.isNotEmpty &&
                                      matchCount > 0) {
                                    matchCountString = "$matchCount";
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        campusDisplayName,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColor.primary
                                              : AppColor.white,
                                          fontSize: themeProvider.fontSizeXS,
                                        ),
                                      ),
                                      matchCount > 0
                                          // ? Padding(
                                          //     padding: const EdgeInsets.only(
                                          //         left: 4.0),
                                          //     child: Chip(side: ,
                                          //       labelStyle: TextStyle(
                                          //         color: Colors.white,
                                          //         fontSize: themeProvider.fontSizeXS,
                                          //       ),
                                          //       backgroundColor:
                                          //           AppTheme.quaternary,
                                          //       padding: EdgeInsets.only(
                                          //         left: 2.0,
                                          //         right: 2.0,
                                          //         top: 0.0,
                                          //         bottom: 0.0,
                                          //       ),
                                          //       labelPadding: EdgeInsets.only(
                                          //         left: 1.0,
                                          //         right: 1.0,
                                          //         top: 0.0,
                                          //         bottom: 0.0,
                                          //       ),
                                          //       label: Text(
                                          //         matchCountString,
                                          //         style: TextStyle(
                                          //           color: Colors.white,
                                          //           fontSize: themeProvider.fontSizeXS,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   )
                                          ? MatchCountChip(matchCountString)
                                          : Container(),
                                    ],
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
                                  selectedColor:
                                      themeProvider.menuColorSelected,
                                  runSpacing: 0,
                                  spacing: 0,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              buttonIndexedBuilder:
                                  (isSelected, index, context) {
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
                                    scheduleTermsMenuProvider.data[index]
                                            ["Desc"]
                                        .toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColor.primary
                                          : AppColor.white,
                                      fontSize: themeProvider.fontSizeXS,
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
                          : scheduleProvider.currentlySelectedCampusFilteredData
                                  .isNotEmpty
                              ? isSmallFormFactor
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
                                              top: 4,
                                              bottom: 4,
                                            ),
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
                                  : const ScheduleDavi()
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
    });
  }
}

class MatchCountChip extends StatelessWidget {
  final String countString;
  const MatchCountChip(
    this.countString, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppTheme>();

    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Container(
        padding: const EdgeInsets.only(
          left: 3.0,
          right: 3.0,
          // top: 2.0,
          // bottom: 2.0,
        ),
        decoration: BoxDecoration(
          color: AppTheme.quaternary,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: AppTheme.quaternary),
        ),
        child: Text(
          countString,
          style: TextStyle(
            color: Colors.white,
            fontSize: themeProvider.fontSizeXS,
          ),
        ),
      ),
    );
  }
}

class ScheduleDavi extends StatelessWidget {
  const ScheduleDavi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<Schedule>();
    final themeProvider = context.watch<AppTheme>();
    final rows = scheduleProvider.currentlySelectedCampusFilteredData;

    return Center(
      child: DaviTheme(
        data: DaviThemeData(
          headerCell: HeaderCellThemeData(
            textStyle: TextStyle(
              color: themeProvider.text,
              fontSize: themeProvider.fontSizeXS,
            ),
            height: themeProvider.daviRowHeight,
            sortPriorityColor: themeProvider.text,
            padding: const EdgeInsets.all(5),
            sortIconColors: SortIconColors.all(themeProvider.text),
          ),
          row: RowThemeData(
            hoverBackground: (index) => themeProvider.rowColorHover,
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
            contentHeight: themeProvider.daviRowHeight,
            textStyle: TextStyle(
              color: themeProvider.daviText,
              fontSize: themeProvider.fontSizeXS,
            ),
          ),
        ),
        child: Davi(
          DaviModel(
            rows: rows,
            columns: [
              DaviColumn(
                name: "Controls",
                width: 140,
                // pinned: true,
                cellBuilder: (context, row) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // MORE INFO ICON
                    IconButton(
                      color: themeProvider.text,
                      tooltip: "More Info",
                      padding: const EdgeInsets.only(
                        left: 1,
                        right: 1,
                      ),
                      icon: Icon(
                        Icons.info_outline,
                        size: themeProvider.fontSizeM,
                      ),
                      onPressed: () {
                        scheduleProvider.showMoreInfoDialog(context, row);
                      },
                    ),
                    // BUY BOOKS ICON
                    IconButton(
                      color: themeProvider.text,
                      tooltip: "Buy Materials",
                      padding: const EdgeInsets.only(
                        left: 1,
                        right: 1,
                      ),
                      icon: Icon(
                        Icons.menu_book_sharp,
                        size: themeProvider.fontSizeM,
                      ),
                      onPressed: () {
                        scheduleProvider.launchBookStore(row);
                      },
                    ),
                    IconButton(
                      color: themeProvider.text,
                      tooltip: "Copy Course Information",
                      padding: const EdgeInsets.only(
                        left: 1,
                        right: 1,
                      ),
                      icon: Icon(
                        Icons.copy_all_sharp,
                        size: themeProvider.fontSizeM,
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
              DaviColumn(
                name: "CRN",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["CRN"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["CRN"]}, ${a["CRN"]}";
                  String v2 = "${(b as Map)["CRN"]}, ${b["CRN"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                // pinned: true,
              ),
              DaviColumn(
                name: "Subject",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["SC"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["SC"]}, ${a["SC"]}";
                  String v2 = "${(b as Map)["SC"]}, ${b["SC"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                // width: 70,
              ),
              DaviColumn(
                name: "Course",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["CN"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["CN"]}, ${a["CN"]}";
                  String v2 = "${(b as Map)["CN"]}, ${b["CN"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                // width: 70,
              ),
              DaviColumn(
                name: "Description",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["CT"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["CT"]}, ${a["CT"]}";
                  String v2 = "${(b as Map)["CT"]}, ${b["CT"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 330 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                sortable: true,
                name: "Course Duration",
                width: 160 + themeProvider.fontSizeXXS * 2,
                cellBuilder: (ctx, row) {
                  final ptrm = (row.data as Map)["PTRM"].toString();
                  final termDesc = (row.data as Map)["TD"];
                  String friendlyType;
                  if (termDesc.toString().toLowerCase().contains("summer")) {
                    if (ptrm == "J01") {
                      friendlyType = "Full 8 Weeks";
                    } else if (ptrm == "J02") {
                      friendlyType = "1st 4 Weeks";
                    } else if (ptrm == "J03") {
                      friendlyType = "2nd 4 Weeks";
                    } else if (ptrm == "JP") {
                      friendlyType = "Extended 10 Weeks";
                    } else {
                      friendlyType = "See Date Range";
                    }
                  } else {
                    if (ptrm == "J01") {
                      friendlyType = "Full 16 Weeks";
                    } else if (ptrm == "J02") {
                      friendlyType = "1st 8 Weeks";
                    } else if (ptrm == "J03") {
                      friendlyType = "2nd 8 Weeks";
                    } else {
                      friendlyType = "See Date Range";
                    }
                  }
                  return Focus(
                    child: Semantics(
                      label: friendlyType,
                      excludeSemantics: true,
                      child: Text(
                        friendlyType,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["PTRM"]}, ${a["PTRM"]}";
                  String v2 = "${(b as Map)["PTRM"]}, ${b["PTRM"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
              ),
              DaviColumn(
                name: "Hours",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["CH"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["CH"]}, ${a["CH"]}";
                  String v2 = "${(b as Map)["CH"]}, ${b["CH"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 60 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Days",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["D"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["D"]}, ${a["D"]}";
                  String v2 = "${(b as Map)["D"]}, ${b["D"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 80 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Start",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["TB"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["TB"]}, ${a["TB"]}";
                  String v2 = "${(b as Map)["TB"]}, ${b["TB"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 80 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "End",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["TE"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["TE"]}, ${a["TE"]}";
                  String v2 = "${(b as Map)["TE"]}, ${b["TE"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 80 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Building",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["B"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["B"]}, ${a["B"]}";
                  String v2 = "${(b as Map)["B"]}, ${b["B"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 300 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Room",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["R"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["R"]}, ${a["R"]}";
                  String v2 = "${(b as Map)["R"]}, ${b["R"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 80 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Teacher(s)",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["TN"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["TN"]}, ${a["TN"]}";
                  String v2 = "${(b as Map)["TN"]}, ${b["TN"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 240 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Enrolled",
                cellBuilder: (context, row) {
                  final val =
                      "${(row.data as Map)["E"]} / ${(row.data as Map)["MS"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["E"]}, ${a["E"]}";
                  String v2 = "${(b as Map)["E"]}, ${b["E"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 80 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Date Start",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["PTRMDS"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["PTRMDS"]}, ${a["PTRMDS"]}";
                  String v2 = "${(b as Map)["PTRMDS"]}, ${b["PTRMDS"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 100 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Date End",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["PTRMDE"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["PTRMDE"]}, ${a["PTRMDE"]}";
                  String v2 = "${(b as Map)["PTRMDE"]}, ${b["PTRMDE"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 100 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Method",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["INSMC"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["INSMC"]}, ${a["INSMC"]}";
                  String v2 = "${(b as Map)["INSMC"]}, ${b["INSMC"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 80 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                name: "Added Fees",
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["AF"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                      ),
                    ),
                  );
                },
                dataComparator: (a, b, column) {
                  String v1 = "${(a as Map)["AF"]}, ${a["AF"]}";
                  String v2 = "${(b as Map)["AF"]}, ${b["AF"]}";
                  if (v1.isEmpty || v2.isEmpty) {
                    return 0;
                  }
                  if (v1.isEmpty) {
                    return 0;
                  }
                  if (v2.isEmpty) {
                    return 1;
                  }
                  return v1.compareTo(v2);
                },
                width: 100 + themeProvider.fontSizeXXS * 2,
              ),
            ],
            multiSortEnabled: true,
          ),
          visibleRowsCount: 20,
          tapToSortEnabled: true,
          columnWidthBehavior: ColumnWidthBehavior.scrollable,
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
    // final Color textColor = Theme.of(context).colorScheme.onBackground;
    final Color textColor = themeProvider.mobileCardTextColor;

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
                fontSize: themeProvider.fontSizeS,
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
                        fontSize: themeProvider.fontSizeS,
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
                        fontSize: themeProvider.fontSizeS,
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
                        fontSize: themeProvider.fontSizeS,
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
