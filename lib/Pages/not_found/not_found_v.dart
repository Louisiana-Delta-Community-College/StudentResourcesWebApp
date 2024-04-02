import 'package:schedule/common/common.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppTheme>();

    return LayoutBuilder(builder: (context, constraints) {
      var isSmallFormFactor = constraints.maxWidth < 800;
      return Scaffold(
        appBar: AppBar(
          title: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                      isSmallFormFactor
                          ? "assets/images/mark.png"
                          : "assets/images/logo.png",
                      height: 35.5,
                      fit: BoxFit.fitHeight)
                ],
              )
            ],
          ),
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "404 Error",
                style: TextStyle(
                  fontSize: themeProvider.fontSizeXXL,
                  fontWeight: FontWeight.w500,
                  fontFamily: "DMSerifDisplay",
                  color: themeProvider.text,
                ),
              ),
              Text(
                "The page you're looking for doesn't exist.",
                style: TextStyle(
                  fontSize: themeProvider.fontSizeL,
                  fontWeight: FontWeight.w500,
                  fontFamily: "DMSerifDisplay",
                  color: themeProvider.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: Text(
                  "You may have mistyped the address or the page may have moved.",
                  style: TextStyle(
                    fontSize: themeProvider.fontSizeM,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Return to the ",
                      style: TextStyle(
                        fontSize: themeProvider.fontSizeM,
                      ),
                    ),
                    InkWell(
                      onTap: () => Modular.to.navigate("/schedule"),
                      child: Text(
                        "Schedule of Classes",
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeM,
                        ),
                      ),
                    ),
                    Text(
                      " or the ",
                      style: TextStyle(
                        fontSize: themeProvider.fontSizeM,
                      ),
                    ),
                    InkWell(
                      onTap: () => Modular.to.navigate("/contacts"),
                      child: Text(
                        "Contacts",
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeM,
                        ),
                      ),
                    ),
                    Text(
                      " pages.",
                      style: TextStyle(
                        fontSize: themeProvider.fontSizeM,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
