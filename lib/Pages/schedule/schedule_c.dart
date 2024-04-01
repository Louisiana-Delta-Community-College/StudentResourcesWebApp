import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:group_button/group_button.dart';
import 'package:davi/davi.dart';

import '../../common/common.dart';

class Schedule extends ChangeNotifier {
  List<dynamic> _data = [];
  bool _isLoading = true;

  bool _hasError = false;
  String _errorMessage = "";

  List _matchCounts = [];

  String _term = "";
  String _termType = "";
  bool _fetchCurrent = false;
  String _campus = "MONROE CAMPUS";
  String isStaff = "";

  bool get fetchCurrent => _fetchCurrent;
  set fetchCurrent(bool v) {
    _fetchCurrent = v;
    notifyListeners();
  }

  String get term => _term;
  String get termType => _termType;

  set term(String s) {
    _term = s;
    notifyListeners();
  }

  set termType(String s) {
    _termType = s;
    notifyListeners();
  }

  String _searchString = "";

  List<dynamic> get data => _data;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get campus => _campus;
  List get matchCounts => _matchCounts;

  String get searchString => _searchString;
  set searchString(String s) {
    // LIGHTLY SANITIZE AND SET SEARCH STRING
    _searchString = s
        .replaceAll("(", "\\(")
        .replaceAll(")", "\\)")
        .replaceAll(RegExp(r'\s+'), ".+");
    notifyListeners();
  }

  void updateMatchCounts() {
    final List campus = Modular.get<ScheduleCampusMenu>()._campusList;
    _matchCounts = campus.map(((e) {
      if (searchString.isNotEmpty) {
        return filteredData.where((course) => course["C"] == e).toList().length;
      } else {
        return 0;
      }
    })).toList();
    notifyListeners();
  }

  // List<dynamic> get filteredData => _data
  //     .where((course) => course["C"] == _campus)
  //     .where((course) => course
  //         .toString()
  //         .toLowerCase()
  //         // .contains(RegExp("\\b$_searchString\\b", caseSensitive: false)))
  //         .contains(RegExp(_searchString, caseSensitive: false)))
  //     .toList();

  List<dynamic> get filteredData {
    return _data
        .where((course) =>
            (course as Map)
                .values
                .toList()
                .toString()
                .toLowerCase()
                // .contains(RegExp("\\b$_searchString\\b", caseSensitive: false)))
                .contains(RegExp(_searchString, caseSensitive: false)) ||
            course.values
                .toList()
                .reversed
                .toList()
                .toString()
                .toLowerCase()
                // .contains(RegExp("\\b$_searchString\\b", caseSensitive: false)))
                .contains(RegExp(_searchString, caseSensitive: false)))
        .toList();
  }

  List<dynamic> get currentlySelectedCampusFilteredData {
    return filteredData.where((course) => course["C"] == _campus).toList();
  }

  set campus(String c) {
    _campus = c;
    updateCampusMenuSelection();
    notifyListeners();
  }

