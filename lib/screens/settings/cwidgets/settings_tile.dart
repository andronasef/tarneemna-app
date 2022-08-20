import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final IconData? icon;
  final Function()? action;
  final String? title;

  const SettingsListTile({Key? key, this.icon, this.action, this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title!),
      leading: Icon(icon),
      onTap: () => action!(),
    );
  }
}
