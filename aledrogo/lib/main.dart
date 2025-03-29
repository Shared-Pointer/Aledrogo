import 'package:aledrogo/router.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _router = goRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      title: 'Aledrogo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}


//zastanawiamy sie co dalej bo jebany go_router wszystko psuje xdddd
