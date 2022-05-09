import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../common/common.dart';

class Directory extends ChangeNotifier {
  List<dynamic> _data = [];
  bool _isLoading = true;

  bool _hasError = false;
  String _errorMessage = "";

  String _searchString = "";

  String _selectedCampus = "";

  List<dynamic> get data => _data;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  String get searchString => _searchString;
  set searchString(String s) {
    _searchString = s;
    notifyListeners();
  }

  set selectedCampus(String s) {
    _selectedCampus = s;
    notifyListeners();
  }

  List<dynamic> get filteredData => _data
      .where((contact) => _selectedCampus.isNotEmpty
          ? contact["Campus"].toString().toLowerCase() ==
              _selectedCampus.toLowerCase()
          : true)
      .where((contact) => contact
          .toString()
          .toLowerCase()
          // .contains(RegExp("\\b$_searchString\\b", caseSensitive: false)))
          .contains(RegExp(_searchString, caseSensitive: false)))
      .toList();

  Future getDirectoryData() async {
    Map<String, dynamic> queryParameters = {};

    final _uri = Uri.https(
        jsonProviderBaseUri, jsonProviderDirectoryPath, queryParameters);

    _errorMessage = "";
    _hasError = false;
    _isLoading = true;
    notifyListeners();

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
            notifyListeners();
            _error(_checkError["message"].toString());
          }
        } else {
          // response.body is already a JSON formatted string
          // because of how the Python CGI page is coded.
          _data = jsonDecode(response.body) as List<dynamic>;
          if (_data.isEmpty) {
            _error("No data.");
          } else {
            _isLoading = false;
            notifyListeners();
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
                  trailing: Text(
                    row["C"]
                        .toString()
                        .replaceAll("LDCC", "")
                        .replaceAll("CAMPUS", "")
                        .toTitleCase()
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
}
