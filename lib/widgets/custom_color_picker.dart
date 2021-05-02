import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CustomColorPicker extends StatefulWidget {
  final List<Color> _availableColors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
  ];

  final String text;
  final int startColor;
  final Function handler;

  CustomColorPicker(Key key, this.text, this.startColor, this.handler)
      : super(key: key);

  @override
  _CustomColorPickerState createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  Color _currentColor = Colors.grey;

  Color _intToColor(int color) {
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

  int _colorToInt(Color color) {
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

  @override
  void initState() {
    _currentColor = _intToColor(widget.startColor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Container(
              width: 50,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  elevation: 5,
                  primary: _currentColor,
                ),
                child: Container(width: 0, height: 0),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Select a color',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        content: SingleChildScrollView(
                          child: Container(
                            width: 400,
                            height: 100,
                            child: BlockPicker(
                              availableColors: widget._availableColors,
                              pickerColor: _currentColor,
                              onColorChanged: (color) {
                                setState(
                                  () {
                                    _currentColor = color;
                                    Navigator.of(context).pop();
                                  },
                                );
                                widget.handler(_colorToInt(color));
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
