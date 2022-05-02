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

    try {
      final response = await http.get(_uri);
      if (response.statusCode == 200) {
        // response.body is already a JSON formatted string
        // because of how the Python CGI page is coded.
        _data = jsonDecode(response.body) as List<dynamic>;
        if (_data.isEmpty) {
          _error("No data.");
        } else {
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

  Future generateMenuFromCampusesInScheduleData() async {
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
