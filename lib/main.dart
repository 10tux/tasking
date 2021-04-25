import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'logic/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DesktopWindow.setMinWindowSize(Size(1000, 1000));
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DatabaseProvider()),
    ],
    child: MyApp(), // application root
  ));
}

/// Root widget for application
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

/// State for `MyApp`
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setUpDatabase(); // load tasks from database
  }

  /// load and setup database
  ///
  /// If database exists load tasks else create database
  void _setUpDatabase() async {
    if (!await DatabaseProvider.checkIfDatabaseExists()) {
      DatabaseProvider.createDatabase();
    }

    Provider.of<DatabaseProvider>(context, listen: false).loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
          textTheme: TextTheme(
            subtitle1: TextStyle(fontSize: 14),
            subtitle2: TextStyle(fontSize: 14),
          )),
      home: MyHomePage(title: 'Tasking'), // Landing page with task details
    );
  }
}
