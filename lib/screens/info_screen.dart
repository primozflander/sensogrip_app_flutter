import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/text_styles.dart';
import '../models/uuids.dart';
import '../providers/ble_provider.dart';
import '../helpers/functions.dart';

class InfoScreen extends StatefulWidget {
  static const routeName = '/info_screen';

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  int _secondsInUse;
  int _secondsInRange;
  String _deviceId;

  @override
  void initState() {
    _secondsInUse = Provider.of<BleProvider>(context, listen: false)
        .findReceivedDataByName('secondsInUse');
    _secondsInRange = Provider.of<BleProvider>(context, listen: false)
        .findReceivedDataByName('secondsInRange');
    // _getId();
    super.initState();
  }

  // void _getId() async {
  //   _deviceId = await Functions.getDeviceId();
  //   setState(() {});
  // }

  @override
  void didChangeDependencies() async {
    _deviceId = await Functions.getDeviceId();
    setState(() {});
    super.didChangeDependencies();
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
                      ' $_secondsInUse ' +
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
                                        _secondsInUse = 0;
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
                      ' $_secondsInRange ' +
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
                                        _secondsInRange = 0;
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
                // ListTile(
                //   leading: Icon(
                //     Icons.edit,
                //     size: 26,
                //   ),
                //   title: Text(
                //       AppLocalizations.of(context).pencilVersion + ': 2.0'),
                // ),
                ListTile(
                  leading: Icon(
                    Icons.code,
                    size: 26,
                  ),
                  title:
                      Text(AppLocalizations.of(context).appVersion + ': 1.6.0'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.perm_device_info,
                    size: 26,
                  ),
                  title: Text(
                      AppLocalizations.of(context).deviceId + ': $_deviceId'),
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
