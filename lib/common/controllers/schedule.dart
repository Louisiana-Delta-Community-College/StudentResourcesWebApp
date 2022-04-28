import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import "../common.dart";

class Schedule extends ChangeNotifier {
  dynamic _data;
  bool _isLoading = true;

  bool _hasError = false;
  String _errorMessage = "";

  String term = "";
  String termType = "";
  String campus = "";
  String isStaff = "";

  get data => _data;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  String _baseUri = "web01.ladelta.edu";

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

    final _uri =
        Uri.https(_baseUri, "/bizzuka/scheduleJSON.py", queryParameters);

    print(_uri);

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
