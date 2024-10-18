import 'package:flutter/material.dart';
import 'package:unify_uni_page_example/page/flutter_hello_page.dart';
import 'package:unify_uni_page_example/uni_page/demo_complex_uni_page.dart';

import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      '/demo': (context) => const UniPageDemo(),
      '/hello': (context) => const FlutterHelloPage(),
    }, home: const HomePage());
  }
}
