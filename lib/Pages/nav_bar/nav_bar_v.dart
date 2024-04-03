import 'package:schedule/common/common.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final themeProvider = context.watch<AppTheme>();
    return Drawer(
      backgroundColor: AppColor.primary,
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset(
              "assets/images/logo_stacked.png",
              fit: BoxFit.fitWidth,
              color: Colors.white,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
              color: Colors.white,
            ),
            title: const Text(
              "LDCC Main Site",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              launchUrl(Uri.parse(mainWebSite));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.contacts_sharp,
              color: Colors.white,
            ),
            title: const Text(
              "Directory",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Modular.to.navigate("/directory");
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.school,
              color: Colors.white,
            ),
            title: const Text(
              "Schedule of Classes",
              style: TextStyle(
                color: Colors.white,
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
