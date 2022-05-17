import 'package:schedule/common/common.dart';

import 'package:easy_table/easy_table.dart';

class DirectoryPage extends StatefulWidget {
  final String selectedCampus;
  const DirectoryPage({Key? key, this.selectedCampus = ""}) : super(key: key);

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  String titleAppendedCampus = "";

  @override
  initState() {
    // Pull in schedule data on page initialization.
    // If one were to try to issue this command in the Widget build method,
    // errors would ensue due to trying to rebuild while build is being executed.
    // This is due to Modular's notifyListeners() method which is used to update
    // isLoading status at the beginning of Schedule.getScheduleData()
    Modular.get<Directory>().getDirectoryData();
    // Schedule app title to run in the future to allow `MyApp.build()`
    // to finish before updating.
    if (widget.selectedCampus.isNotEmpty) {
      titleAppendedCampus =
          " - ${widget.selectedCampus.toString().replaceAll("%20", " ").titleCase}";
    }
    Future.delayed(const Duration(seconds: 1)).then((r) {
      // log.info("setting title");
      Modular.get<Directory>().selectedCampus =
          Uri.decodeComponent(widget.selectedCampus);
      Modular.get<AppTitle>().title = "Directory$titleAppendedCampus";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final directoryProvider = context.watch<Directory>();
    final themeProvider = context.watch<AppTheme>();

    return Scaffold(
      drawer: const NavBar(),
      appBar: EasySearchBar(
        title: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.dark_mode_sharp,
                    color: AppColor.navy,
                  ),
                ),
                Text("Directory$titleAppendedCampus"),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                    isSmallFormFactor(context)
                        ? "assets/images/mark.png"
                        : "assets/images/logo.png",
                    fit: BoxFit.fitHeight)
              ],
            )
          ],
        ),
        backgroundColor: AppColor.navy,
        foregroundColor: AppColor.white,
        searchCursorColor: themeProvider.text,
        searchBackIconTheme: IconThemeData(
          color: themeProvider.text,
        ),
        // centerTitle: true,
        actions: [
          FadeInDown(
            preferences: const AnimationPreferences(
              autoPlay: AnimationPlayStates.Forward,
              duration: Duration(
                milliseconds: 500,
              ),
            ),
            child: IconButton(
                onPressed: () {
                  themeProvider.toggle();
                },
                icon: themeProvider.icon),
          ),
        ],
        onSearch: (value) {
          directoryProvider.searchString = value;
          // log.verbose("Searching for: $value");
        },
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(),
            ),
            // DIRECTORY
            Expanded(
              flex: 98,
              child: Container(
                // color: Colors.green,
                padding: const EdgeInsets.only(
                  // top: 10,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: directoryProvider.isLoading
                    ? const CustomLoadingIndicator()
                    : directoryProvider.hasError
                        ? Center(child: Text(directoryProvider.errorMessage))
                        // : SelectableText(directoryProvider.data[0].toString()),
                        : directoryProvider.filteredData.isNotEmpty
                            ? isSmallFormFactor(context)
                                // MOBILE STYLE CARDS
                                ? ListView.builder(
                                    itemCount:
                                        directoryProvider.filteredData.length,
                                    itemBuilder: (context, index) {
                                      final _contact =
                                          directoryProvider.filteredData[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4, bottom: 4),
                                        child: ListTile(
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                          title: ContactsCard(
                                            contact: _contact,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                // SHOW REGULAR TABLE
                                : const ContactsEasyTable()
                            : Center(
                                child: Text(
                                  directoryProvider.searchString.isNotEmpty
                                      ? "No results for that search."
                                      : "No contacts found",
                                  textAlign: TextAlign.center,
                                ),
                              ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FadeInRight(
        preferences: const AnimationPreferences(
          duration: Duration(
            milliseconds: 500,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  // Modular.to.pushNamed('/other');
                  directoryProvider.getDirectoryData();
                },
                tooltip: 'Refresh',
                child: const Icon(Icons.refresh),
                heroTag: "btnRefresh",
                backgroundColor:
                    themeProvider.floatingActionButtonBackgroundColor,
                foregroundColor:
                    themeProvider.floatingActionButtonForegroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactsEasyTable extends StatelessWidget {
  const ContactsEasyTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final directoryProvider = context.watch<Directory>();
    final themeProvider = context.watch<AppTheme>();
    // final _doFitTableColumns = MediaQuery.of(context).size.width >= 1750;

    // final _viewPortWidth = MediaQuery.of(context).size.width;

    final _rows = directoryProvider.filteredData;

    return Center(
      child: EasyTableTheme(
        data: EasyTableThemeData(
          headerCell: HeaderCellThemeData(
            padding: const EdgeInsets.all(5),
            sortIconColor: themeProvider.text,
          ),
          row: RowThemeData(
            hoveredColor: (index) => themeProvider.rowColorHover,
            color: (index) => index % 2 == 0
                ? themeProvider.rowColorHighlighted
                : themeProvider.rowColorNormal,
          ),
        ),
        child: EasyTable(
          EasyTableModel(
            rows: _rows,
            columns: [
              EasyTableColumn(
                padding: const EdgeInsets.all(5),
                name: "Name",
                stringValue: (row) =>
                    "${(row as Map)["LastName"]}, ${row["FirstName"]}",
                width: 200,
                pinned: true,
              ),
              EasyTableColumn(
                padding: const EdgeInsets.all(5),
                name: "Phone Number",
                cellBuilder: (context, row) => InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      (row as Map)["PhoneNumber"],
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  onTap: () =>
                      launchUrl(Uri.parse("tel:${row["PhoneNumber"]}")),
                ),
                sort: (a, b) {
                  return (a as Map)["PhoneNumber"]
                      .toString()
                      .compareTo((b as Map)["PhoneNumber"].toString());
                },
                width: 130,
              ),
              EasyTableColumn(
                padding: const EdgeInsets.all(5),
                name: "Title",
                stringValue: (row) => (row as Map)["JobTitle"],
                width: 200,
              ),
              EasyTableColumn(
                padding: const EdgeInsets.all(5),
                name: "Department",
                stringValue: (row) => (row as Map)["Department"],
                width: 260,
              ),
              EasyTableColumn(
                padding: const EdgeInsets.all(5),
                name: "Email",
                cellBuilder: (context, row) => InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      (row as Map)["EmailAddress"],
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  onTap: () =>
                      launchUrl(Uri.parse("mailto:${row["EmailAddress"]}")),
                ),
                width: 230,
              ),
              EasyTableColumn(
                padding: const EdgeInsets.all(5),
                name: "Campus",
                stringValue: (row) => (row as Map)["Campus"],
                width: 130,
              ),
              EasyTableColumn(
                padding: const EdgeInsets.all(5),
                name: "Office",
                stringValue: (row) => (row as Map)["Office"],
                width: 100,
              ),
            ],
          ),
          columnsFit: viewPortWidth(context) >= 1300 ? true : false,
          visibleRowsCount: 20,
        ),
      ),
    );
  }
}

class ContactsCard extends StatelessWidget {
  const ContactsCard({
    Key? key,
    this.contact = const {},
  }) : super(key: key);

  final Map contact;

  @override
  Widget build(BuildContext context) {
    // final String _courseName = "${course["SC"]} ${course["CN"]}";
    // final borderColor = AppColor.bronze3.withOpacity(.7);
    final Color _borderColor = Theme.of(context).colorScheme.primary;
    // final Color _color = Theme.of(context).colorScheme.primary;
    final Color _borderTextColor = Theme.of(context).colorScheme.onPrimary;
    final Color _textColor = Theme.of(context).colorScheme.onBackground;

    final name = contact["LastName"].toString().trim() +
        ", " +
        contact["FirstName"].toString().trim();
    final phoneNumber = contact["PhoneNumber"].toString().trim();
    final title = contact["JobTitle"].toString().trim();

    final department = contact["Department"].toString().trim();

    final email = contact["EmailAddress"].toString().trim();

    final campus = contact["Campus"].toString().trim();
    final office = contact["Office"]
        .toString()
        .trim()
        .replaceAll("Bldg", "Building")
        .replaceAll("Rm", "Room");

    return Column(
      children: [
        Align(
          heightFactor: .9,
          alignment: Alignment.centerLeft,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              name,
              style: TextStyle(
                color: _borderTextColor,
                fontWeight: FontWeight.normal,
              ),
            ),
            height: 30,
            // width: 300,
            decoration: BoxDecoration(
              color: _borderColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 5.0, // soften the shadow
                  spreadRadius: 0.0, // extend the shadow
                  offset: Offset(
                    3.0, // right horizontally
                    3.0, // down Vertically
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5.0, // soften the shadow
                spreadRadius: 0.0, // extend the shadow
                offset: Offset(
                  3.0, // right horizontally
                  3.0, // down Vertically
                ),
              )
            ],
            color: _borderColor,
            // borderRadius: const BorderRadius.all(Radius.circular(20)),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),

          //-----------------------------
          // Card Body
          //-----------------------------
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 35,
                        color: _textColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => launchUrl(Uri.parse("tel:$phoneNumber")),
                ),
                Row(
                  children: [
                    Icon(Icons.turned_in_outlined, size: 35, color: _textColor),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.holiday_village_sharp,
                        size: 35, color: _textColor),
                    const SizedBox(width: 10),
                    Text(
                      department,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  child: Row(
                    children: [
                      Icon(Icons.email_sharp, size: 35, color: _textColor),
                      const SizedBox(width: 10),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => launchUrl(Uri.parse("mailto:$email")),
                ),
                Row(
                  children: [
                    Icon(Icons.meeting_room, size: 35, color: _textColor),
                    const SizedBox(width: 10),
                    Text(
                      "$campus - ${office.isEmpty ? "Room N/A" : office}",
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
