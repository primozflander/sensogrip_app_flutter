import 'package:flutter/material.dart';

import 'package:sensogrip_app/models/text_styles.dart';

class DisplayValue extends StatelessWidget {
  final int value;
  final String text;
  final String unit;

  DisplayValue(this.text, this.value, {this.unit = ''});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 2,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //   height: 10,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: TextStyles.sensorCardValueLarge,
                ),
                (unit != '')
                    ? Text(
                        '  $unit',
                        style: TextStyles.sensorCardTitle,
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              text,
              style: TextStyles.sensorCardTitle,
            ),
          ],
        ),
      ),
    );
  }
}
