import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:unify_unipage/unify_unipage.dart';
import 'package:unify_unipage_example/page/flutter_hello_page.dart';
import 'package:unify_unipage_example/unipage/uni_page_demo.dart';

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
    }, home: UniPageProvider(child: HomePage()));
  }
}
