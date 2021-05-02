import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/text_styles.dart';
import '../models/uuids.dart';
import '../providers/ble_provider.dart';

class InfoScreen extends StatefulWidget {
  static const routeName = '/info_screen';

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  int secondsInUse;
  int secondsInRange;

  @override
  void initState() {
    secondsInUse = Provider.of<BleProvider>(context, listen: false)
        .findReceivedDataByName('secondsInUse');
    secondsInRange = Provider.of<BleProvider>(context, listen: false)
        .findReceivedDataByName('secondsInRange');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).pencilInfo,
          style: TextStyles.appBarTextStyle,
        ),
      ),
      body: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.timer,
                    size: 26,
                  ),
                  title: Text(AppLocalizations.of(context).pencilUsage +
                      ' $secondsInUse ' +
                      AppLocalizations.of(context).seconds),
                  subtitle: Text(AppLocalizations.of(context).pencilUsageD),
                  trailing: ElevatedButton(
                    onPressed: () {
                      return showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              title: Text(
                                  AppLocalizations.of(context).resetCounter),
                              content: Text(
                                  AppLocalizations.of(context).resetCounterQ),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child:
                                        Text(AppLocalizations.of(context).no)),
                                TextButton(
                                    onPressed: () {
                                      Provider.of<BleProvider>(context,
                                              listen: false)
                                          .findByName(
                                              Uuid.resetMinutesPassedInUse)
                                          .write([0x0]);
                                      Navigator.of(context).pop(true);
                                      print('counter reset');
                                      setState(() {
                                        secondsInUse = 0;
                                      });
                                    },
                                    child:
                                        Text(AppLocalizations.of(context).yes)),
                              ],
                            ) ??
                            false,
                      );
                    },
                    child: Text(AppLocalizations.of(context).reset),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.timer,
                    size: 26,
                  ),
                  title: Text(AppLocalizations.of(context).pencilInRangeUsage +
                      ' $secondsInRange ' +
                      AppLocalizations.of(context).seconds),
                  subtitle:
                      Text(AppLocalizations.of(context).pencilInRangeUsageD),
                  trailing: ElevatedButton(
                    onPressed: () {
                      return showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              title: Text(
                                  AppLocalizations.of(context).resetCounter),
                              content: Text(
                                  AppLocalizations.of(context).resetCounterQ),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child:
                                        Text(AppLocalizations.of(context).no)),
                                TextButton(
                                    onPressed: () {
                                      Provider.of<BleProvider>(context,
                                              listen: false)
                                          .findByName(
                                              Uuid.resetMinutesPassedInRange)
                                          .write([0x0]);
                                      Navigator.of(context).pop(true);
                                      print('counter reset');
                                      setState(() {
                                        secondsInRange = 0;
                                      });
                                    },
                                    child:
                                        Text(AppLocalizations.of(context).yes)),
                              ],
                            ) ??
                            false,
                      );
                    },
                    child: Text(AppLocalizations.of(context).reset),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.code,
                    size: 26,
                  ),
                  title: Text('App version: 1.2.3'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.contact_support,
                    size: 26,
                  ),
                  title: Text(AppLocalizations.of(context).support +
                      ' primoz.flander@fh-campuswien.ac.at'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
