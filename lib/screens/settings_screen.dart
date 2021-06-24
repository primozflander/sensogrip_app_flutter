import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/custom_color_picker.dart';
import '../models/text_styles.dart';
import '../providers/ble_provider.dart';
import '../providers/users_provider.dart';
import '../models/uuids.dart';
import '../helpers/functions.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  RangeValues _tipSensorRangeValues = const RangeValues(30, 170);
  RangeValues _fingerSensorRangeValues = const RangeValues(50, 150);
  bool _positiveFeedbackSwitch = false;
  bool _angleCorrectionSwitch = false;
  bool _aiModeSwitch = false;
  bool isReady = false;
  int _tipSensorUpperRange;
  int _tipSensorLowerRange;
  int _fingerSensorUpperRange;
  int _fingerSensorLowerRange;
  int _isPositiveFeedback;
  int _feedbackType;
  int _isAIon;
  int _isAngleCorrected;
  int _tipPressureReleaseDelay;
  int _ledTurnOnSpeed;
  int _ledSimpleAssistanceColor;
  int _ledTipAssistanceColor;
  int _ledFingerAssistanceColor;
  int _ledOkColor;
  int _ledNokColor;

  FeedbackType _selectedFeedback;

  void _writeToChar(BluetoothCharacteristic characteristic, int value) async {
    await characteristic.write(Functions.convertIntToBytes(value));
  }

  void _updateSimpleAssistanceColor(int color) {
    _ledSimpleAssistanceColor = color;
    _writeConfigurationState();
  }

  void _updateTipAssistanceColor(int color) {
    _ledTipAssistanceColor = color;
    _writeConfigurationState();
  }

  void _updateFingerAssistanceColor(int color) {
    _ledFingerAssistanceColor = color;
    _writeConfigurationState();
  }

  void _updateOkColor(int color) {
    _ledOkColor = color;
    _writeConfigurationState();
  }

  void _updateNokColor(int color) {
    _ledNokColor = color;
    _writeConfigurationState();
  }

  void _parseConfigurationState(List<int> dataFromDevice) {
    var data = ByteData.view(Uint8List.fromList(dataFromDevice).buffer);
    _tipSensorUpperRange = data.getInt16(0, Endian.little).clamp(0, 500);
    _tipSensorLowerRange = data.getInt16(2, Endian.little).clamp(0, 500);
    _fingerSensorUpperRange = data.getInt16(4, Endian.little).clamp(0, 500);
    _fingerSensorLowerRange = data.getInt16(6, Endian.little).clamp(0, 500);
    _isPositiveFeedback = data.getInt16(8, Endian.little).clamp(0, 1);
    _feedbackType = data.getInt16(10, Endian.little).clamp(0, 5);
    _isAIon = data.getInt16(12, Endian.little).clamp(0, 1);
    _isAngleCorrected = data.getInt16(14, Endian.little).clamp(0, 1);
    _tipPressureReleaseDelay = data.getInt16(16, Endian.little).clamp(0, 250);
    _ledTurnOnSpeed = data.getInt16(18, Endian.little).clamp(0, 250);
    _ledSimpleAssistanceColor = data.getInt16(20, Endian.little).clamp(0, 359);
    _ledTipAssistanceColor = data.getInt16(22, Endian.little).clamp(0, 359);
    _ledFingerAssistanceColor = data.getInt16(24, Endian.little).clamp(0, 359);
    _ledOkColor = data.getInt16(26, Endian.little).clamp(0, 359);
    _ledNokColor = data.getInt16(28, Endian.little).clamp(0, 359);
    isReady = true;
    _setControlsState();
  }

  void _setControlsState() {
    setState(
      () {
        _tipSensorRangeValues = RangeValues(
            _tipSensorLowerRange.toDouble(), _tipSensorUpperRange.toDouble());
        _fingerSensorRangeValues = RangeValues(
            _fingerSensorLowerRange.toDouble(),
            _fingerSensorUpperRange.toDouble());
        _positiveFeedbackSwitch = (_isPositiveFeedback == 0) ? false : true;
        _selectedFeedback = Functions.intToFeedbackType(_feedbackType);
        _aiModeSwitch = (_isAIon == 0) ? false : true;
        _angleCorrectionSwitch = (_isAngleCorrected == 0) ? false : true;
      },
    );
  }

  void _readConfigurationState() async {
    final List<int> value =
        await Provider.of<BleProvider>(context, listen: false)
            .findByName(Uuid.configurationState)
            .read();
    _parseConfigurationState(value);
  }

  @override
  void initState() {
    _readConfigurationState();
    super.initState();
  }

  void _writeConfigurationState() async {
    List<int> configurationState = [];
    configurationState = Functions.convertIntToBytes(_tipSensorUpperRange) +
        Functions.convertIntToBytes(_tipSensorLowerRange) +
        Functions.convertIntToBytes(_fingerSensorUpperRange) +
        Functions.convertIntToBytes(_fingerSensorLowerRange) +
        Functions.convertIntToBytes(_isPositiveFeedback) +
        Functions.convertIntToBytes(_feedbackType) +
        Functions.convertIntToBytes(_isAIon) +
        Functions.convertIntToBytes(_isAngleCorrected) +
        Functions.convertIntToBytes(_tipPressureReleaseDelay) +
        Functions.convertIntToBytes(_ledTurnOnSpeed) +
        Functions.convertIntToBytes(_ledSimpleAssistanceColor) +
        Functions.convertIntToBytes(_ledTipAssistanceColor) +
        Functions.convertIntToBytes(_ledFingerAssistanceColor) +
        Functions.convertIntToBytes(_ledOkColor) +
        Functions.convertIntToBytes(_ledNokColor);
    await Provider.of<BleProvider>(context, listen: false)
        .findByName(Uuid.configurationState)
        .write(configurationState);
    Provider.of<UsersProvider>(context, listen: false).updateUserConfiguration(
      [
        _tipSensorUpperRange,
        _tipSensorLowerRange,
        _fingerSensorUpperRange,
        _fingerSensorLowerRange,
        _isPositiveFeedback,
        _feedbackType,
        _isAIon,
        _isAngleCorrected,
        _ledSimpleAssistanceColor,
        _ledTipAssistanceColor,
        _ledFingerAssistanceColor,
        _ledOkColor,
        _ledNokColor,
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String description,
    bool currentValue,
    Function updateValue,
  ) {
    return Container(
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 30),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        subtitle: Text(
          description,
        ),
        value: currentValue,
        onChanged: updateValue,
      ),
    );
  }

  Widget _buildRadioButton(
    String title,
    FeedbackType value,
  ) {
    return Container(
      // padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(5),
      width: 180,
      // color: Colors.grey.shade200,
      decoration: BoxDecoration(
        // shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          Radio(
            value: value,
            groupValue: _selectedFeedback,
            onChanged: (FeedbackType value) {
              // value == FeedbackType.negativeFeedback
              //     ? _isPositiveFeedback = 0
              //     : _isPositiveFeedback = 1;
              // value == FeedbackType.negativeFeedback
              //     ? _feedbackType = 1
              //     : _feedbackType = Functions.feedbackTypeToInt(value);
              _isPositiveFeedback = 1;
              _feedbackType = Functions.feedbackTypeToInt(value);
              print(Functions.feedbackTypeToInt(value));
              _writeConfigurationState();
              setState(
                () {
                  _selectedFeedback = value;
                },
              );
            },
          ),
          Text(
            title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        (Provider.of<UsersProvider>(context, listen: false).selectedUser.name ==
            'alphaOmega');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).settings,
          style: TextStyles.appBarTextStyle,
        ),
      ),
      body: !isReady
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 5),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).tipSensorRange,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _tipSensorRangeValues.start
                                          .floor()
                                          .toString(),
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: RangeSlider(
                                    values: _tipSensorRangeValues,
                                    min: 5,
                                    max: 500,
                                    divisions: 500,
                                    labels: RangeLabels(
                                      _tipSensorRangeValues.start
                                          .floor()
                                          .toString(),
                                      _tipSensorRangeValues.end
                                          .floor()
                                          .toString(),
                                    ),
                                    onChanged: (RangeValues values) {
                                      setState(
                                        () {
                                          _tipSensorRangeValues = values;
                                        },
                                      );
                                    },
                                    onChangeEnd: (RangeValues endValues) {
                                      _tipSensorUpperRange =
                                          endValues.end.toInt();
                                      _tipSensorLowerRange =
                                          endValues.start.toInt();
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          _writeConfigurationState();
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _tipSensorRangeValues.end
                                          .floor()
                                          .toString(),
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).fingerSensorRange,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _fingerSensorRangeValues.start
                                          .floor()
                                          .toString(),
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: RangeSlider(
                                    values: _fingerSensorRangeValues,
                                    min: 5,
                                    max: 500,
                                    divisions: 500,
                                    labels: RangeLabels(
                                      _fingerSensorRangeValues.start
                                          .floor()
                                          .toString(),
                                      _fingerSensorRangeValues.end
                                          .floor()
                                          .toString(),
                                    ),
                                    onChanged: (RangeValues values) {
                                      setState(() {
                                        _fingerSensorRangeValues = values;
                                      });
                                    },
                                    onChangeEnd: (RangeValues endValues) {
                                      _fingerSensorUpperRange =
                                          endValues.end.toInt();
                                      _fingerSensorLowerRange =
                                          endValues.start.toInt();
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          _writeConfigurationState();
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _fingerSensorRangeValues.end
                                          .floor()
                                          .toString(),
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).feedbackType,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              height: 120.0,
                              child: Center(
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    _buildRadioButton(
                                      AppLocalizations.of(context).noFeedback,
                                      FeedbackType.noFeedback,
                                    ),
                                    _buildRadioButton(
                                      AppLocalizations.of(context)
                                          .simpleFeedback,
                                      FeedbackType.simpleFeedback,
                                    ),
                                    _buildRadioButton(
                                      AppLocalizations.of(context)
                                          .bothSensorsInRange,
                                      FeedbackType.bothSensorsInRange,
                                    ),
                                    _buildRadioButton(
                                      AppLocalizations.of(context)
                                          .advancedFeedback,
                                      FeedbackType.advancedFeedback,
                                    ),
                                    _buildRadioButton(
                                      AppLocalizations.of(context)
                                          .overpressureFeedback,
                                      FeedbackType.overpressureFeedback,
                                    ),
                                    _buildRadioButton(
                                      AppLocalizations.of(context)
                                          .negativeFeedback,
                                      FeedbackType.negativeFeedback,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (isAdmin)
                              _buildSwitchTile(
                                AppLocalizations.of(context).positiveFeedback,
                                AppLocalizations.of(context).positiveFeedbackD,
                                _positiveFeedbackSwitch,
                                (value) {
                                  setState(
                                    () {
                                      _positiveFeedbackSwitch = value;
                                      _isPositiveFeedback = value ? 1 : 0;
                                      _writeConfigurationState();
                                    },
                                  );
                                },
                              ),
                            if (isAdmin)
                              _buildSwitchTile(
                                'Pencil angle correction?',
                                'When turned on, sensor values will be angle compensated',
                                _angleCorrectionSwitch,
                                (value) {
                                  setState(
                                    () {
                                      _angleCorrectionSwitch = value;
                                      _isAngleCorrected = value ? 1 : 0;
                                      _writeConfigurationState();
                                    },
                                  );
                                },
                              ),
                            _buildSwitchTile(
                              AppLocalizations.of(context).dynamicRange,
                              AppLocalizations.of(context).dynamicRangeD,
                              _aiModeSwitch,
                              (value) {
                                setState(
                                  () {
                                    _aiModeSwitch = value;
                                    _isAIon = value ? 1 : 0;
                                    _writeConfigurationState();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedFeedback != FeedbackType.noFeedback)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              if (_selectedFeedback !=
                                  FeedbackType.negativeFeedback)
                                CustomColorPicker(
                                  UniqueKey(),
                                  AppLocalizations.of(context)
                                      .positiveFeedbackColor,
                                  _ledOkColor,
                                  _updateOkColor,
                                ),
                              if (_selectedFeedback ==
                                      FeedbackType.negativeFeedback ||
                                  _selectedFeedback ==
                                      FeedbackType.overpressureFeedback)
                                CustomColorPicker(
                                  UniqueKey(),
                                  AppLocalizations.of(context)
                                      .negativeFeedbackColor,
                                  _ledNokColor,
                                  _updateNokColor,
                                ),
                              if (_selectedFeedback ==
                                  FeedbackType.simpleFeedback)
                                CustomColorPicker(
                                  UniqueKey(),
                                  AppLocalizations.of(context)
                                      .simpleAssistanceColor,
                                  _ledSimpleAssistanceColor,
                                  _updateSimpleAssistanceColor,
                                ),
                              if (_selectedFeedback ==
                                  FeedbackType.advancedFeedback)
                                CustomColorPicker(
                                  UniqueKey(),
                                  AppLocalizations.of(context)
                                      .tipAssistanceColor,
                                  _ledTipAssistanceColor,
                                  _updateTipAssistanceColor,
                                ),
                              if (_selectedFeedback ==
                                  FeedbackType.advancedFeedback)
                                CustomColorPicker(
                                  UniqueKey(),
                                  AppLocalizations.of(context)
                                      .fingerAssistanceColor,
                                  _ledFingerAssistanceColor,
                                  _updateFingerAssistanceColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              label: Text(
                                AppLocalizations.of(context)
                                    .resetSettingsToDefault,
                              ),
                              style: TextButton.styleFrom(
                                primary: Theme.of(context).errorColor,
                                textStyle:
                                    Theme.of(context).textTheme.bodyText1,
                              ),
                              icon: Icon(
                                Icons.settings_backup_restore,
                                size: 32,
                              ),
                              onPressed: () => {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(context)
                                              .resetSettingsToDefault,
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                        content: Text(
                                            AppLocalizations.of(context)
                                                .resetSettingsToDefaultQ),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .no)),
                                          TextButton(
                                              onPressed: () {
                                                _tipSensorUpperRange = 170;
                                                _tipSensorLowerRange = 30;
                                                _fingerSensorUpperRange = 170;
                                                _fingerSensorLowerRange = 30;
                                                _isPositiveFeedback = 1;
                                                _feedbackType = 1;
                                                _isAIon = 0;
                                                _isAngleCorrected = 1;
                                                _ledSimpleAssistanceColor = 240;
                                                _ledTipAssistanceColor = 180;
                                                _ledFingerAssistanceColor = 300;
                                                _ledOkColor = 120;
                                                _ledNokColor = 0;
                                                _setControlsState();
                                                _writeConfigurationState();
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .yes)),
                                        ],
                                      ) ??
                                      false,
                                )
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextButton.icon(
                              label: Text(
                                AppLocalizations.of(context).calibrateSensors,
                              ),
                              style: TextButton.styleFrom(
                                primary: Theme.of(context).errorColor,
                                textStyle:
                                    Theme.of(context).textTheme.bodyText1,
                              ),
                              icon: Icon(
                                Icons.tune,
                                size: 32,
                              ),
                              onPressed: () => {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(context)
                                              .calibrateSensors,
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                        content: Text(
                                            AppLocalizations.of(context)
                                                .calibrateSensorsQ),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .no)),
                                          TextButton(
                                              onPressed: () {
                                                _writeToChar(
                                                  Provider.of<BleProvider>(
                                                          context,
                                                          listen: false)
                                                      .findByName(
                                                          Uuid.calibrate),
                                                  0,
                                                );
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .yes)),
                                        ],
                                      ) ??
                                      false,
                                )
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
