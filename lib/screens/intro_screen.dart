import 'dart:async';

import 'package:flutter/material.dart';
import './start_screen.dart';

class IntroScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  _startTimer() async {
    var duration = new Duration(seconds: 1);
    return new Timer(duration, _route);
  }

  _route() {
    Navigator.of(context).pushReplacementNamed(StartScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Image.asset('assets/images/fhcampus_banner.png'),
      ),
    );
  }
}
