import 'package:schedule/common/common.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                    isSmallFormFactor(context)
                        ? "assets/images/mark.png"
                        : "assets/images/logo.png",
                    height: 35.5,
                    fit: BoxFit.fitHeight)
              ],
            )
          ],
        ),
        backgroundColor: AppColor.navy,
        foregroundColor: AppColor.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "404 Error",
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w500,
                fontFamily: "DMSerifDisplay",
                color: AppColor.navy,
              ),
            ),
            const Text(
              "The page you're looking for doesn't exist.",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                fontFamily: "DMSerifDisplay",
                color: AppColor.navy,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 20,
              ),
              child: Text(
                "You may have mistyped the address or the page may have moved.",
                style: TextStyle(
                  fontSize: 20,
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
                  const Text(
                    "Return to the ",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  InkWell(
                    onTap: () => Modular.to.navigate("/schedule"),
                    child: const Text(
                      "Schedule of Classes",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Text(
                    " or the ",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  InkWell(
                    onTap: () => Modular.to.navigate("/contacts"),
                    child: const Text(
                      "Contacts",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Text(
                    " pages.",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
