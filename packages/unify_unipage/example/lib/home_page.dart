import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniPage demo'),
      ),
      body: ListView(children: [
        OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/demo',
                  arguments: '${DateTime.now().toIso8601String()}').then((value) => null);
            },
            child: Text('goto Unipage: demo'))
      ]),
    );
  }
}
