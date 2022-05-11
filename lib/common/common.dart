import 'dart:io' show Platform;
import 'package:flutter/material.dart';

import 'package:talker/talker.dart';

export 'package:flutter/material.dart';

export 'package:flutter_modular/flutter_modular.dart';
export 'package:flutter_animator/flutter_animator.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:easy_search_bar/easy_search_bar.dart';
export 'package:get_storage/get_storage.dart' show GetStorage;
export 'package:html/parser.dart' show parse;
export 'package:recase/recase.dart';
export 'package:skeletons/skeletons.dart';
export 'package:clipboard/clipboard.dart';

export 'package:schedule/config.dart';
export 'package:schedule/Pages/pages.dart';
export 'package:schedule/common/controllers/counter.dart';
export 'package:schedule/common/controllers/app_title.dart';
export 'package:schedule/common/controllers/persistence.dart';
export 'package:schedule/common/controllers/theme.dart';

export 'package:schedule/Pages/schedule/schedule_c.dart';
export 'package:schedule/Pages/directory/directory_c.dart';

final log = Talker();
// final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

bool get isMobile {
  bool _isMobile = false;

  if (Platform.isAndroid || Platform.isIOS) {
    _isMobile = true;
  }

  return _isMobile;
}

double viewPortWidth(context) {
  double _viewPortWidth = double.infinity;
  _viewPortWidth = MediaQuery.of(context).size.width;
  return _viewPortWidth;
}

bool isSmallFormFactor(context) {
  var _isSmallFormFactor = false;
  final _viewPortWidth = viewPortWidth(context);
  _isSmallFormFactor = _viewPortWidth <= 800;
  return _isSmallFormFactor;
}
