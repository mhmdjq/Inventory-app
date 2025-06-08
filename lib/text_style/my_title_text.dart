import 'package:flutter/material.dart';

class MyTitleText extends StatelessWidget {
  const MyTitleText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
    );
  }
}
