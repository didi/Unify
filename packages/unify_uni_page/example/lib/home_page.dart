import 'package:flutter/material.dart';
import 'package:unify_uni_page_example/uni_page/demo_uni_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String complexPageResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniPage demo'),
      ),
      body: ListView(children: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const DemoUniPage(),
              settings: const RouteSettings(arguments: 'Hello from UniPage!'),
            ));
          },
          child: const Text('Basic UniPage'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(
                  '/demo',
                  arguments:
                      'createTime: ${DateTime.now().millisecondsSinceEpoch}',
                )
                .then((value) => setState(() =>
                    complexPageResult = 'Complex UniPage result: $value'));
          },
          child: const Text('Complex UniPage'),
        ),
        Text(complexPageResult),
      ]),
    );
  }
}
