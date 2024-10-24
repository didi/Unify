import 'package:flutter/material.dart';

class FlutterHelloPageWithResult extends StatefulWidget {
  const FlutterHelloPageWithResult({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FlutterHelloPageWithResultState();
}

class _FlutterHelloPageWithResultState
    extends State<FlutterHelloPageWithResult> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterHelloPage With Result'),
      ),
      body: Column(children: [
        TextField(
          controller: _controller,
          decoration:
              const InputDecoration(label: Text('Params to be passed back')),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text('Pop with result'),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
