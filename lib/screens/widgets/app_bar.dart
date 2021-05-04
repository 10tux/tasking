import 'package:flutter/material.dart';

final taskingAppBar = (BuildContext context) => AppBar(
      title: Text('Tasking'),
      actions: [
        Container(
          padding: EdgeInsets.all(10),
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            child: Text('Tasks', style: TextStyle(color: Colors.white)),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/activities');
            },
            child: Text('Activities', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
      elevation: 0,
    );
