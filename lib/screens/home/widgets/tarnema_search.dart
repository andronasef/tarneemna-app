import 'package:flutter/material.dart';

import '../home_controller.dart';

class TarnemaSearch extends StatelessWidget {
  const TarnemaSearch({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          hintText: "مثال: انا شاعر بيك",
          hintStyle: const TextStyle(color: Colors.black26),
          prefixIcon: IconButton(
            onPressed: () async => controller.query(controller.songText.text),
            icon: const Icon(Icons.search),
          ),
          suffixIcon: IconButton(
              onPressed: () => controller.songText.clear(),
              icon: const Icon(Icons.clear))),
      controller: controller.songText,
      onSubmitted: (value) async => controller.query(value),
    );
  }
}
