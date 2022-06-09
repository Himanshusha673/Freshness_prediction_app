import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qzapp/camerapage.dart';

import 'home.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  void clearCache() async {
    var appDir = (await getTemporaryDirectory()).path;
    Directory(appDir).delete(recursive: true);
    debugPrint('Cache Cleared!');
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, String>{}) as Map;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff0c343d),
          centerTitle: true,
          titleTextStyle: const TextStyle(fontSize: 18),
          title: const Text('Results'),
          toolbarHeight: 60,
        ),
        body: Center(
          child: Column(
            children: [
              SquareCroppedImage(path: arguments['imagePath']),
              /////////////////// UNCOMMENT THIS IF THE IMAGE IS NOT in the 1:1 size and comment the SQUARE CROP WIDGET
              // SizedBox(
              //   height: MediaQuery.of(context).size.width,
              //   width: MediaQuery.of(context).size.width,
              //   child: ClipRect(
              //     child: FittedBox(
              //       alignment: Alignment.bottomCenter,
              //       fit: BoxFit.fitWidth,
              //       child: Image.file(
              //         File(arguments['imagePath']),
              //       ),
              //     ),
              //   ),
              // ),
              Expanded(
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      arguments['predictionResults'],
                      style: const TextStyle(fontSize: 30),
                    ),
                    IndicatorIcon(
                        R: arguments['R'], G: arguments['G'], B: arguments['B'])
                  ],
                )),
              ),
              GestureDetector(
                onTap: () {
                  arguments['setcamon']();
                  Navigator.pop(context);
                  clearCache();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Container(
                      decoration: BoxDecoration(
                          color: primaryColor,
                          border: Border.all(color: primaryColor, width: 5),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Icon(
                        Icons.refresh,
                        size: 40,
                        color: Colors.white,
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SquareCroppedImage extends StatelessWidget {
  final String path;
  const SquareCroppedImage({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.file(File(path));
  }
}
