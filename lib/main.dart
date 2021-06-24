import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './providers/ble_provider.dart';
import './providers/users_provider.dart';
import './screens/info_screen.dart';
import './screens/profiles_screen.dart';
import './screens/chart_screen.dart';
import './screens/settings_screen.dart';
import './screens/start_screen.dart';
// import './screens/intro_screen.dart';
import './screens/connect_to_device_screen.dart';
import './screens/data_and_stats_screen.dart';
import './screens/help_screen.dart';
import './screens/onboarding_screen.dart';

// void main() => runApp(MyApp());
bool showOnboarding;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("showOnboarding", null);
  showOnboarding = prefs.getBool("showOnboarding");
  if (showOnboarding == null) {
    await prefs.setBool("showOnboarding", false);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UsersProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => BleProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (ctx) => DataProvider(),
        // ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        title: 'Sensogrip App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.blueAccent,
          accentColorBrightness: Brightness.dark,
          fontFamily: 'Quicksand',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // initialRoute: StartScreen.routeName,
        initialRoute: showOnboarding != null
            ? StartScreen.routeName
            : OnboardingScreen.routeName,
        routes: {
          StartScreen.routeName: (context) => StartScreen(),
          ProfilesScreen.routeName: (context) => ProfilesScreen(),
          InfoScreen.routeName: (context) => InfoScreen(),
          ChartScreen.routeName: (context) => ChartScreen(),
          SettingsScreen.routeName: (context) => SettingsScreen(),
          ConnectToDeviceScreen.routeName: (context) => ConnectToDeviceScreen(),
          DataAndStatsScreen.routeName: (context) => DataAndStatsScreen(),
          HelpScreen.routeName: (context) => HelpScreen(),
          OnboardingScreen.routeName: (context) => OnboardingScreen(),
          // DataSelectionScreen.routeName: (context) => DataSelectionScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (ctx) => StartScreen(),
          );
        },
      ),
    );
  }
}
