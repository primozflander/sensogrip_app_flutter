import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:device_info/device_info.dart';

class Functions {
  static Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId;
    }
  }

  static List<int> convertIntToBytes(int value) {
    int byte1 = value & 0xff;
    int byte2 = (value >> 8) & 0xff;
    return [byte1, byte2];
  }

  static Color intToColor(int color) {
    Color outputColor = Colors.grey;
    switch (color) {
      case 0:
        outputColor = Colors.red;
        break;
      case 60:
        outputColor = Colors.yellow;
        break;
      case 120:
        outputColor = Colors.green;
        break;
      case 180:
        outputColor = Colors.cyan;
        break;
      case 240:
        outputColor = Colors.blue;
        break;
      case 300:
        outputColor = Colors.purple;
        break;
    }
    return outputColor;
  }

  static int colorToInt(Color color) {
    int outputColor;
    if (color == Colors.red) {
      outputColor = 0;
    } else if (color == Colors.yellow) {
      outputColor = 60;
    } else if (color == Colors.green) {
      outputColor = 120;
    } else if (color == Colors.cyan) {
      outputColor = 180;
    } else if (color == Colors.blue) {
      outputColor = 240;
    } else if (color == Colors.purple) {
      outputColor = 300;
    } else
      outputColor = 0;
    return outputColor;
  }

  static int feedbackTypeToInt(FeedbackType feedbackType) {
    int output = 0;
    switch (feedbackType) {
      case FeedbackType.noFeedback:
        output = 0;
        break;
      case FeedbackType.bothSensorsInRange:
        output = 1;
        break;
      case FeedbackType.simpleFeedback:
        output = 2;
        break;
      case FeedbackType.advancedFeedback:
        output = 3;
        break;
      case FeedbackType.overpressureFeedback:
        output = 4;
        break;
      case FeedbackType.negativeFeedback:
        output = 5;
        break;
    }
    return output;
  }

  static FeedbackType intToFeedbackType(int value) {
    FeedbackType output = FeedbackType.noFeedback;
    switch (value) {
      case 0:
        output = FeedbackType.noFeedback;
        break;
      case 1:
        output = FeedbackType.bothSensorsInRange;
        break;
      case 2:
        output = FeedbackType.simpleFeedback;
        break;
      case 3:
        output = FeedbackType.advancedFeedback;
        break;
      case 4:
        output = FeedbackType.overpressureFeedback;
        break;
      case 5:
        output = FeedbackType.negativeFeedback;
        break;
    }
    return output;
  }

  static Map<String, dynamic> parseStream(List<dynamic> dataFromDevice) {
    var data = ByteData.view(Uint8List.fromList(dataFromDevice).buffer);
    if (data.lengthInBytes == 48) {
      return {
        'timestamp': data.getUint16(0, Endian.little),
        'tipSensorValue': data.getInt16(2, Endian.little),
        'fingerSensorValue': data.getInt16(4, Endian.little),
        'angle': data.getInt16(6, Endian.little).abs(),
        'speed': data.getInt16(8, Endian.little),
        'batteryLevel': data.getInt16(10, Endian.little),
        'secondsInRange': data.getInt16(12, Endian.little),
        'secondsInUse': data.getInt16(14, Endian.little),
        'tipSensorUpperRange': data.getInt16(16, Endian.little),
        'tipSensorLowerRange': data.getInt16(18, Endian.little),
        'fingerSensorUpperRange': data.getInt16(20, Endian.little),
        'fingerSensorLowerRange': data.getInt16(22, Endian.little),
        'accX': data.getFloat32(24, Endian.little),
        'accY': data.getFloat32(28, Endian.little),
        'accZ': data.getFloat32(32, Endian.little),
        'gyroX': data.getFloat32(36, Endian.little),
        'gyroY': data.getFloat32(40, Endian.little),
        'gyroZ': data.getFloat32(44, Endian.little),
      };
    } else if (data.lengthInBytes == 24) {
      return {
        'timestamp': data.getUint16(0, Endian.little),
        'tipSensorValue': data.getInt16(2, Endian.little),
        'fingerSensorValue': data.getInt16(4, Endian.little),
        'angle': data.getInt16(6, Endian.little).abs(),
        'speed': data.getInt16(8, Endian.little),
        'batteryLevel': data.getInt16(10, Endian.little),
        'secondsInRange': data.getInt16(12, Endian.little),
        'secondsInUse': data.getInt16(14, Endian.little),
        'tipSensorUpperRange': data.getInt16(16, Endian.little),
        'tipSensorLowerRange': data.getInt16(18, Endian.little),
        'fingerSensorUpperRange': data.getInt16(20, Endian.little),
        'fingerSensorLowerRange': data.getInt16(22, Endian.little),
        'accX': 0,
        'accY': 0,
        'accZ': 0,
        'gyroX': 0,
        'gyroY': 0,
        'gyroZ': 0,
      };
    } else
      return {
        'timestamp': 0,
        'tipSensorValue': 0,
        'fingerSensorValue': 0,
        'angle': 0,
        'speed': 0,
        'batteryLevel': 0,
        'secondsInRange': 0,
        'secondsInUse': 0,
        'tipSensorUpperRange': 0,
        'tipSensorLowerRange': 0,
        'fingerSensorUpperRange': 0,
        'fingerSensorLowerRange': 0,
        'accX': 0,
        'accY': 0,
        'accZ': 0,
        'gyroX': 0,
        'gyroY': 0,
        'gyroZ': 0,
      };
  }

  static Future<String> saveMeasurementDialog(BuildContext context) {
    String dropdownValue = 'A1';
    final _form = GlobalKey<FormState>();
    var _isCustom = false;
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(
              builder: (BuildContext ctx, StateSetter setState) {
            return AlertDialog(
                  title: Text(
                    AppLocalizations.of(context).saveMeasurement,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      height: 90,
                      // width: 500,
                      child: dropdownValue !=
                              AppLocalizations.of(context).newTestProtocol
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)
                                    .saveMeasurementQ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(AppLocalizations.of(context)
                                            .testProtocol +
                                        ':'),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    DropdownButton<String>(
                                      value: dropdownValue,
                                      // icon: const Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                      underline: Container(
                                        height: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          dropdownValue = newValue;
                                        });
                                      },
                                      items: <String>[
                                        AppLocalizations.of(context)
                                            .newTestProtocol,
                                        'A1',
                                        'A2',
                                        'A3',
                                        'A4',
                                        'A5',
                                        'B1a1',
                                        'B1a2',
                                        'B2b1',
                                        'B2b2',
                                        'B3a1',
                                        'B3a2',
                                        'B4b1',
                                        'B4b2',
                                        'B5a1',
                                        'B5a2',
                                        'C',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Form(
                              key: _form,
                              child: TextFormField(
                                initialValue: '',
                                decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)
                                        .testProtocol),
                                textInputAction: TextInputAction.done,
                                // onFieldSubmitted: (_) {
                                //   print('--------------->form submited');
                                //   // FocusScope.of(context).requestFocus(_priceFocusNode);
                                // },
                                onSaved: (value) {
                                  dropdownValue = value;
                                },
                                onChanged: (_) {
                                  _isCustom = true;
                                  print('custom---------->');
                                },
                                // validator: (value) {
                                //   if (value.isEmpty) {
                                //     return 'Please provide a value';
                                //   }
                                //   return null;
                                // },
                              ),
                            ),
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        if (dropdownValue ==
                            AppLocalizations.of(context).newTestProtocol)
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    dropdownValue = 'A1';
                                    _isCustom = false;
                                  });
                                },
                                child: Text(AppLocalizations.of(context).back),
                              ),
                            ],
                          ),
                        Expanded(child: Container()),
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context).no)),
                        TextButton(
                          onPressed: () {
                            if (_isCustom) {
                              _form.currentState.save();
                            }
                            Navigator.of(context).pop(dropdownValue);
                            SystemChrome.setEnabledSystemUIOverlays([]);
                          },
                          child: Text(AppLocalizations.of(context).yes),
                        ),
                      ],
                    ),
                  ],
                ) ??
                null;
          });
        });
  }
}

enum FeedbackType {
  noFeedback,
  bothSensorsInRange,
  simpleFeedback,
  advancedFeedback,
  overpressureFeedback,
  negativeFeedback,
}
