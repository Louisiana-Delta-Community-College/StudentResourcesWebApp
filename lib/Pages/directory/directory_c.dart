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

  final FocusNode _focusNode = FocusNode();
  final ScrollController _vScrollController = ScrollController();
  final ScrollController _hScrollController = ScrollController();

  FocusNode get focusNode => _focusNode;
  ScrollController get vScrollController => _vScrollController;
  ScrollController get hScrollController => _hScrollController;

  void handleKeyEvent(RawKeyEvent event) async {
    // log.info(event.toString());
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _vScrollController.animateTo(_vScrollController.offset - 200,
          duration: const Duration(milliseconds: 10), curve: Curves.ease);
      // log.info("up");
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _vScrollController.animateTo(_vScrollController.offset + 200,
          duration: const Duration(milliseconds: 10), curve: Curves.ease);
      // log.info("down");
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _hScrollController.animateTo(_hScrollController.offset - 50,
          duration: const Duration(milliseconds: 10), curve: Curves.ease);
      // log.info("left");
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _hScrollController.animateTo(_hScrollController.offset + 50,
          duration: const Duration(milliseconds: 10), curve: Curves.ease);
      // log.info("right");
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _vScrollController.animateTo(_vScrollController.offset - 1000,
          duration: const Duration(milliseconds: 10), curve: Curves.ease);
      // log.info("up");
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _vScrollController.animateTo(_vScrollController.offset + 1000,
          duration: const Duration(milliseconds: 10), curve: Curves.ease);
      // log.info("down");
    }
  }

  void toggleFocus() {
    var _focusable = _focusNode.descendantsAreFocusable;
    if (_focusable == true) {
      _focusable = false;
    } else {
      _focusable = true;
    }
    notifyListeners();
  }

  void init() {
    toggleFocus();
  }

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
          // log.info(_data.runtimeType.toString());
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
}
