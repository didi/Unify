import 'package:flutter/material.dart';

class FlutterHelloPage extends StatelessWidget {
  const FlutterHelloPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic params = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text('FlutterHelloPage')),
      backgroundColor: Colors.blue,
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Hello UniPage!'),
          const Text('Received params from NativeUniPage'),
          Text('$params')
        ],
      )),
    );
  }
}
