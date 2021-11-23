import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/adapter_android_mp.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/functions.dart';
import '../models/text_styles.dart';

class RealtimeChart extends StatefulWidget {
  final StreamController<List<int>> streamController;
  final bool isSmall;
  final Function handler;
  final double maxYAxisValue;

  RealtimeChart(this.streamController, this.handler, this.isSmall,
      [this.maxYAxisValue]);

  @override
  State<StatefulWidget> createState() {
    return RealtimeChartState();
  }
}

class RealtimeChartState extends State<RealtimeChart>
    implements OnChartValueSelectedListener {
  LineChartController _controller;
  StreamSubscription<List<int>> streamSubscription;

  static const int VISIBLE_COUNT = 6000;
  int _removalCounter = 0;
  bool _isSubscribed = true;
  int _drawTipSensor = 1;
  int _drawFingerSensor = 1;
  bool _drawAngle = false;
  bool _drawSpeed = false;
  bool _isRecording = false;

  void _initController() {
    _controller = LineChartController(
      infoTextColor: Colors.grey,
      infoTextSize: 20,
      noDataText: AppLocalizations.of(context).noStream,
      highLightPerTapEnabled: false,
      highlightPerDragEnabled: false,
      legendSettingFunction: (legend, controller) {
        legend
          ..shape = LegendForm.DEFAULT
          ..typeface = TypeFace(fontFamily: 'Quicksand')
          ..textSize = 20
          ..yOffset = 3.0
          ..xOffset = 0
          ..textColor = Colors.black;
      },
      xAxisSettingFunction: (xAxis, controller) {
        xAxis
          ..textColor = Colors.black
          ..drawGridLines = true
          ..enabled = true;
      },
      axisLeftSettingFunction: (axisLeft, controller) {
        axisLeft..enabled = false;
        // axisLeft..axisMaximum = double.infinity;
        // axisLeft..axisMinimum = 0.0;
      },

      axisRightSettingFunction: (axisRight, controller) {
        axisRight..enabled = true;

        // axisRight..axisMinimum = 0.0;
        // axisRight..axisMaximum = double.infinity;
        // axisRight..useAutoScaleRestrictionMax = true;
      },
      drawBorders: true,
      borderColor: Colors.grey,
      borderStrokeWidth: 0.3,
      extraBottomOffset: 15,
      drawGridBackground: false,
      backgroundColor: Colors.white,
      selectionListener: this,
      pinchZoomEnabled: false,
      minOffset: 15,
      scaleXEnabled: true,
      scaleYEnabled: true,
      dragXEnabled: true,
      dragYEnabled: true,
      // autoScaleMinMaxEnabled: true,
      // autoScaleMinMaxEnabled: false,
    );
    LineData data = _controller?.data;
    if (data == null) {
      data = LineData();
      _controller.data = data;
    }
  }

  void _adaptYScale() {
    if (widget.maxYAxisValue != null) {
      _controller.axisRight.setAxisMaximum(widget.maxYAxisValue);
      _controller.axisLeft.setAxisMaximum(widget.maxYAxisValue);
    } else {
      _controller.axisRight.resetAxisMaximum();
      _controller.axisLeft.resetAxisMaximum();
    }
    _controller.axisRight.setAxisMinimum(0);
    _controller.axisLeft.setAxisMinimum(0);
  }

  void _addEntry(Map<String, dynamic> streamData) {
    _adaptYScale();
    LineData data = _controller.data;
    if (data != null) {
      ILineDataSet set = data.getDataSetByIndex(0);
      if (set == null) {
        set = _createTipSensorSet();
        data.addDataSet(set);
        data.addDataSet(_createFingerSensorSet());
        data.addDataSet(_createAngleSet());
        data.addDataSet(_createSpeedSet());
        data.addDataSet(_createTipMaxSet());
        data.addDataSet(_createTipMinSet());
        data.addDataSet(_createFingerMaxSet());
        data.addDataSet(_createFingerMinSet());
      }
      double x = (set.getEntryCount() + _removalCounter).toDouble() / 10;
      data.addEntry(
        Entry(
          x: x,
          y: _drawTipSensor != 0 ? streamData['tipSensorValue'].toDouble() : 0,
        ),
        0,
      );
      if (_drawFingerSensor > 0)
        data.addEntry(
          Entry(
            x: x,
            y: streamData['fingerSensorValue'].toDouble(),
          ),
          1,
        );
      if (_drawAngle)
        data.addEntry(
          Entry(
            x: x,
            y: streamData['angle'].toDouble(),
          ),
          2,
        );
      if (_drawSpeed)
        data.addEntry(
          Entry(
            x: x,
            y: streamData['speed'].toDouble(),
          ),
          3,
        );
      if (_drawTipSensor == 2)
        data.addEntry(
          Entry(
            x: x,
            y: streamData['tipSensorUpperRange'].toDouble(),
          ),
          4,
        );
      if (_drawTipSensor == 2)
        data.addEntry(
          Entry(
            x: x,
            y: streamData['tipSensorLowerRange'].toDouble(),
          ),
          5,
        );
      if (_drawFingerSensor == 2)
        data.addEntry(
          Entry(
            x: x,
            y: streamData['fingerSensorUpperRange'].toDouble(),
          ),
          6,
        );
      if (_drawFingerSensor == 2)
        data.addEntry(
          Entry(
            x: x,
            y: streamData['fingerSensorLowerRange'].toDouble(),
          ),
          7,
        );
      if (set.getEntryCount() > VISIBLE_COUNT) {
        data.removeEntry2(_removalCounter.toDouble() / 10, 0);
        data.removeEntry2(_removalCounter.toDouble() / 10, 1);
        data.removeEntry2(_removalCounter.toDouble() / 10, 2);
        data.removeEntry2(_removalCounter.toDouble() / 10, 3);
        data.removeEntry2(_removalCounter.toDouble() / 10, 4);
        data.removeEntry2(_removalCounter.toDouble() / 10, 5);
        data.removeEntry2(_removalCounter.toDouble() / 10, 6);
        data.removeEntry2(_removalCounter.toDouble() / 10, 7);
        _removalCounter++;
      }
      data.notifyDataChanged();
      _controller.setVisibleXRangeMaximum(300);
      _controller.moveViewToX(data.getEntryCount().toDouble());
      _controller.state?.setStateIfNotDispose();
    }
  }

  void _startStream() {
    Stream<List<int>> incomingData = widget.streamController.stream;
    streamSubscription = incomingData.listen(
      (streamData) {
        _addEntry(Functions.parseStream(streamData));
      },
    );
  }

  void _clearChart() {
    _controller.data?.clearValues();
    _controller.state?.setStateIfNotDispose();
    // controller.viewPortHandler.fitScreen1();
  }

  Color _getColor(int selector) {
    switch (selector) {
      case 0:
        return Colors.grey;
        break;
      case 1:
        return Theme.of(context).colorScheme.secondary;
        break;
      case 2:
        return Theme.of(context).primaryColor;
        break;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    _startStream();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _initController();
    super.didChangeDependencies();
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      // height: 585,
      width: widget.isSmall ? size.width / 7 * 4 : size.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
        elevation: 2,
        child: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isSubscribed
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.stop),
                          iconSize: 30,
                          color: Colors.white,
                          onPressed: () {
                            streamSubscription.cancel();
                            setState(() {
                              _isSubscribed = false;
                            });
                          },
                        ))
                    : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: Icon(Icons.play_arrow),
                          iconSize: 30,
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _isSubscribed = true;
                            });
                            _startStream();
                          },
                        ),
                      ),
                SizedBox(
                  height: 5,
                ),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 30,
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.delete_sweep),
                    iconSize: 30,
                    onPressed: _clearChart,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: _getColor(_drawTipSensor),
                    ),
                    child: Text(
                      AppLocalizations.of(context).tipSensorLetter,
                      style: TextStyles.avatarTextStyle,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          _drawTipSensor += 1;
                          if (_drawTipSensor > 2) _drawTipSensor = 0;
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: _getColor(_drawFingerSensor),
                    ),
                    child: Text(
                      AppLocalizations.of(context).fingerSensorLetter,
                      style: TextStyles.avatarTextStyle,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          _drawFingerSensor += 1;
                          if (_drawFingerSensor > 2) _drawFingerSensor = 0;
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: _drawAngle
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                    ),
                    child: Text(
                      AppLocalizations.of(context).angleLetter,
                      style: TextStyles.avatarTextStyle,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          _drawAngle = !_drawAngle;
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: _drawSpeed
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                    ),
                    child: Text(
                      AppLocalizations.of(context).speedLetter,
                      style: TextStyles.avatarTextStyle,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          _drawSpeed = !_drawSpeed;
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
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
                        widget.handler();
                        setState(
                          () {
                            _isRecording = !_isRecording;
                          },
                        );
                      }),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: LineChart(_controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineDataSet _createTipSensorSet() {
    LineDataSet set =
        LineDataSet(null, AppLocalizations.of(context).tipPressure);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.blue[400]);
    set.setLineWidth(1.0);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createFingerSensorSet() {
    LineDataSet set =
        LineDataSet(null, AppLocalizations.of(context).fingerPressure);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.red[400]);
    set.setLineWidth(1.0);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createAngleSet() {
    LineDataSet set = LineDataSet(null, AppLocalizations.of(context).angle);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.green[400]);
    set.setLineWidth(1.0);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createSpeedSet() {
    LineDataSet set = LineDataSet(null, AppLocalizations.of(context).speed);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.purple[400]);
    set.setLineWidth(1.0);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createTipMaxSet() {
    LineDataSet set =
        LineDataSet(null, AppLocalizations.of(context).tipPressureUpperRangeC);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.yellow[400]);
    set.setLineWidth(0.5);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createTipMinSet() {
    LineDataSet set =
        LineDataSet(null, AppLocalizations.of(context).tipPressureLowerRangeC);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.yellow[200]);
    set.setLineWidth(0.5);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createFingerMaxSet() {
    LineDataSet set = LineDataSet(
        null, AppLocalizations.of(context).fingerPressureUpperRangeC);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.orange[300]);
    set.setLineWidth(0.5);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  LineDataSet _createFingerMinSet() {
    LineDataSet set = LineDataSet(
        null, AppLocalizations.of(context).fingerPressureLowerRangeC);
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(Colors.orange[200]);
    set.setLineWidth(0.5);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }
}
