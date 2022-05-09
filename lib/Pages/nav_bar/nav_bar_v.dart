import 'package:schedule/common/common.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppTheme>();
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset(
              "assets/images/logo.png",
              fit: BoxFit.fitWidth,
              color: themeProvider.text,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: themeProvider.text,
            ),
            title: Text(
              "LDCC Main Site",
              style: TextStyle(
                color: themeProvider.text,
              ),
            ),
            onTap: () {
              launchUrl(Uri.parse(mainWebSite));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.contacts_sharp,
              color: themeProvider.text,
            ),
            title: Text(
              "Directory",
              style: TextStyle(
                color: themeProvider.text,
              ),
            ),
            onTap: () {
              Modular.to.navigate("/directory");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.school,
              color: themeProvider.text,
            ),
            title: Text(
              "Schedule of Classes",
              style: TextStyle(
                color: themeProvider.text,
              ),
            ),
            onTap: () {
              Modular.to.navigate("/schedule");
            },
          ),
        ],
      ),
    );
  }
}
