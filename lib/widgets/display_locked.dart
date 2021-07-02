import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/sql_helper.dart';
import '../helpers/firebase_cloud_helper.dart';
import '../helpers/functions.dart';

class DisplayLocked extends StatefulWidget {
  final bool isSmall;
  final Function saveData;
  final Function unlock;

  const DisplayLocked(this.saveData, this.isSmall, this.unlock);

  @override
  State<DisplayLocked> createState() => _DisplayLockedState();
}

class _DisplayLockedState extends State<DisplayLocked> {
  final _form = GlobalKey<FormState>();
  bool _isRecording = false;
  bool _isLoading = false;

  void _submitData() async {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    // _form.currentState.save();
    widget.unlock();
    print('code accepted');
  }

  Future<void> _startTransferToCLoud() async {
    setState(() {
      _isLoading = true;
    });
    final data = await SqlHelper.getData();
    final String deviceId = await Functions.getDeviceId();
    print('device id: $deviceId');
    final response =
        await FirebaseCloudHelper.transferDataListToCloud(deviceId, data);
    setState(() {
      _isLoading = false;
    });
    print('response $response');
    response
        ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).checkConnectionN)))
        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).transferToCloudN)));
  }

  @override
  void initState() {
    print('<display locked screen init>');
    // _getDataFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: widget.isSmall ? size.width / 7 * 4 : size.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
        elevation: 2,
        child: Row(
          children: [
            Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 20,
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _isRecording
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey,
                  child: IconButton(
                      icon: Icon(Icons.fiber_manual_record),
                      iconSize: 30,
                      color: _isRecording ? Colors.red : Colors.white,
                      onPressed: () {
                        widget.saveData();
                        setState(
                          () {
                            _isRecording = !_isRecording;
                          },
                        );
                      }),
                ),
                SizedBox(
                  height: 5,
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : IconButton(
                          icon: Icon(Icons.cloud_upload),
                          iconSize: 30,
                          color: Colors.white,
                          onPressed: _startTransferToCLoud,
                        ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 500,
                    padding: EdgeInsets.all(20),
                    child: Text(
                      AppLocalizations.of(context).lockedFeaturesD,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ),
                  Expanded(
                      // height: 300,
                      // width: 320,
                      child: Image.asset('assets/images/locked.png')),
                  // Container(
                  //   height: 50,
                  //   child: ElevatedButton.icon(
                  //     icon: Icon(
                  //       Icons.lock_open,
                  //       size: 30,
                  //     ),
                  //     label: Text(
                  //       // AppLocalizations.of(context).addUser,
                  //       'Unlock',
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 18,
                  //         color: Colors.white,
                  //         fontFamily: 'Quicksand',
                  //       ),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       primary: Theme.of(context).colorScheme.secondary,
                  //     ),
                  //     onPressed: () => _submitData(),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // )
                  Container(
                    width: 200,
                    child: Form(
                      key: _form,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          _submitData();
                        },
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context).enterPassword),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                          color: Colors.grey,
                          fontFamily: 'Quicksand',
                        ),
                        onSaved: (_) =>
                            SystemChrome.setEnabledSystemUIOverlays([]),
                        validator: (value) {
                          if (value != "2908") {
                            return AppLocalizations.of(context).passwordF;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 20,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
