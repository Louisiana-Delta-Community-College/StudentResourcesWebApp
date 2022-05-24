import 'dart:io' show Platform;
import 'package:flutter/material.dart';
export 'package:flutter/services.dart';

import 'package:talker/talker.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:rive/rive.dart' hide LinearGradient, RadialGradient;
import 'package:flutter_modular/flutter_modular.dart';

import 'package:schedule/config.dart';
import 'package:schedule/common/controllers/theme.dart';

export 'dart:math';
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
  bool isMobile = false;

  if (Platform.isAndroid || Platform.isIOS) {
    isMobile = true;
  }

  return isMobile;
}

double viewPortWidth(context) {
  double viewPortWidth = double.infinity;
  viewPortWidth = MediaQuery.of(context).size.width;
  return viewPortWidth;
}

bool isSmallFormFactor(context) {
  var isSmallFormFactor = false;
  isSmallFormFactor = viewPortWidth(context) <= 800;
  return isSmallFormFactor;
}

void makeToast(String message) {
  showToast(
    message,
    duration: const Duration(seconds: 5),
    animation: StyledToastAnimation.fade,
    reverseAnimation: StyledToastAnimation.fade,
    alignment: Alignment.center,
    position: StyledToastPosition.bottom,
    backgroundColor: AppTheme.primary80,
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
      color: AppColor.primary,
      child: Align(
        alignment: Alignment.centerLeft,
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
      ),
    ),
    duration: const Duration(seconds: 5),
    animation: StyledToastAnimation.slideFromBottom,
    reverseAnimation: StyledToastAnimation.slideFromBottom,
    alignment: Alignment.center,
    position: StyledToastPosition.bottom,
  );
}

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          // "assets/rive/ldcc_mark.riv",
          "assets/rive/elastic_circle.riv",
          animations: [
            Modular.get<AppTheme>().themeMode == ThemeMode.dark
                ? "whiteInfinite"
                : "navyInfinite"
          ],
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
