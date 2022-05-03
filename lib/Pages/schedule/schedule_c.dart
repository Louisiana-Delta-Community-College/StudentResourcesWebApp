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
  String campus = "";
  String isStaff = "";

  List<dynamic> get data => _data;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  final String _baseUri = "web01.ladelta.edu";
  final String _baseUriScheduleDataPath = "/bizzuka/scheduleJSON.py";

  Future getScheduleData() async {
    Map<String, dynamic> queryParameters = {};

    if (term.isNotEmpty) {
      queryParameters["term"] = term;
    }

    if (termType.isNotEmpty) {
      queryParameters["termType"] = termType;
    }

    if (campus.isNotEmpty) {
      queryParameters["camp"] = campus;
    }

    final _uri = Uri.https(_baseUri, _baseUriScheduleDataPath, queryParameters);

    _errorMessage = "";
    _hasError = false;
    _isLoading = true;
    notifyListeners();

    final _scheduleCampusMenu = Modular.get<ScheduleCampusMenu>();

    try {
      final response = await http.get(_uri);
      if (response.statusCode == 200) {
        // response.body is already a JSON formatted string
        // because of how the Python CGI page is coded.
        _data = jsonDecode(response.body) as List<dynamic>;
        if (_data.isEmpty) {
          _error("No data.");
        } else {
          _scheduleCampusMenu.getMenuData();
          _isLoading = false;

          notifyListeners();
          // MAKE SURE THAT THE VISUALLY SELECTED TERM CODE IN THE BUTTON GROUP
          // IS THE CORRECT ONE FOR THE DATA JUST RETRIEVED.
          final _scheduleTermsMenuController = Modular.get<ScheduleTermsMenu>();
          final _retrievedTerm = _data[0]["T"];
          final _termsList = _scheduleTermsMenuController.termsList;
          if (_termsList.contains(_retrievedTerm)) {
            final _retrievedTermIndex = _termsList.indexOf(_retrievedTerm);
            _scheduleTermsMenuController.groupButtonTermMenuController
                .selectIndex(_retrievedTermIndex);
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
        _error(e.toString());
      }
    }
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
                  trailing:
                      Text(row["TN"].toString().replaceAll("<br/>", "; ")),
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
                  trailing: Text("${row["PTRMDS"]} / ${row["PTRMDE"]}"),
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
                  trailing: Text("${row["TB"]} - ${row["TE"]}"),
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
                  color: Theme.of(context).colorScheme.tertiary,
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

class ScheduleTermsMenu extends ChangeNotifier {
  dynamic _data;
  bool _isLoading = true;
  List _termsList = [];

  bool _hasError = false;
  String _errorMessage = "";

  final GroupButtonController _groupButtonTermMenuController =
      GroupButtonController();

  get data => _data;
  bool get isLoading => _isLoading;
  List get termsList => _termsList;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  GroupButtonController get groupButtonTermMenuController =>
      _groupButtonTermMenuController;

  final String _baseUri = "web01.ladelta.edu";
  final String _baseUriMenuPath = "/bizzuka/scheduleSideMenuJSON.py";

  Future getMenuData() async {
    Map<String, dynamic> queryParameters = {};

    final _uri = Uri.https(_baseUri, _baseUriMenuPath, queryParameters);

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
            for (final item in _data) item["Term"].toString(),
          ];
          notifyListeners();
        }
      } else {
        throw HttpException("${response.statusCode}");
      }
    } on HttpException {
      _error("Unable to reach the server (bad URL?).");
    } catch (e) {
      if (e.toString() == "XMLHttpRequest error.") {
        _error("Unable to reach the server (bad URL?).");
      } else {
        _error(e.toString());
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

  bool _hasError = false;
  String _errorMessage = "";

  final GroupButtonController _groupButtonCampusMenuController =
      GroupButtonController();

  get data => _data;
  bool get isLoading => _isLoading;
  List get campusList => _campusList;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  GroupButtonController get groupButtonCampusMenuController =>
      _groupButtonCampusMenuController;

  Future getMenuData() async {
    _isLoading = true;
    notifyListeners();

    if (_campusList.isEmpty) {
      final _scheduleData = Modular.get<Schedule>().data;

      for (var element in _scheduleData) {
        _campusList.add(element["C"]);
      }

      // FILTER OUT ALL BUT UNIQUE BY USING SET
      _campusList = _campusList.toSet().toList();
    }

    _isLoading = false;
    notifyListeners();

    log.info(_campusList.toString());
  }

  // _error(String message) {
  //   _isLoading = false;
  //   _hasError = true;
  //   _errorMessage = message;
  //   notifyListeners();
  // }
}
