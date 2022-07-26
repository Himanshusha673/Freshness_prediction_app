import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'package:image_cropper/image_cropper.dart';
//import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

import '../widgets/LodingIndicator.dart';

bool autoSavedToGallery = false;
var primaryColor = const Color.fromRGBO(12, 52, 61, 1);

class ResultsPage extends StatefulWidget {
  String path = '', mlModel = '', part = '', details = '';

  late int R, B, G;
  String predictionResult = '';

  ResultsPage(
      {required this.path,
      required this.B,
      required this.G,
      required this.R,
      required this.predictionResult,
      required this.mlModel,
      required this.part,
      required this.details});

  @override
  State<ResultsPage> createState() => ResultsPageState();
}

class ResultsPageState extends State<ResultsPage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String cdate = DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now());

  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iosInformation;
  bool cameraOn = true;
  File? croppedImage;
  bool getBottom = true;

  var predictionNumeric;

  @override
  void initState() {
    super.initState();
    debugPrint('initialPAth:${widget.path}');
    resultPlatformState();
    debugPrint('initialPAth:${widget.path}');

    // debugPrint(widget.mlModel);
  }

  void clearCache() async {
    var appDir = (await getTemporaryDirectory()).path;
    Directory(appDir).delete(recursive: true);
    debugPrint('Cache Cleared!');
  }
  //////////////////////////////
  ///
  /// Method For Downloading File From Gallery
  ///
  ///

  bool isLoadig = false;

  downloadFile() async {
    setState(() {
      isLoadig = true;
      //getBottom = false;
    });
    //First method to download images and save it to Gallery
    try {
      await GallerySaver.saveImage(widget.path,
              albumName:
                  'Banana_Predictions/ ${widget.predictionResult} $cdate')
          .then((val) {
        if (val == true) {
          debugPrint('image Saved');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            dismissDirection: DismissDirection.down,
            content: Text('Image Saved TO Pictures'),
            backgroundColor: Colors.deepOrange,
            elevation: 6.0,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Something went wrong ',
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ));
        }
      }).whenComplete(() => {
                setState(() {
                  isLoadig = false;
                  //getBottom = true;
                })
              });
    } catch (e) {
      debugPrint(e.toString());
    }

