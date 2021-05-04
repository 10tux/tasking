import 'package:flutter/material.dart';
import 'widgets/app_bar.dart';

class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: taskingAppBar(context),
    );
  }
}
