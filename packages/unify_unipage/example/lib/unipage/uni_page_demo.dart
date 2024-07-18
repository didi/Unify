import 'package:flutter/material.dart';
import 'package:unify_unipage/unify_unipage.dart';

class UniPageDemo extends StatefulWidget {
  const UniPageDemo({Key? key}) : super(key: key);

  @override
  State<UniPageDemo> createState() => _UniPageDemoState();
}

class _UniPageDemoState extends State<UniPageDemo> {
  final UniPageController controller = UniPageController();
  String titleBarText = "DemoUniPage";

  @override
  void initState() {
    super.initState();
    controller.registerMethod("updateTitleBar", (params) async {
      assert(params.containsKey('title'));
      setState(() {
        titleBarText = params['title'];
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text(titleBarText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Update NAText",
            onPressed: () {
              controller
                  .invoke("flutterUpdateTextView", {"text": 'UpdatedFromFlutter'});
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: UniPage('demo',
          controller: controller, createParams: {'words': words}),
    );
  }
}
