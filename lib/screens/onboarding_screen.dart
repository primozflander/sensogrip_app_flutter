import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../screens/start_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding_screen';
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    Navigator.of(context).pushReplacementNamed(StartScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 18.0),
      titlePadding: EdgeInsets.all(30),
      descriptionPadding: EdgeInsets.symmetric(vertical: 30, horizontal: 300),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.only(top: 120),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "Instant feedback",
          body:
              "Get instant feedback via real-time chart and built-in pencil LED.",
          image: Image.asset(
            'assets/images/ledFeedback.png',
            width: 400,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "User profiles",
          body:
              "Each user has their own profile, with their own personalized settings and measurements.",
          image: Image.asset(
            'assets/images/profiles.png',
            width: 400,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Analyze data",
          body:
              "Get detailed statistics of your measurements from the App or simply export your data to your PC for further analysis.",
          image: Image.asset('assets/images/analyzeData.png', width: 400),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Cloud service",
          body: "Save your data securely to the cloud.",
          image: Image.asset('assets/images/cloud.png', width: 270),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text('Skip',
          style: TextStyle(color: Colors.grey, fontSize: 18)),
      next: Container(
        height: 60,
        child: Center(
          child: const Text('Next',
              style: TextStyle(color: Colors.grey, fontSize: 18)),
        ),
      ),
      done: Container(
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        width: 200,
        height: 60,
        child: Center(
          child: const Text('Get started',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeColor: Colors.green,
        activeSize: Size(20.0, 12.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
