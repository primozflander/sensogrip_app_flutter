import 'package:flutter/material.dart';

import '../models/data.dart';

class DataItem extends StatelessWidget {
  final Data data;
  final bool isSelected;
  final Function deleteData;
  final Function saveScrollOffset;

  DataItem(this.data, this.isSelected, this.deleteData, this.saveScrollOffset);

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
        Container(
            width: 110,
            alignment: Alignment.center,
            child: data.videofile.isNotEmpty
                ? Icon(Icons.video_library)
                : Container()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _selectData(context);
        saveScrollOffset();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: isSelected
              ? BorderSide(color: Colors.blue, width: 2)
              : BorderSide.none,
        ),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 2,
        child: ListTile(
          minVerticalPadding: 30,
          minLeadingWidth: 250,
          leading: Chip(
            padding: EdgeInsets.all(10),
            label: Text(
              data.username,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          title: _buildDataBody(data),
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
