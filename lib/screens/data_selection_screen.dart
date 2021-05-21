import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    print('init data select screen');
    _getDataFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: CircularProgressIndicator(
                    color: Colors.white,
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
      body: Container(
        height: 700,
        child: ListView.builder(
          itemCount: _filteredData.length,
          itemBuilder: (ctx, i) => DataItem(
              _filteredData[i],
              (_filteredData[i].id == widget.selectedData.id) ? true : false,
              _deleteData),
        ),
      ),
    );
  }
}
