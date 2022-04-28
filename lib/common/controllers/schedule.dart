import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import "../common.dart";

class Schedule extends ChangeNotifier {
  dynamic _data;
  bool _isLoading = true;

  get data => _data;
  get isLoading => _isLoading;

  Future getScheduleData() async {
    _isLoading = true;
    notifyListeners();
    final response = await http
        .get(Uri.parse('https://web01.ladelta.edu/bizzuka/scheduleJSON.py'));
    if (response.statusCode == 200) {
      _data = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();
      // print(_data);
    } else {
      // on failure, throw an exception
      throw Exception('Failed to load json');
    }
  }
}
