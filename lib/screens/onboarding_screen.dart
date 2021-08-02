import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screens/start_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding_screen';
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    Navigator.of(context).pushReplacementNamed(BLECheckScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
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
          title: AppLocalizations.of(context).instantFeedbackH,
          body: AppLocalizations.of(context).instantFeedbackD,
          image: Image.asset(
            'assets/images/ledFeedback.png',
            width: 400,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: AppLocalizations.of(context).userProfilesH,
          body: AppLocalizations.of(context).userProfilesD,
          image: Image.asset(
            'assets/images/profiles.png',
            width: 400,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: AppLocalizations.of(context).analyzeDataH,
          body: AppLocalizations.of(context).analyzeDataD,
          image: Image.asset('assets/images/analyzeData.png', width: 400),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: AppLocalizations.of(context).cloudServiceH,
          body: AppLocalizations.of(context).cloudServiceD,
          image: Image.asset('assets/images/cloud.png', width: 270),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: Text(AppLocalizations.of(context).skipBtn,
          style: TextStyle(color: Colors.grey, fontSize: 18)),
      next: Container(
        height: 60,
        child: Center(
          child: Text(AppLocalizations.of(context).nextBtn,
              style: TextStyle(color: Colors.green, fontSize: 18)),
        ),
      ),
      done: Container(
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        width: 200,
        height: 60,
        child: Center(
          child: Text(AppLocalizations.of(context).getStartedBtn,
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
