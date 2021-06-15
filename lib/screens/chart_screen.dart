import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:screen_recorder_flutter/screen_recorder_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/realtime_chart.dart';
import '../widgets/display_data_and_stats.dart';
import '../widgets/app_drawer.dart';
import '../models/data.dart';
import './start_screen.dart';
import '../models/text_styles.dart';
import '../helpers/functions.dart';
import '../helpers/sql_helper.dart';
import '../providers/ble_provider.dart';
import '../providers/users_provider.dart';

enum ViewOptions {
  BleData,
  BleAndCameraData,
}

class ChartScreen extends StatefulWidget {
  static const routeName = '/chart_screen';

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  bool _isRecording = false;
  bool _isCameraOn = false;
  CameraController controller;
  bool _isCameraReady = false;
  List<String> currentMeasurements = [];

  void _saveData() async {
    if (_isRecording == false) {
      currentMeasurements = [];
      _isRecording = true;
      if (_isCameraOn) {
        ScreenRecorderFlutter.startScreenRecord;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(days: 1),
          content: Text(AppLocalizations.of(context).recording),
          backgroundColor: Colors.black87,
        ),
      );
    } else {
      _isRecording = false;
      if (_isCameraOn) {
        ScreenRecorderFlutter.stopScreenRecord;
      }
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      await Functions.saveMeasurementDialog(context).then(
        (measurementDescription) {
          print('value from drop down $measurementDescription');
          if (measurementDescription != null) {
            _saveMeasurementToDb(currentMeasurements, measurementDescription);
            _saveMeasurementToFile(currentMeasurements, measurementDescription);
          }
        },
      );
    }
  }

  void _addMeasurementPoint(Map<String, dynamic> data) {
    currentMeasurements.add(
        '${data['timestamp']},${data['tipSensorValue']},${data['tipSensorUpperRange']},${data['tipSensorLowerRange']},${data['fingerSensorValue']},${data['fingerSensorUpperRange']},${data['fingerSensorLowerRange']},${data['angle']},${data['speed']},${data['accX']},${data['accY']},${data['accZ']},${data['gyroX']},${data['gyroY']},${data['gyroZ']}');
  }

  void _saveMeasurementToDb(List<String> data, String description) {
    final id =
        Provider.of<UsersProvider>(context, listen: false).selectedUser.id;
    Data dbData = Data(
      id: null,
      userid: id,
      description: description,
      measurement: data.join('_'),
      timestamp: DateFormat('dd.MM.yyyy kk:mm:ss').format(
        DateTime.now(),
      ),
    );
    SqlHelper.insertData(dbData.toMap());
  }

  void _saveMeasurementToFile(List<String> data, String description) async {
    String fileHeader =
        'timestamp,tipPressure,tipUpperRange,tipLowerRange,fingerPressure,fingerUpperRange,fingerLowerRange,angle,writtingSpeed,accX,accY,accZ,gyroX,gyroY,gyroZ';
    data.insert(0, fileHeader);
    final userName =
        Provider.of<UsersProvider>(context, listen: false).selectedUser.name;
    String formattedDate = DateFormat('dd.MM.yyyy_kk.mm.ss').format(
      DateTime.now(),
    );
    await getExternalStorageDirectory().then(
      (directory) {
        File file = File(
            '${directory.path}/${description}_${userName}_$formattedDate.txt');
        file.writeAsString(data.join('\n'), mode: FileMode.write);
      },
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(
              AppLocalizations.of(context).disconnectDevice,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            content: Text(AppLocalizations.of(context).disconnectDeviceQ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context).no)),
              TextButton(
                  onPressed: () {
                    final device =
                        Provider.of<BleProvider>(context, listen: false)
                            .bleDevice;
                    Navigator.of(context).pop(true);
                    Navigator.of(context)
                        .pushReplacementNamed(StartScreen.routeName);
                    device.disconnect();
                  },
                  child: Text(AppLocalizations.of(context).yes)),
            ],
          ) ??
          false,
    );
  }

  void _initCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    print('camera: $cameras');
    controller = CameraController(cameras.first, ResolutionPreset.max);
    controller.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isCameraReady = true;
        });
      },
    );
    // controller.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
  }

  Future<void> _initScreenRecorder() async {
    ScreenRecorderFlutter.init(onRecordingStarted: (started, msg) {
      print("Recording $started $msg");
    }, onRecodingCompleted: (path) {
      print("Recording completed $path");
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initCamera();
    _initScreenRecorder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bleData = Provider.of<BleProvider>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context).chartView,
            style: TextStyles.appBarTextStyle,
          ),
          actions: [
            PopupMenuButton(
              onSelected: (ViewOptions selectedValue) {
                setState(
                  () {
                    if (selectedValue == ViewOptions.BleData) {
                      _isCameraOn = false;
                    } else {
                      _isCameraOn = true;
                    }
                  },
                );
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child:
                      Text(AppLocalizations.of(context).displayRealtimeChart),
                  value: ViewOptions.BleData,
                ),
                PopupMenuItem(
                  child: Text(AppLocalizations.of(context)
                      .displayRealtimeChartAndVideo),
                  value: ViewOptions.BleAndCameraData,
                ),
              ],
            ),
          ],
        ),
        drawer: AppDrawer(_onWillPop),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  RealtimeChart(
                    bleData.streamController,
                    _saveData,
                    _isCameraOn,
                  ),
                  if (_isCameraOn &&
                      _isCameraReady &&
                      controller.value.isInitialized)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            top: 10, left: 0, right: 10, bottom: 4),
                        height: size.height - 150,
                        // width: 590,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Transform.scale(
                            scale: 2,
                            child: Center(
                              child: CameraPreview(controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            StreamBuilder<List<dynamic>>(
              stream: bleData.streamController.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.active) {
                  var parsedData = Functions.parseStream(snapshot.data);
                  //print('Parsed data---------> $parsedData');
                  bleData.updateReceivedData(parsedData);
                  if (_isRecording) {
                    _addMeasurementPoint(parsedData);
                  }
                  return Container(
                    height: 140,
                    child: DisplayDataAndStats(
                      parsedData,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
