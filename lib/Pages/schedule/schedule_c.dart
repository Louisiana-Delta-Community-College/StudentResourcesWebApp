import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:group_button/group_button.dart';

import '../../common/common.dart';

class Schedule extends ChangeNotifier {
  List<dynamic> _data = [];
  bool _isLoading = true;

  bool _hasError = false;
  String _errorMessage = "";

  String term = "";
  String termType = "";
  String _campus = "MONROE CAMPUS";
  String isStaff = "";

  String _searchString = "";

  List<dynamic> get data => _data;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get campus => _campus;

  String get searchString => _searchString;
  set searchString(String s) {
    // LIGHTLY SANITIZE AND SET SEARCH STRING
    _searchString = s.replaceAll("(", "\\(").replaceAll(")", "\\)");
    notifyListeners();
  }

  List<dynamic> get filteredData => _data
      .where((course) => course["C"] == _campus)
      .where((course) => course
          .toString()
          .toLowerCase()
          // .contains(RegExp("\\b$_searchString\\b", caseSensitive: false)))
          .contains(RegExp(_searchString, caseSensitive: false)))
      .toList();

  set campus(String c) {
    _campus = c;
    updateCampusMenuSelection();
    notifyListeners();
  }

  Future getScheduleData() async {
    Map<String, dynamic> queryParameters = {};

    if (term.isNotEmpty) {
      queryParameters["term"] = term;
    }

    if (termType.isNotEmpty) {
      queryParameters["termty"] = termType;
    }

    // if (campus.isNotEmpty) {
    //   queryParameters["camp"] = campus;
    // }

    final _uri = Uri.https(
        jsonProviderBaseUri, jsonProviderSchedulePath, queryParameters);

    _errorMessage = "";
    _hasError = false;
    _isLoading = true;
    notifyListeners();

    final _scheduleCampusMenu = Modular.get<ScheduleCampusMenu>();

    try {
      final response = await http.get(_uri);
      if (response.statusCode == 200) {
        // final _responseTest =
        //     '{"success": false, "message": "Error connecting to the database."}';
        if (response.body.length < 200) {
          final _checkError = jsonDecode(response.body) as Map<String, dynamic>;
          if (_checkError.containsKey("success") &&
              _checkError["success"] == false) {
            _isLoading = false;
            _scheduleCampusMenu.isLoading = false;
            _scheduleCampusMenu._campusList = ["None"];
            notifyListeners();
            _error(_checkError["message"].toString());
          }
        } else {
          // response.body is already a JSON formatted string
          // because of how the Python CGI page is coded.
          _data = jsonDecode(response.body) as List<dynamic>;
          // log.info(_data.runtimeType.toString());
          if (_data.isEmpty) {
            _error("No data.");
          } else {
            _scheduleCampusMenu.getMenuData();
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
          log.info(_data.runtimeType.toString());
        } catch (e) {
          _error(e.toString());
        }
      }
    }
  }

  void updateTermsMenuSelection() {
    final _scheduleTermsMenuController = Modular.get<ScheduleTermsMenu>();
    final _retrievedTerm = _data[0]["TD"];
    var _selectedTermDesc = _scheduleTermsMenuController.selectedTermDesc;
    if (_selectedTermDesc.isEmpty) {
      _selectedTermDesc = _scheduleTermsMenuController.data
          .where((e) => e["Desc"] == _retrievedTerm)
          .toList()[0]["Desc"];
    }
    // log.info(_selectedTermDesc);
    final _termsList = _scheduleTermsMenuController.termsList;
    if (_termsList.contains(_selectedTermDesc)) {
      final _retrievedTermIndex = _termsList.indexOf(_selectedTermDesc);
      _scheduleTermsMenuController.groupButtonTermMenuController
          .selectIndex(_retrievedTermIndex);
    }
  }

  void updateCampusMenuSelection() {
    int _termIndex = 0;
    final _scheduleCampusMenuController = Modular.get<ScheduleCampusMenu>();
    final _selectedCampus = _campus;
    final _campusList = _scheduleCampusMenuController.campusList;
    if (_campusList.contains(_selectedCampus)) {
      _termIndex = _campusList.indexOf(_selectedCampus);
    } else {
      _campus = _campusList[0];
      _termIndex = 0;
    }
    _scheduleCampusMenuController.groupButtonCampusMenuController
        .selectIndex(_termIndex);
  }

  _error(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  Future<dynamic> showMoreInfoDialog(BuildContext context, Object? row) {
    return showDialog(
      context: context,
      builder: (context) {
        final feesFlat = (row as Map)["FF"];
        final feesCredit = row["FC"];
        var feesTotal = "0.00";
        try {
          feesTotal = ((double.tryParse(feesFlat) ?? 0.00) +
                  (double.tryParse(feesCredit) ?? 0.00))
              .toStringAsFixed(2);
        } catch (e) {
          log.error(e.toString());
        }
        return AlertDialog(
          title: Text("${row["CT"]} - ${row["SC"]} ${row["CN"]}"),
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
            height: MediaQuery.of(context).size.height * .80,
            width: MediaQuery.of(context).size.width * .80,
            child: ListView(
              shrinkWrap: true,
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
                          overlayColor: MaterialStateProperty.all(
                              AppColor.bronze2.withOpacity(.5)),
                          foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.tertiary,
                          ),
                          side: MaterialStateProperty.all(
                            BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => copyRowToClipboard(row),
                        icon: const Icon(Icons.copy_all_sharp),
                        label: const Text("Copy to Clipboard"),
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                              AppColor.bronze2.withOpacity(.5)),
                          foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.tertiary,
                          ),
                          side: MaterialStateProperty.all(
                            BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const ListTile(
                  dense: true,
                  leading: Text(
                    "Course Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "CRN:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText(
                    row["CRN"].toString().trim(),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Campus:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText(
                    row["C"]
                        .toString()
                        .replaceAll("LDCC", "")
                        .replaceAll("CAMPUS", "")
                        .titleCase
                        .trim(),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Teacher(s):",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText(row["TN"].toString()),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Enrolled:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText("${row["E"]} / ${row["MS"]}"),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Building:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText(row["B"].toString()),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Room:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText(row["R"].toString()),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Dates in Session:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing:
                      SelectableText("${row["PTRMDS"]} / ${row["PTRMDE"]}"),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Days:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText(row["D"].toString()),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Time:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText("${row["TB"]} - ${row["TE"]}"),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Credit Hours:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText(row["CH"].toString()),
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
                  trailing: SelectableText("${(row)["FF"]}"),
                ),
                ListTile(
                  dense: true,
                  leading: const Text(
                    "Credit:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: SelectableText("${row["FC"]}"),
                ),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                ListTile(
                  dense: true,
                  // leading: const SelectableText(
                  //   "Credit:",
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  trailing: SelectableText(feesTotal),
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
                  title: SelectableText(
                    row["N"].toString().trim() != ""
                        ? parse(row["N"].toString())
                            .body!
                            .text
                            // .toString()
                            .replaceAll("<br/>", "\n")
                        // .replaceAll("&lt;", "")
                        // .replaceAll("&gt;", "")
                        // .replaceAll("br/", "")
                        : "No description.",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  void copyRowToClipboard(row) {
    final _feesFlat = (row as Map)["FF"];
    final _feesCredit = row["FC"];
    var _feesTotal = "0.00";
    try {
      _feesTotal = ((double.tryParse(_feesFlat) ?? 0.00) +
              (double.tryParse(_feesCredit) ?? 0.00))
          .toStringAsFixed(2);
    } catch (e) {
      log.error(e.toString());
    }
    FlutterClipboard.copy("""
Course: ${row["SC"]} ${row["CN"]}
Title: ${row["CT"]}
CRN: ${row["CRN"]}
Campus: ${row["C"]}
Teacher(s): ${row["TN"]}
Enrolled: ${row["E"]} / ${row["MS"]} 
Building: ${row["B"]}
Room: ${row["R"]}
Dates in Session: ${row["PTRMDS"]} / ${row["PTRMDE"]}
Days: ${row["D"]}
Time: ${row["TB"]} - ${row["TE"]}
Credit Hours: ${row["CH"]}

Additional Fees:
Flat: $_feesFlat
Credit: $_feesCredit
Total: $_feesTotal

Description:
${row["N"]}
"""
        .trim());
  }
}

class ScheduleTermsMenu extends ChangeNotifier {
  List<dynamic> _data = [];
  bool _isLoading = true;
  List _termsList = [];

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
    Map<String, dynamic> queryParameters = {};

    final _uri = Uri.https(
        jsonProviderBaseUri, jsonProviderTermMenuPath, queryParameters);

    _errorMessage = "";
    _hasError = false;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(_uri);
      if (response.statusCode == 200) {
        // response.body is already a JSON formatted string
        // because of how the Python CGI page is coded.
        _data = jsonDecode(response.body);
        if (_data.toString() == "[]") {
          _error("No data.");
        } else {
          _isLoading = false;
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

    // if (_campusList.isEmpty) {
    _campusList = [];
    final _scheduleData = Modular.get<Schedule>().data;

    for (var element in _scheduleData) {
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

    // log.info(_campusList.toString());
  }

  // _error(String message) {
  //   _isLoading = false;
  //   _hasError = true;
  //   _errorMessage = message;
  //   notifyListeners();
  // }
}
