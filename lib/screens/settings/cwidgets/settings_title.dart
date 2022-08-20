import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsTitle extends StatelessWidget {
  final String title;

  const SettingsTitle(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(
          right: 16,
          bottom: 8,
          top: 8,
        ),
        child: Opacity(
          opacity: .7,
          child: Text(title.toUpperCase(),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ));
  }
}
