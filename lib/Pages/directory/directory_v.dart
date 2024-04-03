import 'package:flutter/rendering.dart';
import 'package:schedule/common/common.dart';

import 'package:davi/davi.dart';

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

    return LayoutBuilder(builder: (context, constraints) {
      var isSmallFormFactor = constraints.maxWidth < 800;

      return Scaffold(
        drawer: Semantics(
            value: "navigation menu",
            sortKey: const OrdinalSortKey(1),
            child: const NavBar()),
        appBar: EasySearchBar(
          title: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // This is here to pad the title to center position
                  const Icon(
                    Icons.dark_mode_sharp,
                    color: AppColor.primary,
                  ),
                  Focus(
                    child: Semantics(
                      label: "Page Title: Directory$titleAppendedCampus",
                      excludeSemantics: true,
                      child: Center(
                        child: Text(
                          "Directory$titleAppendedCampus",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: themeProvider.fontSizeM,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Focus(
                    child: Semantics(
                      image: true,
                      label: "LDCC Logo",
                      excludeSemantics: true,
                      child: Image.asset(
                          isSmallFormFactor
                              ? "assets/images/mark.png"
                              : "assets/images/logo.png",
                          fit: BoxFit.fitHeight),
                    ),
                  )
                ],
              )
            ],
          ),
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          searchCursorColor: themeProvider.text,
          searchBackIconTheme: IconThemeData(
            color: themeProvider.text,
          ),
          // centerTitle: true,
          actions: [
            Semantics(
              button: true,
              value: "toggle brightness mode",
              child: FadeInDown(
                preferences: const AnimationPreferences(
                  autoPlay: AnimationPlayStates.Forward,
                  duration: Duration(
                    milliseconds: 500,
                  ),
                ),
                child: IconButton(
                    tooltip: "Toggle Brightness Mode",
                    onPressed: () {
                      themeProvider.toggle();
                    },
                    icon: themeProvider.icon),
              ),
            ),
          ],
          onSearch: (value) {
            directoryProvider.searchString = value;
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
                              ? isSmallFormFactor
                                  // MOBILE STYLE CARDS
                                  ? GlowingOverscrollIndicator(
                                      axisDirection: AxisDirection.down,
                                      color: AppColor.secondary,
                                      child: ListView.builder(
                                        itemCount: directoryProvider
                                            .filteredData.length,
                                        itemBuilder: (context, index) {
                                          final contact = directoryProvider
                                              .filteredData[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            child: ListTile(
                                              dense: true,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              title: ContactsCard(
                                                contact: contact,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  // SHOW REGULAR TABLE
                                  : const ContactsDavi()
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
        floatingActionButton: Focus(
          child: Semantics(
            button: true,
            label: "Refresh Table Data",
            child: FadeInUp(
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
                      tooltip: 'Refresh Table Data',
                      heroTag: "btnRefresh",
                      backgroundColor:
                          themeProvider.floatingActionButtonBackgroundColor,
                      foregroundColor:
                          themeProvider.floatingActionButtonForegroundColor,
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class ContactsDavi extends StatelessWidget {
  const ContactsDavi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final directoryProvider = context.watch<Directory>();
    final themeProvider = context.watch<AppTheme>();
    final rows = directoryProvider.filteredData;

    return Center(
      child: DaviTheme(
        data: DaviThemeData(
          headerCell: HeaderCellThemeData(
            textStyle: TextStyle(
              color: themeProvider.text,
              fontSize: themeProvider.fontSizeXS,
            ),
            height: themeProvider.daviRowHeight,
            sortPriorityColor: themeProvider.text,
            padding: const EdgeInsets.all(5),
            sortIconColors: SortIconColors.all(themeProvider.text),
          ),
          row: RowThemeData(
            hoverBackground: (index) => themeProvider.rowColorHover,
            color: (index) => index % 2 == 0
                ? themeProvider.rowColorHighlighted
                : themeProvider.rowColorNormal,
          ),
          scrollbar: const TableScrollbarThemeData(
            thickness: 10,
            thumbColor: AppTheme.primary,
            radius: Radius.circular(10),
          ),
          cell: CellThemeData(
            contentHeight: themeProvider.daviRowHeight,
            textStyle: TextStyle(
              color: themeProvider.daviText,
              fontSize: themeProvider.fontSizeXS,
            ),
          ),
        ),
        child: Semantics(
          label: "Employee Directory Table",
          explicitChildNodes: true,
          // excludeSemantics: true,
          child: Davi(
            DaviModel(
              rows: rows,
              columns: [
                DaviColumn(
                  name: "Name",
                  cellBuilder: (context, row) {
                    final name =
                        "${(row.data as Map)["LastName"]}, ${(row.data as Map)["FirstName"]}";
                    return Focus(
                      child: Semantics(
                        label: "Name: $name",
                        excludeSemantics: true,
                        child: // SHARE CONTACT INFO BUTTON
                            Row(
                          children: [
                            IconButton(
                              color: themeProvider.text,
                              tooltip: "Share Contact Information",
                              padding: const EdgeInsets.only(
                                left: 1,
                                right: 1,
                              ),
                              icon: Icon(
                                Icons.copy_all_sharp,
                                size: themeProvider.fontSizeM,
                              ),
                              onPressed: () {
                                directoryProvider.copyRowToClipboard(row);

                                showSnackBar(
                                  'Contact information copied to clipboard!',
                                  isSuccess: true,
                                );
                              },
                            ),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: themeProvider.fontSizeXXS,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  width: 300,
                ),
                DaviColumn(
                  name: "Phone Number",
                  cellBuilder: (context, row) {
                    final phoneNumber = "${(row.data as Map)["PhoneNumber"]}";
                    return Focus(
                      child: Semantics(
                        label: "Phone Number: $phoneNumber",
                        onTap: () => launchUrl(Uri.parse(
                            "tel:${(row.data as Map)["PhoneNumber"]}")),
                        excludeSemantics: true,
                        button: true,
                        child: InkWell(
                          child: Text(
                            phoneNumber,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: themeProvider.text,
                              decorationThickness: 2,
                              fontSize: themeProvider.fontSizeXXS,
                            ),
                          ),
                          onTap: () => launchUrl(Uri.parse(
                              "tel:${(row.data as Map)["PhoneNumber"]}")),
                        ),
                      ),
                    );
                  },
                  width: 150 + themeProvider.fontSizeXXS * 2,
                ),
                DaviColumn(
                  name: "Title",
                  cellBuilder: (context, row) {
                    final jobTitle = "${(row.data as Map)["JobTitle"]}";
                    return Focus(
                      child: Semantics(
                        label: "Job Title: $jobTitle",
                        excludeSemantics: true,
                        child: Text(
                          jobTitle,
                          style: TextStyle(
                            fontSize: themeProvider.fontSizeXXS,
                          ),
                        ),
                      ),
                    );
                  },
                  // sort: (a, b) {
                  //   return directoryProvider.directoryTableStringSorter(
                  //       a, b, "JobTitle");
                  // },
                  width: 300 + themeProvider.fontSizeXXS * 2,
                ),
                DaviColumn(
                  name: "Department",
                  cellBuilder: (context, row) {
                    final department = "${(row.data as Map)["Department"]}";
                    return Focus(
                      child: Text(
                        department,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeXXS,
                        ),
                        semanticsLabel: "Department: $department",
                      ),
                    );
                  },
                  // sort: (a, b) {
                  //   return directoryProvider.directoryTableStringSorter(
                  //       a, b, "Department");
                  // },
                  width: 300 + themeProvider.fontSizeXXS * 2,
                ),
                DaviColumn(
                  name: "Email",
                  cellBuilder: (context, row) {
                    final emailAddress = "${(row.data as Map)["EmailAddress"]}";
                    return Focus(
                      child: Semantics(
                        label: "Email Address: $emailAddress",
                        excludeSemantics: true,
                        button: true,
                        onTap: () => launchUrl(Uri.parse(
                            "mailto:${(row.data as Map)["EmailAddress"]}")),
                        child: InkWell(
                          child: Text(
                            emailAddress,
                            style: TextStyle(
                              fontSize: themeProvider.fontSizeXXS,
                              decoration: TextDecoration.underline,
                              decorationColor: themeProvider.text,
                              decorationThickness: 2,
                            ),
                          ),
                          onTap: () => launchUrl(Uri.parse(
                              "mailto:${(row.data as Map)["EmailAddress"]}")),
                        ),
                      ),
                    );
                  },
                  // sort: (a, b) {
                  //   return directoryProvider.directoryTableStringSorter(
                  //       a, b, "EmailAddress");
                  // },
                  width: 300 + themeProvider.fontSizeXXS * 2,
                ),
                DaviColumn(
                  name: "Campus",
                  cellBuilder: (context, row) {
                    final campus = "${(row.data as Map)["Campus"]}";
                    return Focus(
                      child: Semantics(
                        label: "Campus: $campus",
                        excludeSemantics: true,
                        child: Text(
                          campus,
                          style: TextStyle(
                            fontSize: themeProvider.fontSizeXXS,
                          ),
                        ),
                      ),
                    );
                  },
                  // sort: (a, b) {
                  //   return directoryProvider.directoryTableStringSorter(
                  //       a, b, "Campus");
                  // },
                  width: 130 + themeProvider.fontSizeXXS * 2,
                ),
                DaviColumn(
                  name: "Office",
                  cellBuilder: (context, row) {
                    final office = "${(row.data as Map)["Office"]}";
                    return Focus(
                      child: Semantics(
                        label: "Office: $office",
                        excludeSemantics: true,
                        child: Text(
                          office,
                          style: TextStyle(
                            fontSize: themeProvider.fontSizeXXS,
                          ),
                        ),
                      ),
                    );
                  },
                  // sort: (a, b) {
                  //   return directoryProvider.directoryTableStringSorter(
                  //       a, b, "Office");
                  // },
                  width: 100 + themeProvider.fontSizeXXS * 2,
                ),
              ],
              multiSortEnabled: true,
            ),
            columnWidthBehavior: ColumnWidthBehavior.scrollable,

            // columnsFit: viewPortWidth(context) >= 1300 ? true : false,
            tapToSortEnabled: true,
            visibleRowsCount: 20,
          ),
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
    final themeProvider = context.watch<AppTheme>();
    final Color borderColor = themeProvider.mobileCardBorderColor;
    final Color borderTextColor = themeProvider.mobileCardBorderTextColor;
    final Color textColor = themeProvider.mobileCardTextColor;

    final name =
        "${contact["LastName"].toString().trim()}, ${contact["FirstName"].toString().trim()}";
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
            height: 30,
            // width: 300,
            decoration: BoxDecoration(
              color: borderColor,
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
            child: Text(
              name,
              style: TextStyle(
                color: borderTextColor,
                fontSize: themeProvider.fontSizeS,
                // fontWeight: FontWeight.w600,
              ),
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
            color: borderColor,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 35,
                        color: textColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeS,
                          color: textColor,
                          decoration: TextDecoration.underline,
                          decorationColor: textColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => launchUrl(Uri.parse("tel:$phoneNumber")),
                ),
                Row(
                  children: [
                    Icon(Icons.turned_in_outlined, size: 35, color: textColor),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: themeProvider.fontSizeS,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.holiday_village_sharp,
                        size: 35, color: textColor),
                    const SizedBox(width: 10),
                    Text(
                      department,
                      style: TextStyle(
                        fontSize: themeProvider.fontSizeS,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email_sharp, size: 35, color: textColor),
                      const SizedBox(width: 10),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: themeProvider.fontSizeS,
                          color: textColor,
                          decoration: TextDecoration.underline,
                          decorationColor: textColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => launchUrl(Uri.parse("mailto:$email")),
                ),
                Row(
                  children: [
                    Icon(Icons.meeting_room, size: 35, color: textColor),
                    const SizedBox(width: 10),
                    Text(
                      "$campus - ${office.isEmpty ? "Room N/A" : office}",
                      style: TextStyle(
                        fontSize: themeProvider.fontSizeS,
                        color: textColor,
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
