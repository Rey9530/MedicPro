import 'package:flutter/material.dart';
import 'package:medicpro/src/models/expedientes_model.dart';
import 'package:medicpro/src/themes/theme.dart';

class Preselected extends StatelessWidget {
  UserModel item;
  String string;
  Preselected(this.item, this.string);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (item.avatar == null)
          ? ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                backgroundColor: temaApp.primaryColor,
              ),
              title: Text("Seleccione..."),
            )
          : ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                backgroundColor: temaApp.primaryColor,
                backgroundImage: NetworkImage(item.avatar),
              ),
              title: Text(item.name),
              subtitle: Text(item.celular),
            ),
    );
  }
}

class YaSelected extends StatelessWidget {
  bool isSelected;
  UserModel item;

  YaSelected(this.item, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item.name),
        subtitle: Text(item.celular),
        leading: CircleAvatar( 
          backgroundColor: temaApp.primaryColor,
          backgroundImage: NetworkImage(item.avatar),
        ),
      ),
    );
  }
}