// here Second Method to save it to Gallery
    // debugPrint('initialPAth:${widget.path}');

    // Uint8List bytes = await File(widget.path).readAsBytes();

    // try {
    //   //value return by saveImage:-->{filePath: content://media/external/images/media/8636, errorMessage: null, isSuccess: true}
    //   await ImageGallerySaver.saveImage(bytes,
    //       name: 'Banana_Predictions/ ${widget.predictionResult} $cdate');

    //     .then((val) {
    //   if (val['isSuccess'] == true) {
    //     debugPrint('image Saved');
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       dismissDirection: DismissDirection.down,
    //       content: Text('Image Saved TO Pictures'),
    //       elevation: 6.0,
    //       behavior: SnackBarBehavior.floating,
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(20))),
    //     ));
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       content: Text(
    //         'Something went wrong ',
    //       ),
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(20))),
    //     ));
    //   }
    // }).whenComplete(() => {
    //           setState(() {
    //             isLoadig = false;
    //             //getBottom = true;
    //           })
    //         });

    // } catch (e) {
    //   debugPrint(e.toString());
    // }
  }

  //////////////////////////////////////////////

  ////////////////////////////////////////////

  late bool notNUll;

  void _getImage() async {
    // debugPrint('$autoSavedToGallery');
    XFile? imageXfile;
    try {
      setState(() {
        cameraOn = false;
      });

      imageXfile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (imageXfile == null) {
        setState(() {
          notNUll == true;
          cameraOn = true;
        });
      }
      debugPrint('File is :$imageXfile');

      File tempImage = File(imageXfile!.path);
      var decodedImage = await decodeImageFromList(tempImage.readAsBytesSync());
      if (decodedImage.height != decodedImage.width) {
        croppedImage = await ImageCropper().cropImage(
            sourcePath: imageXfile.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 700,
            maxHeight: 700,
            compressFormat: ImageCompressFormat.png,
            androidUiSettings: AndroidUiSettings(
              lockAspectRatio: true,
            ));
        if (croppedImage == null) {
          setState(() {
            cameraOn = true;
          });
        } else {
          setState(() {
            widget.path = croppedImage!.path;
            cameraOn = true;
          });

          // _apiCallSetStates(croppedImage!.path);
          if (autoSavedToGallery) {
            downloadFile();
          }
        }

        // debugPrint('$autoSavedToGallery');

      } else {
        setState(() {
          widget.path = imageXfile!.path;
          cameraOn = true;
        });
        //_apiCallSetStates(imageXfile!.path);
        debugPrint('$autoSavedToGallery');

        if (autoSavedToGallery) {
          downloadFile();
        }
      }
    } catch (e) {
      debugPrint('error Message is ${e.toString()}');
    }
  }

  Future<http.StreamedResponse> uploadImage(
      filepath, deviceModel, brand, mlModel, part, hour, flash) async {
    // String url = "http://127.0.0.1:8000/post/";
    String url = 'http://mobileapi.qzenselabs.com:8000/postCFData/';
    var request = http.MultipartRequest('post', Uri.parse(url));
    // request.files.add(await http.MultipartFile.fromPath('capture', filepath,
    //     contentType: MediaType('application', 'x-tar')));
    request.files.add(await http.MultipartFile.fromPath('capture', filepath));
    request.fields['deviceModel'] = deviceModel;
    request.fields['mlModel'] = mlModel;
    request.fields['brand'] = brand;
    request.fields['part'] = part;
    request.fields['hour'] = hour;
    request.fields['flash'] = flash ? 1.toString() : 0.toString();

    ////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////

    ///if test is true, image wont be pushed to database on api, else pushed
    request.fields['test'] = 'False'; // DB PUSH BOOLEAN

    ////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////

    var res = await request.send();
    debugPrint("\nThe status code is : ${res.statusCode.toString()}");
    debugPrint("\nResponse Headers : ${res.headers.toString()}");
    debugPrint("\nThe Reason Phrase is : ${res.reasonPhrase.toString()}");
    return res;
  }

  Future<void> resultPlatformState() async {
    if (Platform.isAndroid) {
      deviceInfoPlugin.androidInfo
          .then((value) => setState(() => {androidInfo = value}));
    }
  }

  void _apiCallSetStates(path) {
    uploadImage(path, androidInfo.model, androidInfo.brand, "BANANA", "BANANA",
            "CAM_TEST", false)
        .then((value) => {
              debugPrint('first REs VALUE : $value'),
              value.stream
                  .bytesToString()
                  .then((value) => {
                        // if (autoSavedToGallery)
                        //   {
                        //     downloadFile(),
                        //   },
                        debugPrint(
                            'type of second value : ${value.runtimeType}'),
                        debugPrint('seconD REs VALUE : $value'),
                        debugPrint(jsonDecode(value).toString()),
                        setState(() {
                          widget.predictionResult = jsonDecode(value)['result'];
                          widget.details = jsonDecode(value)['action'];

                          predictionNumeric = jsonDecode(value)['numericVal'];

                          // set RGB values
                          widget.R = jsonDecode(value)['R'];
                          widget.G = jsonDecode(value)['G'];
                          widget.B = jsonDecode(value)['B'];
                          cameraOn = true;
                          widget.path = path;
                        }),

                        // Navigator.pushNamed(context, '/results', arguments: {
                        //   'setcamon': setCameraOn,
                        //   'R': R,
                        //   'G': G,
                        //   'B': B,
                        //   'predictionResults': predictionResult,
                        //   'imagePath': imagePath
                        // });
                      })
                  .catchError((e) {
                setState(() {
                  widget.predictionResult = '**Something went wrong**';
                  widget.R = 255;
                  widget.G = 255;
                  widget.B = 255;
                  cameraOn = true;
                });
                // Navigator.pushNamed(context, '/results', arguments: {
                //   'setcamon': setCameraOn,
                //   'R': R,
                //   'G': G,
                //   'B': B,
                //   'predictionResults': predictionResult,
                //   'imagePath': imagePath
                // });
              }).catchError((e) {
                setState(() {
                  widget.predictionResult = '**Something went wrong**';
                  widget.R = 255;
                  widget.G = 255;
                  widget.B = 255;
                });
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    widget.path == null ? notNUll = true : notNUll = false;
    //double deviceSize = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => true,
      child: cameraOn
          ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      clearCache();
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back)),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(top: 10, right: 10),
                    child: Stack(
                      children: [
                        Text('Auto Save ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        SizedBox(
                          height: 20,
                        ),
                        Switch(
                            activeColor: Colors.deepOrange,
                            value: autoSavedToGallery,
                            onChanged: (value) {
                              debugPrint('$autoSavedToGallery');
                              if (value) {
                                downloadFile();
                              }

                              setState(() {
                                autoSavedToGallery = value;
                              });
                              debugPrint('$autoSavedToGallery');
                            }),
                      ],
                    ),
                  ),
                ],
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff0c343d),
                centerTitle: true,
                titleTextStyle: const TextStyle(fontSize: 18),
                title: const Text('Results'),
                toolbarHeight: 60,
              ),
              extendBody: true,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterDocked,
              floatingActionButton: FloatingActionButton(
                focusColor: Colors.white,
                hoverColor: primaryColor,
                foregroundColor: Colors.white,
                splashColor: Colors.purple,
                onPressed: () {
                  clearCache();

                  _getImage();
                  debugPrint(' now PAth:${widget.path}');
                },
                backgroundColor: primaryColor,
                child: FaIcon(Icons.camera_alt_rounded),
              ),
              bottomNavigationBar: getBottom
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width * 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          child: BottomAppBar(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    SizedBox(
                                      height: 23,
                                    ),
                                    Text(widget.details,
                                        style: const TextStyle(
                                            fontSize: 17, color: Colors.white)),
                                    SizedBox(
                                      height: 22,
                                    ),
                                    const Text(
                                        ' * Result are Only Indicative To Aid Consumers ',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white)),
                                  ])),
                            ),
                            elevation: 2,
                            notchMargin: 6.5,
                            color: primaryColor,
                            shape: CircularNotchedRectangle(),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              body: Column(
                children: [
                  notNUll
                      ? Text('This is NUll')
                      : SquareCroppedImage(path: widget.path),
                  SizedBox(
                    height: 55,
                  ),
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.width * 0.4),
                        child: Container(
                          child: FittedBox(
                            child: Text(
                              notNUll ? 'Sorry.....' : widget.predictionResult,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.width * 0.4),
                        child: IndicatorIcon(
                            R: widget.R, G: widget.G, B: widget.B),
                      )
                    ],
                  ),

                  // GestureDetector(
                  //   onTap: () {
                  //     arguments['setcamon']();
                  //     Navigator.pop(context);
                  //     clearCache();
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(vertical: 40.0),
                  //     child: Container(
                  //         decoration: BoxDecoration(
                  //             color: primaryColor,
                  //             border: Border.all(color: primaryColor, width: 5),
                  //             borderRadius: BorderRadius.circular(20)),
                  //         child: const Icon(
                  //           Icons.refresh,
                  //           size: 40,
                  //           color: Colors.white,
                  //         )),
                  //   ),
                  // )
                ],
              ),
            )
          : const LodingInd(),
    );
  }
}

class SquareCroppedImage extends StatelessWidget {
  final String path;
  const SquareCroppedImage({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: FittedBox(child: Image.file(File(path))));
  }
}

class IndicatorIcon extends StatelessWidget {
  final int R, G, B;
  const IndicatorIcon(
      {Key? key, required this.R, required this.G, required this.B})
      : super(key: key);

  // IconData _getIcon(value) {
  //   if (value > 70) {
  //     return FontAwesomeIcons.circleCheck;
  //   } else if (value < 70 && value > 30) {
  //     return FontAwesomeIcons.circleStop;
  //   } else {
  //     return FontAwesomeIcons.circleXmark;
  //   }
  // }

  // Color _getColor(value) {
  //   if (value > 70) {
  //     return const Color.fromARGB(255, 0, 169, 6);
  //   } else if (value < 70 && value > 30) {
  //     return const Color.fromARGB(255, 173, 156, 2);
  //   } else {
  //     return const Color.fromARGB(255, 255, 17, 0);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      FontAwesomeIcons.solidCircle,
      color: Color.fromARGB(255, R, G, B),
      size: 40,
    );
  }
}