  Future getScheduleData() async {
    Map<String, dynamic> queryParameters = {};

    if (_term.isNotEmpty) {
      queryParameters["term"] = _term;
    }

    if (_termType.isNotEmpty) {
      queryParameters["termty"] = _termType;
    }

    if (_fetchCurrent) {
      queryParameters["fetchCurrent"] = _fetchCurrent.toString();
    }

    // log.d(queryParameters);

    final uri = Uri.https(
        jsonProviderBaseUri, jsonProviderSchedulePath, queryParameters);

    _errorMessage = "";
    _hasError = false;
    _isLoading = true;
    notifyListeners();

    final scheduleCampusMenu = Modular.get<ScheduleCampusMenu>();

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // final _responseTest =
        //     '{"success": false, "message": "Error connecting to the database."}';
        if (response.body.length < 200) {
          final checkError = jsonDecode(response.body) as Map<String, dynamic>;
          if (checkError.containsKey("success") &&
              checkError["success"] == false) {
            _isLoading = false;
            scheduleCampusMenu.isLoading = false;
            scheduleCampusMenu._campusList = ["None"];
            notifyListeners();
            _error(checkError["message"].toString());
          }
        } else {
          // response.body is already a JSON formatted string
          // because of how the Python CGI page is coded.
          _data = jsonDecode(response.body) as List<dynamic>;
          if (_data.isEmpty) {
            _error("No data.");
          } else {
            scheduleCampusMenu.getMenuData();
            _isLoading = false;

            notifyListeners();
            // MAKE SURE THAT THE VISUALLY SELECTED TERM CODE IN THE BUTTON GROUP
            // IS THE CORRECT ONE FOR THE DATA JUST RETRIEVED.
            updateTermsMenuSelection();
            // SAME FOR THE CAMPUS MENU
            updateCampusMenuSelection();
          }
        }
      } else {
        throw HttpException("${response.statusCode}");
      }
    } on HttpException {
      _error("Unable to reach the server (bad URL?).");
    } catch (e) {
      if (e.toString() == "XMLHttpRequest error.") {
        _error("Unable to reach the server (bad URL?).");
      } else if (e.toString() ==
          "Expected a value of type 'List<dynamic>', but got one of type '_JsonMap'") {
        _error("Error connecting to database.");
      } else {
        try {
          // _data = jsonDecode(response.body) as List<dynamic>;
          // _data = [
          //   jsonDecode(
          //       '{"success": false, "message": "Error connecting to the database."}')
          // ] as List<Map<String, dynamic>>;
        } catch (e) {
          _error(e.toString());
        }
      }
    }
  }

  void updateTermsMenuSelection() {
    final scheduleTermsMenuController = Modular.get<ScheduleTermsMenu>();
    final retrievedTerm = _data[0]["TD"];
    var selectedTermDesc = scheduleTermsMenuController.selectedTermDesc;
    if (selectedTermDesc.isEmpty) {
      selectedTermDesc = scheduleTermsMenuController.data
          .where((e) => e["Desc"] == retrievedTerm)
          .toList()[0]["Desc"];
    }
    final termsList = scheduleTermsMenuController.termsList;
    if (termsList.contains(selectedTermDesc)) {
      final retrievedTermIndex = termsList.indexOf(selectedTermDesc);
      scheduleTermsMenuController.groupButtonTermMenuController
          .selectIndex(retrievedTermIndex);
    }
  }

  void updateCampusMenuSelection() {
    int termIndex = 0;
    final scheduleCampusMenuController = Modular.get<ScheduleCampusMenu>();
    final selectedCampus = _campus;
    final campusList = scheduleCampusMenuController.campusList;
    if (campusList.contains(selectedCampus)) {
      termIndex = campusList.indexOf(selectedCampus);
    } else {
      _campus = campusList[0];
      termIndex = 0;
    }
    scheduleCampusMenuController.groupButtonCampusMenuController
        .selectIndex(termIndex);
  }

  _error(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  Future<dynamic> showMoreInfoDialog(BuildContext context, row) {
    final ScrollController scrollController = ScrollController();

    return showDialog(
      context: context,
      builder: (context) {
        Map rowData = {};
        final themeProvider = context.watch<AppTheme>();
        if (row.runtimeType == DaviRow) {
          rowData = (row.data as Map);
        } else {
          rowData = row;
        }
        final feesFlat = rowData["FF"];
        final feesCredit = rowData["FC"];
        var feesTotal = "0.00";
        try {
          feesTotal = ((double.tryParse(feesFlat) ?? 0.00) +
                  (double.tryParse(feesCredit) ?? 0.00))
              .toStringAsFixed(2);
        } catch (e) {
          log.e(e.toString());
        }
        return AlertDialog(
          title: Text(
            "${rowData["SC"]} ${rowData["CN"]} - ${rowData["CT"]}",
            style: TextStyle(color: themeProvider.text),
          ),
          alignment: Alignment.center,
          backgroundColor: themeProvider.bodyBackground,
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  themeProvider.text,
                ),
                foregroundColor: MaterialStateProperty.all(
                  themeProvider.bodyBackground,
                ),
              ),
              onPressed: () {
                Modular.to.pop();
              },
              child: const Text("Close"),
            ),
          ],
          content: SizedBox(
            height: MediaQuery.of(context).size.height * .80,
            width: MediaQuery.of(context).size.width * .80,
            child: Scrollbar(
              controller: scrollController,
              // isAlwaysShown: true,
              thumbVisibility: true,
              child: ListView(
                shrinkWrap: true,
                controller: scrollController,
                children: [
                  // BUY MATERIALS BUTTON
                  ListTile(
                    dense: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () => launchBookStore(row),
                          icon: const Icon(Icons.menu_book_sharp),
                          label: const Text("Buy Materials"),
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(themeProvider.text),
                            foregroundColor: MaterialStateProperty.all(
                              themeProvider.text,
                            ),
                            side: MaterialStateProperty.all(
                              BorderSide(
                                width: 1,
                                color: themeProvider.text,
                              ),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            copyRowToClipboard(row);
                            showSnackBar(
                              "Course information copied to clipboard!",
                              isSuccess: true,
                            );
                          },
                          icon: const Icon(Icons.copy_all_sharp),
                          label: const Text("Copy Course Info"),
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(themeProvider.text),
                            foregroundColor:
                                MaterialStateProperty.all(themeProvider.text),
                            side: MaterialStateProperty.all(
                              BorderSide(
                                width: 1,
                                color: themeProvider.text,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Course Details",
                          style: TextStyle(
                            color: themeProvider.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InfoRow("CRN:", rowData["CRN"].toString().trim()),
                  InfoRow(
                      "Campus:",
                      rowData["C"]
                          .toString()
                          .replaceAll("LDCC", "")
                          .replaceAll("CAMPUS", "")
                          .titleCase
                          .trim()),
                  InfoRow("Teacher(s):", rowData["TN"].toString()),
                  InfoRow("Enrolled:", "${rowData["E"]} / ${rowData["MS"]}"),
                  InfoRow("Building:", rowData["B"].toString()),
                  InfoRow("Room:", rowData["R"].toString()),
                  InfoRow("Dates in Session:",
                      "${rowData["PTRMDS"]} / ${rowData["PTRMDE"]}"),
                  InfoRow("Days:", rowData["D"].toString()),
                  InfoRow("Time:", "${rowData["TB"]} - ${rowData["TE"]}"),
                  InfoRow("Credit Hours:", rowData["CH"].toString()),
                  // ADDITIONAL FEES
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Additional Fees",
                          style: TextStyle(
                            color: themeProvider.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InfoRow("Flat:",
                      "${(rowData)["FF"] == "" ? "0.00" : (rowData)["FF"]}"),
                  InfoRow("Credit:",
                      "${(rowData)["FC"] == "" ? "0.00" : (rowData)["FC"]}"),
                  Divider(
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: themeProvider.text,
                  ),
                  InfoRow("", feesTotal),
                  // DESCRIPTION
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Description",
                          style: TextStyle(
                            color: themeProvider.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: SelectableText(
                      rowData["N"].toString().trim() != ""
                          ? parse(rowData["N"].toString())
                              .body!
                              .text
                              .replaceAll("<br/>", "\n")
                          : "No description.",
                      style: TextStyle(
                        color: themeProvider.text,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void launchBookStore(row) {
    Uri bookStoreURI;
    const bookStoreHost = "ladelta.bncollege.com";
    const bookStorePath = "/webapp/wcs/stores/servlet/TBListView";
    var courseXML = "";
    Map rowData = {};
    if (row.runtimeType == DaviRow) {
      rowData = (row?.data as Map);
    } else {
      rowData = row;
    }
    if (rowData["C"] == "MONROE CAMPUS") {
      courseXML =
          '<?xml version="1.0" encoding="UTF-8"?><textbookorder><campus name="MONROE"><courses><course dept="${rowData["SC"]}" num="${rowData["CN"]}" sect="${rowData["CRN"]}" term="${rowData["T"]}"/></courses></campus></textbookorder>';
    } else {
      courseXML =
          '<?xml version="1.0" encoding="UTF-8"?><textbookorder><campus name="OTHER"><courses><course dept="${rowData["SC"]}" num="${rowData["CN"]}" sect="${rowData["CRN"]}" term="${rowData["T"]}"/></courses></campus></textbookorder>';
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

  void copyRowToClipboard(row) {
    Map rowData = {};
    if (row.runtimeType == DaviRow) {
      rowData = (row.data as Map);
    } else {
      rowData = row;
    }
    final feesFlat = rowData["FF"];
    final feesCredit = rowData["FC"];
    var feesTotal = "0.00";
    try {
      feesTotal = ((double.tryParse(feesFlat) ?? 0.00) +
              (double.tryParse(feesCredit) ?? 0.00))
          .toStringAsFixed(2);
    } catch (e) {
      log.e(e.toString());
    }
    FlutterClipboard.copy("""
Course: ${rowData["SC"]} ${rowData["CN"]}
Title: ${rowData["CT"]}
CRN: ${rowData["CRN"]}
Campus: ${rowData["C"]}
Teacher(s): ${rowData["TN"]}
Enrolled: ${rowData["E"]} / ${rowData["MS"]} 
Building: ${rowData["B"]}
Room: ${rowData["R"]}
Dates in Session: ${rowData["PTRMDS"]} / ${rowData["PTRMDE"]}
Days: ${rowData["D"]}
Time: ${rowData["TB"]} - ${rowData["TE"]}
Credit Hours: ${rowData["CH"]}

Additional Fees:
Flat: $feesFlat
Credit: $feesCredit
Total: $feesTotal

Description:
${rowData["N"]}
"""
        .trim());
  }
}

class ScheduleTermsMenu extends ChangeNotifier {
  List<dynamic> _data = [];
  bool _isLoading = true;
  List _termsList = [];

  Map<String, dynamic> _passedInTerm = {};
  Map<String, dynamic> get passedInTerm => _passedInTerm;
  set passedInTerm(Map<String, dynamic> p) {
    _passedInTerm = p;
    notifyListeners();
  }

  String _selectedTermDesc = "";

  bool _hasError = false;
  String _errorMessage = "";

  final GroupButtonController _groupButtonTermMenuController =
      GroupButtonController();

  List<dynamic> get data => _data;
  bool get isLoading => _isLoading;
  List get termsList => _termsList;
  bool get hasError => _hasError;
  String get selectedTermDesc => _selectedTermDesc;
  String get errorMessage => _errorMessage;
  GroupButtonController get groupButtonTermMenuController =>
      _groupButtonTermMenuController;

  set selectedTermDesc(String s) {
    _selectedTermDesc = s;
    notifyListeners();
  }

  Future getMenuData() async {
    final rng = Random().nextInt(9999999).toString();
    Map<String, dynamic> queryParameters = {"v": rng};

    final uri = Uri.https(
        jsonProviderBaseUri, jsonProviderTermMenuPath, queryParameters);

    _errorMessage = "";
    _hasError = false;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // response.body is already a JSON formatted string
        // because of how the Python CGI page is coded.
        _data = jsonDecode(response.body);
        if (_data.toString() == "[]") {
          _error("No data.");
        } else {
          _isLoading = false;
          if (passedInTerm.isNotEmpty) {
            _data.removeWhere((element) =>
                element["Term"] == passedInTerm["Term"] &&
                element["TermTy"] == passedInTerm["TermTy"]);
            for (final item in _data) {
              item["default"] = false;
            }
            _data.add(passedInTerm);
            selectedTermDesc = passedInTerm["Desc"];
          }
          _data.sort(
              (a, b) => int.parse(a["Term"]).compareTo(int.parse(b["Term"])));
          _termsList = [
            for (final item in _data) item["Desc"].toString(),
          ];

          notifyListeners();
        }
      } else {
        throw HttpException("${response.statusCode}");
      }
    } on HttpException {
      _error("Unable to connect to LCTCS server.");
    } catch (e) {
      if (e.toString() == "XMLHttpRequest error.") {
        _error("Unable to connect to LCTCS server.");
      } else {
        _error("Resource temporarily offline.\nPlease try again later.");
        // _error(e.toString());
      }
    }
  }

  _error(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }
}

class ScheduleCampusMenu extends ChangeNotifier {
  dynamic _data;
  bool _isLoading = true;
  List _campusList = [];

  final bool _hasError = false;
  final String _errorMessage = "";

  final GroupButtonController _groupButtonCampusMenuController =
      GroupButtonController();

  get data => _data;
  bool get isLoading => _isLoading;
  List get campusList => _campusList;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  GroupButtonController get groupButtonCampusMenuController =>
      _groupButtonCampusMenuController;

  set isLoading(bool s) {
    _isLoading = s;
    notifyListeners();
  }

  Future getMenuData() async {
    _isLoading = true;
    notifyListeners();

    _campusList = [];
    final scheduleData = Modular.get<Schedule>().data;

    for (var element in scheduleData) {
      _campusList.add(element["C"]);
    }

    // FILTER OUT ALL BUT UNIQUE BY USING SET
    _campusList = _campusList.toSet().toList();

    // SORT THE LIST
    _campusList.sort((a, b) => a.compareTo(b));

    // BUT MAKE SURE THAT "MONROE CAMPUS" IS ALWAYS FIRST IF IT IS IN THE LIST
    if (_campusList.contains("MONROE CAMPUS")) {
      _campusList.remove("MONROE CAMPUS");
      _campusList.insert(0, "MONROE CAMPUS");
    }
    // }

    _isLoading = false;
    notifyListeners();
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.name, this.value, {Key? key}) : super(key: key);

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: themeProvider.text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SelectableText(
            value,
            style: TextStyle(
              color: themeProvider.text,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
