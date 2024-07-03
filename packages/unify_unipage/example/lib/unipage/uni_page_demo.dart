import 'package:flutter/material.dart';
import 'package:unify_unipage/unify_unipage.dart';

class UniPageDemo extends StatelessWidget {
  const UniPageDemo({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final words = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text("DemoUniPage")),
      backgroundColor: Colors.white,
      body: UniPage('demo', createParams: {
        'words': words
      }),
    );
  }
}
