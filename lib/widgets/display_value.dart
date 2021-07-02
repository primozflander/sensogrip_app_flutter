import 'package:flutter/material.dart';

class DisplayValue extends StatelessWidget {
  final int value;
  final String text;
  final String unit;

  DisplayValue(this.text, this.value, {this.unit = ''});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 2,
      // width: 200,
      // height: 150,
      //padding: EdgeInsets.all(5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 50,
                    color: Theme.of(context).colorScheme.secondary,
                    //fontFamily: 'Quicksand',
                  ),
                ),
                (unit != '')
                    ? Text(
                        '  $unit',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color: Colors.black),
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
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
