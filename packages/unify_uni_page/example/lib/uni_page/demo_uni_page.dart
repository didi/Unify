import 'package:flutter/material.dart';
import 'package:unify_uni_page/unify_uni_page.dart';

class DemoUniPage extends StatefulWidget {
  const DemoUniPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DemoUniPageState();
}

class _DemoUniPageState extends State<DemoUniPage> {
  final UniPageController _controller = UniPageController();

  @override
  void initState() {
    super.initState();
    _controller.methodCallHandler = (methodName, prams) async {
      switch (methodName) {
        case 'flutterMethod1':
          // do something...
          break;
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UniPage(
        'demo_uni_page',
        controller: _controller,
        createParams: {'demoText': ModalRoute.of(context)?.settings.arguments},
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
