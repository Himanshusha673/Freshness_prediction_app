import 'package:flutter/material.dart';
import 'package:qzenesapp/screens/home.dart';

class LodingInd extends StatefulWidget {
  const LodingInd({Key? key}) : super(key: key);

  @override
  State<LodingInd> createState() => _LodingIndState();
}

class _LodingIndState extends State<LodingInd> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(),
        child: Dialog(
            backgroundColor: Colors.white,
            elevation: 2,
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: primaryColor,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      ' Loading...',
                      style: TextStyle(color: primaryColor),
                    )
                  ]),
            )),
      ),
    );
  }
}
