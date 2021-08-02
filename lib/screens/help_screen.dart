import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/text_styles.dart';

class HelpScreen extends StatefulWidget {
  static const routeName = '/help_screen';
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String pdfPath = "";
  var isReady = false;
  Future<File> fromAsset(String asset, String filename) async {
    Completer<File> completer = Completer();
    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  void initState() {
    print('<help screen init>');
    fromAsset('assets/pdf/manual.pdf', 'manual.pdf').then((f) {
      setState(() {
        pdfPath = f.path;
        isReady = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Help',
          style: TextStyles.appBarTextStyle,
        ),
      ),
      body: Center(
        child: isReady
            ? PDFView(
                filePath: pdfPath,
                // enableSwipe: true,
                // pageFling: true,
              )
            : Center(
                child: Text(
                  'No pdf document found!',
                  style: TextStyles.textGrey,
                ),
              ),
      ),
    );
  }
}
