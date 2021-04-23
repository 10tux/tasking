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
    child: MyApp(),
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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Lexend',
      ),
      home: Consumer<DatabaseProvider>(
        builder: (context, dbProvider, child) {
          if (dbProvider.dbStatus == DatabaseStatus.Loaded) {
            return MyHomePage(title: 'Tasking');
          } else {
            return LoadingPage();
          }
        },
      ),
    );
  }
}

class LoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }

  void _loadDatabase() async {
    // check if database file exists
    if (await DatabaseProvider.checkIfDatabaseExists()) {
      //pass
    } else {
      Provider.of<DatabaseProvider>(context, listen: false).dbStatus =
          DatabaseStatus.FileMissing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<DatabaseProvider>(
          builder: (context, dbProvider, child) {
            if (dbProvider.dbStatus == DatabaseStatus.FileMissing) {
              return Text('Database File Missing');
            } else {
              return Text('Database Loading');
            }
          },
        ),
      ),
    );
  }
}
