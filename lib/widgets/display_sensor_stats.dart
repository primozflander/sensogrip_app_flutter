import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sensogrip_app/models/text_styles.dart';

class DisplaySensorStats extends StatefulWidget {
  final int value;
  final String text;
  // final String unit;

  DisplaySensorStats(
    this.text,
    this.value,
  );

  @override
  _DisplaySensorStatsState createState() => _DisplaySensorStatsState();
}

class _DisplaySensorStatsState extends State<DisplaySensorStats> {
  int _sumValues = 0;
  int _maxValue = 0;
  int _indexValue = 1;

  int _getMax(int value) {
    if (value > _maxValue) _maxValue = value;
    return _maxValue;
  }

  int _getAverage(int value) {
    if (value != null && value > 5) {
      _sumValues += value;
      _indexValue++;
    }
    return (_sumValues ~/ _indexValue).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 3,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        elevation: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   height: 5,
                  // ),
                  Text(
                    widget.value.toString(),
                    style: TextStyles.sensorCardValueLarge,
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    widget.text,
                    style: TextStyles.sensorCardTitle,
                  ),
                ],
              ),
            ),
            Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () => _maxValue = 0,
                    child: Column(
                      children: [
                        Text(
                          _getMax(widget.value).toString(),
                          style: TextStyles.sensorCardValueSmall,
                        ),
                        Text(
                          AppLocalizations.of(context).max,
                          style: TextStyles.sensorCardTitle,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _sumValues = 0;
                      _indexValue = 1;
                    },
                    child: Column(
                      children: [
                        Text(
                          _getAverage(widget.value).toString(),
                          style: TextStyles.sensorCardValueSmall,
                        ),
                        Text(AppLocalizations.of(context).avg,
                            style: TextStyles.sensorCardTitle),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
