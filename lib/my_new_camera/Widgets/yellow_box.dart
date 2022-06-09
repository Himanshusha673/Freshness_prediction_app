import 'package:flutter/material.dart';

class YellowBox extends StatelessWidget {
  final double X;
  const YellowBox({Key? key, required this.X}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: X * 0.7,
          height: X * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.yellow, width: 3),
          )),
    );
  }
}
