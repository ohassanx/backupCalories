import 'dart:core';

import 'package:flutter/material.dart';
import 'package:audio_fit/models/user.dart';
import 'package:audio_fit/screens/home/home.dart';
import 'package:audio_fit/screens/home/wrapper.dart';
import 'package:audio_fit/services/auth.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(myApp());
}

class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserApp>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/second': (context) => Home(),
        },
        home: Wrapper(),
      ),
    );
  }
}
