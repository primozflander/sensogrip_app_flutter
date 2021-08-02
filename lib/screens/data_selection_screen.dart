import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/data_item.dart';
import '../providers/users_provider.dart';
import '../models/text_styles.dart';
import '../models/data.dart';
import '../helpers/sql_helper.dart';
import '../helpers/firebase_cloud_helper.dart';
import '../helpers/functions.dart';

enum FilteredOptions {
  CurrentUser,
  All,
}

class DataSelectionScreen extends StatefulWidget {
  static const routeName = '/data_selection_screen';

  final Data selectedData;
  DataSelectionScreen(this.selectedData);

  @override
  _DataSelectionScreenState createState() => _DataSelectionScreenState();
}

class _DataSelectionScreenState extends State<DataSelectionScreen> {
  List<Data> _data = [];
  List<Data> _filteredData = [];
  bool _isLoading = false;
  ScrollController _controller = ScrollController(keepScrollOffset: true);
  double _scrollOffset;

  Future<void> _startTransferToCLoud() async {
    setState(() {
      _isLoading = true;
    });
    final String deviceId = await Functions.getDeviceId();
    print('device id: $deviceId');
    final response =
        await FirebaseCloudHelper.transferDataListToCloud(deviceId, _data);
    setState(() {
      _isLoading = false;
    });
    print('response $response');
    response
        ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).checkConnectionN)))
        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).transferToCloudN)));
  }

  void _getDataFromDatabase() async {
    List<Data> dataFromDb = await SqlHelper.getData();
    setState(
      () {
        _data = dataFromDb;
        _filteredData = _data;
      },
    );
  }

  // Future<void> _getPrevScrollIndex() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var index = prefs.getDouble('dataScrollIndex');
  //   if (index != null) {
  //     print('dataindex ------------> $index');
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       _controller.jumpTo(index);
  //     });
  //   }
  // }

  void _setDataFocus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var index = prefs.getDouble('dataScrollIndex');
    if (index != null) {
      print('dataindex ------------> $index');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          print('$index -------------->Success');
          _controller.jumpTo(index);
        }
      });
    }
  }

  void _saveScrollOffset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('dataScrollIndex', _scrollOffset);
    print('index saved-------------> $_scrollOffset');
  }

  void _deleteData(Data data) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(
              AppLocalizations.of(context).deleteData,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            content: Text(AppLocalizations.of(context).deleteDataQ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context).no)),
              TextButton(
                  onPressed: () {
                    SqlHelper.deleteDataWhereId(data.id)
                        .then((_) => _getDataFromDatabase());
                    Navigator.of(context).pop(true);
                  },
                  child: Text(AppLocalizations.of(context).yes)),
            ],
          ) ??
          false,
    );
  }

  @override
  void initState() {
    //SqlHelper.deleteDb('sensogrip');
    print('<data selection screen init>');
    _getDataFromDatabase();
    _setDataFocus();
    // _getPrevScrollIndex();
    _controller = ScrollController()
      ..addListener(() {
        _scrollOffset = _controller.offset;
        print(
            "offset = ${_controller.offset},${_controller.initialScrollOffset}");
      });

    super.initState();
  }

  TextStyle headerStyle = TextStyle(fontSize: 18, color: Colors.white);

  Widget _buildHeader() {
    return Container(
      height: 60,
      color: Colors.black87,
      child: Row(
        children: [
          SizedBox(width: 30),
          Container(
              width: 235,
              alignment: Alignment.centerLeft,
              child:
                  Text(AppLocalizations.of(context).user, style: headerStyle)),
          Container(
              width: 160,
              alignment: Alignment.center,
              child: Text('Id', style: headerStyle)),
          Container(
              width: 195,
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context).protocol,
                  style: headerStyle)),
          Container(
              width: 210,
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context).pencilName,
                  style: headerStyle)),
          Container(
              width: 170,
              alignment: Alignment.center,
              child:
                  Text(AppLocalizations.of(context).date, style: headerStyle)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).selectDataToDisplay,
          style: TextStyles.appBarTextStyle,
        ),
        actions: [
          _isLoading
              ? Center(
                  widthFactor: 1.6,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  onPressed: _startTransferToCLoud),
          PopupMenuButton(
            onSelected: (FilteredOptions selectedValue) {
              setState(
                () {
                  final userid =
                      Provider.of<UsersProvider>(context, listen: false)
                          .selectedUser
                          .id;
                  if (selectedValue == FilteredOptions.All) {
                    _filteredData = _data;
                  } else {
                    _filteredData = _data
                        .where((element) => element.userid == userid)
                        .toList();
                  }
                },
              );
              print(selectedValue);
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(AppLocalizations.of(context).currentUser),
                value: FilteredOptions.CurrentUser,
              ),
              PopupMenuItem(
                child: Text(AppLocalizations.of(context).showAllUsers),
                value: FilteredOptions.All,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Container(
            height: size.height - 130,
            child: ListView.builder(
              controller: _controller,
              itemCount: _filteredData.length,
              // restorationId: 'index',
              // reverse: true,
              // key: PageStorageKey<String>('dataSelectionList'),
              itemBuilder: (ctx, i) => DataItem(
                  _filteredData[_filteredData.length - 1 - i],
                  (_filteredData[_filteredData.length - 1 - i].id ==
                          widget.selectedData.id)
                      ? true
                      : false,
                  _deleteData,
                  _saveScrollOffset),
            ),
          ),
        ],
      ),
    );
  }
}
