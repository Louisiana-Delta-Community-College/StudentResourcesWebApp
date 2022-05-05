import 'package:schedule/common/common.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Modular.to.navigate("/schedule");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
