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
    // LIGHTLY SANITIZE AND SET SEARCH STRING
    _searchString = s
        .replaceAll("(", "\\(")
        .replaceAll(")", "\\)")
        .replaceAll(RegExp(r'\s+'), ".+");
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
      .where((contact) =>
          (contact as Map)
              .values
              .toList()
              .toString()
              .toLowerCase()
              // .contains(RegExp("\\b$_searchString\\b", caseSensitive: false)))
              .contains(RegExp(_searchString, caseSensitive: false)) ||
          contact.values
              .toList()
              .reversed
              .toList()
              .toString()
              .toLowerCase()
              // .contains(RegExp("\\b$_searchString\\b", caseSensitive: false)))
              .contains(RegExp(_searchString, caseSensitive: false)))
      .toList();

  Future getDirectoryData() async {
    Map<String, dynamic> queryParameters = {};

    final uri = Uri.https(
        jsonProviderBaseUri, jsonProviderDirectoryPath, queryParameters);

    _errorMessage = "";
    _hasError = false;
    _isLoading = true;
    notifyListeners();

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
            // CLEAN UP THE STRINGS
            for (var element in _data) {
              cleanTitleString(element, "JobTitle");
              cleanTitleString(element, "Department");
            }
            _isLoading = false;
            notifyListeners();
          }
        }
      } else {
        throw HttpException("${response.statusCode}");
      }
    } on HttpException {
      _error("Unable to connect to LCTCS server.");
    } catch (e) {
      if (e.toString() == "XMLHttpRequest error.") {
        _error("Unable to connect to LCTCS server.");
      } else if (e.toString() ==
          "Expected a value of type 'List<dynamic>', but got one of type '_JsonMap'") {
        _error("Resource temporarily offline.\nPlease try again later.");
      } else {
        try {
          // _data = jsonDecode(response.body) as List<dynamic>;
          // _data = [
          //   jsonDecode(
          //       '{"success": false, "message": "Error connecting to the database."}')
          // ] as List<Map<String, dynamic>>;
        } catch (e) {
          _error("Resource temporarily offline.\nPlease try again later.");
          // _error(e.toString());
        }
      }
    }
  }

  void cleanTitleString(element, String key) {
    if ((element as Map).containsKey(key)) {
      element[key] = element[key]
          .toString()
          .titleCase
          .replaceAll("I T", "IT")
          .replaceAll("( ", "(")
          .replaceAll(" )", ")");
    }
  }

  _error(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  directoryTableStringSorter(Object? a, Object? b, String field) {
    String? v1 = (a as Map)[field].toString();
    String? v2 = (b as Map)[field].toString();
    if (v1.isEmpty && v2.isEmpty) {
      return 0;
    }
    if (v1.isEmpty) {
      return -1;
    }
    if (v2.isEmpty) {
      return 1;
    }
    return v1.compareTo(v2);
  }

  void copyRowToClipboard(row) {
    // log.d(row);
    final rowData = (row.data as Map);
    final office = rowData["Office"].toString().replaceAll("Rm", "").trim();
    FlutterClipboard.copy("""
${rowData["FirstName"]} ${rowData["LastName"]}
${rowData["JobTitle"]}
${rowData["Department"]}

${rowData["PhoneNumber"]}
${rowData["EmailAddress"]}
${rowData["Campus"]} Campus
Room $office
"""
        .trim());
  }
}
