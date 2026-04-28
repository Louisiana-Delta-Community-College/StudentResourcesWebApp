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
  bool _isSearchOpen = false;

  @override
  @override
  void initState() {
    super.initState();

    final season = widget.season.toString().toLowerCase();
    final year = widget.year.toString();

    final scheduleTermsMenu = Modular.get<ScheduleTermsMenu>();

    final fetchCurrent =
        (widget.current.isNotEmpty && widget.current == "current");
    Modular.get<Schedule>().fetchCurrent = fetchCurrent;

    String termCode = "";
    String termTy = "";
    Map<String, dynamic> passedInTerm = {};

    if (season.isNotEmpty && year.isNotEmpty && year.length == 4) {
      int? intYear = int.tryParse(widget.year);
      if (intYear != null) {
        if (["spring", "summer", "fall", "winter"]
            .any((element) => element.contains(season))) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Modular.get<AppTitle>().title = "Schedule of Classes";
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<Schedule>();
    final scheduleTermsMenuProvider = context.watch<ScheduleTermsMenu>();
    final scheduleCampusMenuProvider = context.watch<ScheduleCampusMenu>();
    final themeProvider = context.watch<AppTheme>();
    final cellFontSize = themeProvider.fontSizeXS;

    final groupButtonCampusMenuController =
        scheduleCampusMenuProvider.groupButtonCampusMenuController;

    final groupButtonTermMenuController =
        scheduleTermsMenuProvider.groupButtonTermMenuController;

    final matchCounts = scheduleProvider.matchCounts;

    return LayoutBuilder(builder: (context, constraints) {
      final themeProvider = context.read<AppTheme>();
      themeProvider.updateLayoutMetrics(constraints.maxWidth);
      var isSmallFormFactor = constraints.maxWidth < 800;

      return Scaffold(
        // key: globalKey,
        drawer: const NavBar(),
        appBar: AppBar(
          title: SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // TITLE (fades out when search open)
                Opacity(
                  opacity: _isSearchOpen ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isSearchOpen,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.dark_mode_sharp,
                          color: AppColor.primary,
                        ),
                        Semantics(
                          label: "Page Title: Schedule of Classes",
                          excludeSemantics: true,
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
                  ),
                ),
                // LOGO
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: isSmallFormFactor ? 60 : 250,
                    child: Focus(
                      child: Semantics(
                        image: true,
                        label: "LDCC Logo",
                        excludeSemantics: true,
                        child: Image.asset(
                          isSmallFormFactor
                              ? "assets/images/mark.png"
                              : "assets/images/logo.png",
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                ),
                // SEARCH FIELD (fades in when search open)
                Positioned(
                  left: isSmallFormFactor ? 60 : 250,
                  right: 100,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: _isSearchOpen ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !_isSearchOpen,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          cursorColor: AppColor.white,
                          key: ValueKey<bool>(
                              _isSearchOpen), // ADD THIS - forces rebuild on toggle
                          autofocus: _isSearchOpen, // ADD THIS
                          onChanged: (value) {
                            scheduleProvider.searchString = value;
                            scheduleProvider.updateMatchCounts();
                          },
                          style: const TextStyle(color: AppColor.white),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              color: AppColor.white.withValues(alpha: 0.7),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColor.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          actions: [
            // SEARCH TOGGLE
            IconButton(
              tooltip: "Search",
              onPressed: () {
                setState(() {
                  _isSearchOpen = !_isSearchOpen;
                  if (!_isSearchOpen) {
                    scheduleProvider.searchString = "";
                    scheduleProvider.updateMatchCounts();
                  }
                });
              },
              icon: Icon(
                _isSearchOpen ? Icons.close : Icons.search,
                color: AppColor.white,
              ),
            ),
            // BRIGHTNESS TOGGLE
            Semantics(
              button: true,
              value: "toggle brightness mode",
              child: FadeInDown(
                preferences: const AnimationPreferences(
                  autoPlay: AnimationPlayStates.Forward,
                  duration: Duration(milliseconds: 500),
                ),
                child: IconButton(
                  tooltip: "Toggle Brightness Mode",
                  onPressed: () {
                    themeProvider.toggle();
                  },
                  icon: themeProvider.icon,
                ),
              ),
            ),
          ],
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
                      ? Skeletonizer(
                          child: Container(
                            height: 20,
                            margin: EdgeInsets.symmetric(
                              horizontal: viewPortWidth(context) * .2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
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
                                          fontSize: cellFontSize,
                                        ),
                                      ),
                                      matchCount > 0
                                          // ? Padding(
                                          //     padding: const EdgeInsets.only(
                                          //         left: 4.0),
                                          //     child: Chip(side: ,
                                          //       labelStyle: TextStyle(
                                          //         color: Colors.white,
                                          //         fontSize: cellFontSize,
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
                                          //           fontSize: cellFontSize,
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
                      ? Skeletonizer(
                          child: Container(
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 200),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
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
                                      fontSize: cellFontSize,
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
    final cellFontSize = themeProvider.fontSizeXS;

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
            fontSize: cellFontSize,
          ),
        ),
      ),
    );
  }
}

class ScheduleDavi extends StatefulWidget {
  const ScheduleDavi({Key? key}) : super(key: key);

  @override
  State<ScheduleDavi> createState() => _ScheduleDaviState();
}

class _ScheduleDaviState extends State<ScheduleDavi> {
  Map<String, double> _cachedWidths = {};
  String _cacheKey = "";

  String _buildCacheKey(
    List rows,
    AppTheme themeProvider,
  ) {
    final length = rows.length;
    final firstHash = length > 0 ? rows.first.hashCode : 0;
    final lastHash = length > 0 ? rows.last.hashCode : 0;

    return [
      length,
      firstHash,
      lastHash,
      themeProvider.daviFontSize.toStringAsFixed(2),
      themeProvider.viewportBucket,
    ].join("|");
  }

  Map<String, double> _computeWidths(
    List rows,
    AppTheme themeProvider,
  ) {
    final cellFontSize = themeProvider.daviFontSize;

    return {
      "CRN": computeColumnWidth(
        header: "CRN",
        values: rows.map((r) => r['CRN'].toString()),
        fontSize: cellFontSize,
        minWidth: 70,
        maxWidth: 140,
      ),
      "SC": computeColumnWidth(
        header: "Subject",
        values: rows.map((r) => r['SC'].toString()),
        fontSize: cellFontSize,
        minWidth: 85,
        maxWidth: 140,
      ),
      "CN": computeColumnWidth(
        header: "Course",
        values: rows.map((r) => r['CN'].toString()),
        fontSize: cellFontSize,
        minWidth: 80,
        maxWidth: 140,
      ),
      "CT": computeColumnWidth(
        header: "Description",
        values: rows.map((r) => r['CT'].toString()),
        fontSize: cellFontSize,
        minWidth: 180,
        maxWidth: 320,
      ),
      "PTRM": computeColumnWidth(
        header: "Course Duration",
        values: rows.map((r) => r['PTRM'].toString()),
        fontSize: cellFontSize,
        minWidth: 140,
        maxWidth: 220,
      ),
      "CH": computeColumnWidth(
        header: "Hours",
        values: rows.map((r) => r['CH'].toString()),
        fontSize: cellFontSize,
        minWidth: 70,
        maxWidth: 100,
      ),
      "D": computeColumnWidth(
        header: "Days",
        values: rows.map((r) => r['D'].toString()),
        fontSize: cellFontSize,
        minWidth: 80,
        maxWidth: 130,
      ),
      "TB": computeColumnWidth(
        header: "Start",
        values: rows.map((r) => r['TB'].toString()),
        fontSize: cellFontSize,
        minWidth: 90,
        maxWidth: 130,
      ),
      "TE": computeColumnWidth(
        header: "End",
        values: rows.map((r) => r['TE'].toString()),
        fontSize: cellFontSize,
        minWidth: 90,
        maxWidth: 130,
      ),
      "B": computeColumnWidth(
        header: "Building",
        values: rows.map((r) => r['B'].toString()),
        fontSize: cellFontSize,
        minWidth: 180,
        maxWidth: 280,
      ),
      "R": computeColumnWidth(
        header: "Room",
        values: rows.map((r) => r['R'].toString()),
        fontSize: cellFontSize,
        minWidth: 80,
        maxWidth: 120,
      ),
      "TN": computeColumnWidth(
        header: "Teacher(s)",
        values: rows.map((r) => r['TN'].toString()),
        fontSize: cellFontSize,
        minWidth: 160,
        maxWidth: 320,
      ),
      "E": computeColumnWidth(
        header: "Enrolled",
        values: rows.map((r) => r['E'].toString()),
        fontSize: cellFontSize,
        minWidth: 90,
        maxWidth: 120,
      ),
      "PTRMDS": computeColumnWidth(
        header: "Date Start",
        values: rows.map((r) => r['PTRMDS'].toString()),
        fontSize: cellFontSize,
        minWidth: 110,
        maxWidth: 150,
      ),
      "PTRMDE": computeColumnWidth(
        header: "Date End",
        values: rows.map((r) => r['PTRMDE'].toString()),
        fontSize: cellFontSize,
        minWidth: 110,
        maxWidth: 150,
      ),
      "INSMC": computeColumnWidth(
        header: "Method",
        values: rows.map((r) => r['INSMC'].toString()),
        fontSize: cellFontSize,
        minWidth: 100,
        maxWidth: 180,
      ),
      "AF": computeColumnWidth(
        header: "Added Fees",
        values: rows.map((r) => r['AF'].toString()),
        fontSize: cellFontSize,
        minWidth: 100,
        maxWidth: 160,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<Schedule>();
    final themeProvider = context.watch<AppTheme>();
    final rows = scheduleProvider.currentlySelectedCampusFilteredData;
    final cellFontSize = themeProvider.fontSizeXS;

    final nextCacheKey = _buildCacheKey(rows, themeProvider);
    if (_cacheKey != nextCacheKey) {
      _cachedWidths = _computeWidths(rows, themeProvider);
      _cacheKey = nextCacheKey;
    }

    final widthCRN = _cachedWidths["CRN"]!;
    final widthSC = _cachedWidths["SC"]!;
    final widthCN = _cachedWidths["CN"]!;
    final widthCT = _cachedWidths["CT"]!;
    final widthPTRM = _cachedWidths["PTRM"]!;
    final widthCH = _cachedWidths["CH"]!;
    final widthD = _cachedWidths["D"]!;
    final widthTB = _cachedWidths["TB"]!;
    final widthTE = _cachedWidths["TE"]!;
    final widthB = _cachedWidths["B"]!;
    final widthR = _cachedWidths["R"]!;
    final widthTN = _cachedWidths["TN"]!;
    final widthE = _cachedWidths["E"]!;
    final widthPTRMDS = _cachedWidths["PTRMDS"]!;
    final widthPTRMDE = _cachedWidths["PTRMDE"]!;
    final widthINSMC = _cachedWidths["INSMC"]!;
    final widthAF = _cachedWidths["AF"]!;

    return Center(
      child: DaviTheme(
        data: DaviThemeData(
          headerCell: HeaderCellThemeData(
            textStyle: TextStyle(
              color: themeProvider.text,
              fontSize: cellFontSize,
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
              fontSize: cellFontSize,
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
                width: widthCRN,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["CRN"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
                width: widthSC,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["SC"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
                width: widthCN,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["CN"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
                width: widthCT,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["CT"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
                // width: 330 + themeProvider.fontSizeXXS * 2,
              ),
              DaviColumn(
                sortable: true,
                name: "Course Duration",
                width: widthPTRM,
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
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
                width: widthCH,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["CH"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Days",
                width: widthD,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["D"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Start",
                width: widthTB,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["TB"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "End",
                width: widthTE,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["TE"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Building",
                width: widthB,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["B"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Room",
                width: widthR,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["R"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Teacher(s)",
                width: widthTN,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["TN"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Enrolled",
                width: widthE,
                cellBuilder: (context, row) {
                  final val =
                      "${(row.data as Map)["E"]} / ${(row.data as Map)["MS"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Date Start",
                width: widthPTRMDS,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["PTRMDS"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Date End",
                width: widthPTRMDE,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["PTRMDE"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Method",
                width: widthINSMC,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["INSMC"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              ),
              DaviColumn(
                name: "Added Fees",
                width: widthAF,
                cellBuilder: (context, row) {
                  final val = "${(row.data as Map)["AF"]}";
                  return Focus(
                    child: Semantics(
                      label: val,
                      excludeSemantics: true,
                      child: Text(
                        val,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
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
              color: Theme.of(context).colorScheme.surface,
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
