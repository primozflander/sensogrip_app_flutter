import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/chart_with_statistics.dart';
import '../models/text_styles.dart';

enum DisplayOptions {
  SingleChart,
  TwoCharts,
}

class DataAndStatsScreen extends StatefulWidget {
  static const routeName = '/data_and_stats_screen';
  @override
  _DataAndStatsScreenState createState() => _DataAndStatsScreenState();
}

class _DataAndStatsScreenState extends State<DataAndStatsScreen> {
  bool _singleChart = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).dataAndStats,
          style: TextStyles.appBarTextStyle,
        ),
        actions: [
          PopupMenuButton(
            onSelected: (DisplayOptions selectedValue) {
              setState(
                () {
                  if (selectedValue == DisplayOptions.SingleChart) {
                    _singleChart = true;
                  } else {
                    _singleChart = false;
                  }
                },
              );
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(AppLocalizations.of(context).singleChart),
                value: DisplayOptions.SingleChart,
              ),
              PopupMenuItem(
                child: Text(AppLocalizations.of(context).twoCharts),
                value: DisplayOptions.TwoCharts,
              ),
            ],
          ),
        ],
      ),
      body: _singleChart
          ? ChartWithStatistics(isSmall: false)
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChartWithStatistics(isSmall: true),
                ChartWithStatistics(isSmall: true),
              ],
            ),
    );
  }
}
