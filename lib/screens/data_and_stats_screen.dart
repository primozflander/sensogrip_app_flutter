import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/chart_with_statistics.dart';
import '../models/text_styles.dart';
import '../models/data.dart';
import '../helpers/sql_helper.dart';

enum DisplayOptions {
  SingleChart,
  TwoCharts,
  AllCharts,
}

class DataAndStatsScreen extends StatefulWidget {
  static const routeName = '/data_and_stats_screen';
  @override
  _DataAndStatsScreenState createState() => _DataAndStatsScreenState();
}

class _DataAndStatsScreenState extends State<DataAndStatsScreen> {
  int _chartMode = 0;
  List<Data> _data;
  ScrollController _controller = ScrollController(keepScrollOffset: true);

  void _getDataFromDatabase() async {
    List<Data> dataFromDb = await SqlHelper.getData();
    setState(
      () {
        _data = dataFromDb;
        print("data from db: $_data");
        // print("data read from database");
      },
    );
  }

  @override
  void initState() {
    print('init data and stats screen');
    _getDataFromDatabase();
    super.initState();
  }

  Widget _buildNoDataAvailableText() {
    return Center(
      child: Container(
        child: Text(
          AppLocalizations.of(context).noDataToDisplay,
          style: TextStyles.textGrey,
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_chartMode) {
      case 0:
        {
          return ChartWithStatistics(_chartMode);
        }
        break;

      case 1:
        {
          return Column(
            children: [
              ChartWithStatistics(_chartMode),
              ChartWithStatistics(_chartMode)
            ],
          );
        }
        break;

      default:
        {
          return ListView.builder(
            controller: _controller,
            itemCount: _data.length,
            // reverse: true,
            itemBuilder: (ctx, i) => ChartWithStatistics(_chartMode, i),
          );
        }
        break;
    }
  }

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
                    _chartMode = 0;
                  } else if (selectedValue == DisplayOptions.TwoCharts) {
                    _chartMode = 1;
                  } else
                    _chartMode = 2;
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
              PopupMenuItem(
                child: Text(AppLocalizations.of(context).allCharts),
                value: DisplayOptions.AllCharts,
              ),
            ],
          ),
        ],
      ),
      body: _data == null ? _buildNoDataAvailableText() : _buildChart(),
    );
  }
}
