import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/data.dart';
import '../providers/users_provider.dart';

class DataItem extends StatelessWidget {
  final Data data;
  final bool isSelected;
  final Function deleteData;

  DataItem(this.data, this.isSelected, this.deleteData);

  void _selectData(context) async {
    print('Data selected ${data.userid}');
    Navigator.pop(context, data);
  }

  Widget _buildDataBody(Data data) {
    return Row(
      children: [
        Container(
            width: 100, alignment: Alignment.center, child: Text('${data.id}')),
        Container(
            width: 250,
            alignment: Alignment.center,
            child: Text(data.description)),
        Container(
            width: 160,
            alignment: Alignment.center,
            child: Text(data.pencilname)),
        Container(
            width: 225,
            alignment: Alignment.center,
            child: Text(data.timestamp)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final users = Provider.of<UsersProvider>(context, listen: false).users;
    return InkWell(
      onTap: () => _selectData(context),
      //borderRadius: BorderRadius.circular(15),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 2,
        child: ListTile(
          minVerticalPadding: 30,
          minLeadingWidth: 190,
          selected: isSelected,
          // selectedTileColor: Colors.grey.shade200,
          leading: Chip(
            padding: EdgeInsets.all(10),
            label: Text(
              // '${(users.where((user) => user.id == data.userid)).first.name}',
              '${data.username}',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          title: _buildDataBody(data),
          // subtitle: Text('Id: ${data.id}'),
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              size: 30,
            ),
            color: Theme.of(context).errorColor,
            onPressed: () => deleteData(data),
          ),
        ),
      ),
    );
  }
}
