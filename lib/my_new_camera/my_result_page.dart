import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qzapp/camerapage.dart';

class MyResultPage extends StatefulWidget {
  MyResultPage({Key? key}) : super(key: key);

  @override
  State<MyResultPage> createState() => MyResultPageState();
}

class MyResultPageState extends State<MyResultPage> {
  String? imagePath = '';
  bool imageIsNotNull = true;
  void clearCache() async {
    var appDir = (await getTemporaryDirectory()).path;
    Directory(appDir).delete(recursive: true);
    debugPrint('Cache Cleared!');
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments ??
        <String, String>{}) as Map;
    imagePath = args['path'];
    var size = args['size'];
    List<CameraDescription> cameras = args['cameras'];
    File? imagexFile = args['imageFile'];
    if (imagePath == null) {
      imageIsNotNull = false;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                clearCache();

                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: imageIsNotNull
            ? Column(
                children: [
                  Container(
                    height: size.width,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(),
                    child: Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )
            : Center(child: Text('No Image is Selcted')),
      ),
    );
  }
}
