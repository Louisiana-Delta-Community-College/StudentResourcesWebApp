import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:schedule/config.dart';

import 'package:talker/talker.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

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
export 'package:flutter_styled_toast/flutter_styled_toast.dart';

export 'package:schedule/config.dart';
export 'package:schedule/Pages/pages.dart';
export 'package:schedule/common/controllers/counter.dart';
export 'package:schedule/common/controllers/app_title.dart';
export 'package:schedule/common/controllers/persistence.dart';
export 'package:schedule/common/controllers/theme.dart';

export 'package:schedule/Pages/schedule/schedule_c.dart';
export 'package:schedule/Pages/directory/directory_c.dart';

late BuildContext globalContext;

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

void makeToast(String message) {
  showToast(
    message,
    duration: const Duration(seconds: 5),
    animation: StyledToastAnimation.fade,
    reverseAnimation: StyledToastAnimation.fade,
    alignment: Alignment.center,
    position: StyledToastPosition.bottom,
    backgroundColor: AppColor.navy.withOpacity(.8),
    textStyle: const TextStyle(
      color: AppColor.white,
    ),
  );
}

void showSnackBar(
  String message, {
  dynamic isSuccess,
}) {
  Widget? iconWidget;
  if (isSuccess is bool && isSuccess) {
    iconWidget = Icon(
      Icons.check_circle_outline_sharp,
      color: Colors.green[400],
    );
  } else if (isSuccess is bool && !isSuccess) {
    iconWidget = Icon(
      Icons.cancel_outlined,
      color: Colors.red[400],
    );
  } else {
    iconWidget = Container();
  }
  showToastWidget(
    Container(
      height: 50,
      width: double.infinity,
      color: AppColor.navy,
      child: Align(
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  message,
                  style: const TextStyle(color: AppColor.white),
                ),
              ),
            ],
          ),
        ),
        alignment: Alignment.centerLeft,
      ),
    ),
    duration: const Duration(seconds: 5),
    animation: StyledToastAnimation.slideFromBottom,
    reverseAnimation: StyledToastAnimation.slideFromBottom,
    alignment: Alignment.center,
    position: StyledToastPosition.bottom,
  );
}
