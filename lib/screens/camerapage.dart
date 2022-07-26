import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:io';

// import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:qzenesapp/constants.dart';
import 'package:qzenesapp/screens/home.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/Linksfooter.dart';
import '../widgets/logout.dart';

class CameraApp extends StatefulWidget {
  String mlModel = '';
  String part = '';

  CameraApp({Key? key, required this.mlModel, required this.part})
      : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  bool cameraOn = true;
  // String mlModel = 'BANANA';
  // String part = 'BANANA';

  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iosInformation;
  late int R, G, B;
  dynamic size;
  bool isRightHanded = true;

  ////////////////////
  ///
  XFile? imageFile;

  bool isBanana = false;

  // bool notCropped = false;
  File? croppedImage;
  int predictionNumeric = -1;
  bool flashOn = false;

  String myImagePath = '',
      predictionResult = '',
      hour = 'CAM_TEST',
      details = '';
  Map<String, String> suffix = {'BANANA': 'Type', 'FISH': 'Freshness'};
  List<String> goMicro = ['0', '20', '40', '60', '80', '100', 'CAM_TEST'];

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      deviceInfoPlugin.androidInfo
          .then((value) => setState(() => {androidInfo = value}));
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    debugPrint(widget.mlModel);
  }

  void setCameraOn() {
    setState(() {
      cameraOn = true;
    });
  }

  Future<http.StreamedResponse> uploadImage(
      filepath, deviceModel, brand, mlModel, part, hour, flash) async {
    // String url = "http://127.0.0.1:8000/post/";
    String url = 'http://mobileapi.qzenselabs.com:8000/post/';
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

  // calling the api and we sent the path only and it takes all necessary parameters which are need to use in uploadimage

  void _apiCallSetStates(String path) {
    debugPrint("api caling");
    setState(() {
      cameraOn = false;
    });

    uploadImage(path, androidInfo.model, androidInfo.brand, widget.mlModel,
            widget.part, hour, flashOn)
        .then((value) => {
              debugPrint('first REs VALUE : $value'),
              value.stream
                  .bytesToString()
                  .then((value) => {
                        debugPrint(
                            'type of second value : ${value.runtimeType}'),
                        debugPrint('seconD REs VALUE : $value'),
                        debugPrint(jsonDecode(value).toString()),
                        setState(() => {
                              // set prediction results
                              myImagePath = path,
                              predictionResult = jsonDecode(value)['result'],
                              details = jsonDecode(value)['action'],

                              predictionNumeric =
                                  jsonDecode(value)['numericVal'],

                              // set RGB values
                              R = jsonDecode(value)['R'],
                              G = jsonDecode(value)['G'],
                              B = jsonDecode(value)['B'],
                              cameraOn = true,
                            }),
                        Navigator.pushNamed(context, Result_Page, arguments: {
                          'mlModel': widget.mlModel,
                          'details': details,
                          'part': widget.part,
                          'R': R,
                          'G': G,
                          'B': B,
                          'predictionResults': predictionResult,
                          'imagePath': myImagePath
                        })
                      })
                  .catchError((e) {
                setState(() {
                  predictionResult = '**Something went wrong**';
                  R = 255;
                  G = 255;
                  B = 255;
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
              })
            })
        .catchError((e) {
      setState(() {
        predictionResult = '**Something went wrong**';
        R = 255;
        G = 255;
        B = 255;
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
        predictionResult = '**Something went wrong**';
        R = 255;
        G = 255;
        B = 255;
      });
      Navigator.pushNamed(context, Result_Page, arguments: {
        'mlModel': widget.mlModel,
        'part': widget.part,
        'details': details,
        'R': R,
        'G': G,
        'B': B,
        'predictionResults': predictionResult,
        'imagePath': myImagePath
      });
    });
  }

  Future<void> _removeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    prefs
        .remove('email')
        .then((value) => {debugPrint('email removed : $value')});
    prefs
        .remove('token')
        .then((value) => {debugPrint('Token removed : $value')});
    debugPrint('Removed Email and Token credentials from Local Storage!');
  }

  //////////////////////////////////////////////////////////
  ///////////////////////////////
  void _getImage(ImageSource source) async {
    try {
      setState(() {
        cameraOn = false;
      });

      XFile? imageXfile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 50,
      );
      if (imageXfile == null) {
        setState(() {
          cameraOn = true;
        });
      }
      debugPrint('$imageXfile');

      File tempImage = File(imageXfile!.path);
      var decodedImage = await decodeImageFromList(tempImage.readAsBytesSync());
      if (decodedImage.height != decodedImage.width) {
        croppedImage = await ImageCropper().cropImage(
            sourcePath: imageXfile.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 700,
            maxHeight: 700,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              lockAspectRatio: true,
            ));
        if (croppedImage == null) {
          setState(() {
            cameraOn = true;
          });
        }

        _apiCallSetStates(croppedImage!.path);
        setState(() {
          myImagePath = croppedImage!.path;
          cameraOn = false;
        });
      } else {
        _apiCallSetStates(imageXfile.path);
        setState(() {
          myImagePath = imageXfile.path;
          cameraOn = false;
        });
      }
    } catch (e) {
      debugPrint('error Message is ${e.toString()}');
    }
  }

  /////////////////////////
  /////////////////////////////////////////////
  //////////////

/////////////////////////////////////////////////////

  @override
  build(BuildContext context) {
    size = MediaQuery.of(context).size;

    // fetch screen size

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // This below Code is For Bottom Sheet OF Image Picker
    // ImagePicker Optionb
    // void imagePickerOption() {
    //   if (cameraOn == true) {
    //     Get.bottomSheet(
    //       SingleChildScrollView(
    //         child: ClipRRect(
    //           borderRadius: const BorderRadius.only(
    //             topLeft: Radius.circular(10.0),
    //             topRight: Radius.circular(10.0),
    //           ),
    //           child: Container(
    //             color: Colors.white,
    //             height: 250,
    //             child: Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
    //                 children: [
    //                   const Text(
    //                     "Pic Image From",
    //                     style: TextStyle(
    //                         fontSize: 20, fontWeight: FontWeight.bold),
    //                     textAlign: TextAlign.center,
    //                   ),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   ElevatedButton.icon(
    //                     onPressed: () async {
    //                       if (cameraOn) {
    //                         _getImage(ImageSource.camera);
    //                         Get.back();
    //                         setState(() {
    //                           cameraOn = false;
    //                         });
    //                       } else {
    //                         setState(() =>
    //                             {myImagePath = '', predictionResult = ""});
    //                       }
    //                     },
    //                     icon: const Icon(Icons.camera),
    //                     label: const Text("CAMERA"),
    //                   ),
    //                   ElevatedButton.icon(
    //                     onPressed: () async {
    //                       if (cameraOn) {
    //                         _getImage(ImageSource.gallery);
    //                         Get.back();
    //                         setState(() {
    //                           cameraOn = false;
    //                         });
    //                       } else {
    //                         setState(() =>
    //                             {myImagePath = '', predictionResult = ""});
    //                       }
    //                     },
    //                     icon: const Icon(Icons.image),
    //                     label: const Text("GALLERY"),
    //                   ),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   ElevatedButton.icon(
    //                     onPressed: () {
    //                       Get.back();
    //                     },
    //                     icon: const Icon(Icons.close),
    //                     label: const Text("CANCEL"),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     );
    //   } else {
    //     Center(child: CircularProgressIndicator());
    //   }
    // }

    if (widget.mlModel == 'BANANA') {
      setState(() {
        isBanana = true;
      });
    }

    return WillPopScope(
        onWillPop: () async => true,
        child: SafeArea(
          child: Stack(
            children: [
              cameraOn
                  ? Scaffold(
                      // floatingActionButton: FloatingActionButton(
                      //     autofocus: true,
                      //     focusColor: Colors.white,
                      //     hoverColor: primaryColor,
                      //     foregroundColor: Colors.white,
                      //     splashColor: Colors.purple,
                      //     onPressed: () {
                      //       if (cameraOn) {
                      //         _getImage(ImageSource.camera);

                      //         setState(() {});
                      //       } else {
                      //         setState(() =>
                      //             {myImagePath = '', predictionResult = ""});
                      //       }
                      //     },
                      //     backgroundColor: primaryColor,
                      //     child: Icon(
                      //       Icons.camera_alt_sharp,
                      //       size: 30,
                      //     )),
                      // bottomNavigationBar: SizedBox(
                      //   height: 85,
                      //   child: Container(
                      //     // decoration: BoxDecoration(
                      //     //     borderRadius: BorderRadius.only(
                      //     //         topLeft: Radius.circular(30),
                      //     //         topRight: Radius.circular(30))),
                      //     child: ClipRRect(
                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(15),
                      //           topRight: Radius.circular(15)),
                      //       child: BottomAppBar(
                      //           notchMargin: 6.5,
                      //           color: primaryColor,
                      //           shape: CircularNotchedRectangle(),
                      //           child: Row(
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceAround,
                      //             children: [
                      //               IconButton(
                      //                 onPressed: () {
                      //                   if (cameraOn) {
                      //                     _getImage(ImageSource.gallery);
                      //                   } else {
                      //                     setState(() => {
                      //                           myImagePath = '',
                      //                           predictionResult = ""
                      //                         });
                      //                   }
                      //                 },
                      //                 icon: Icon(
                      //                   Icons.image_outlined,
                      //                   color:
                      //                       Color.fromARGB(255, 236, 139, 11),
                      //                 ),
                      //                 iconSize: 40,
                      //               ),
                      //               isBanana
                      //                   ? IconButton(
                      //                       onPressed: () {
                      //                         if (cameraOn) {
                      //                           _getImage(ImageSource.camera);

                      //                           setState(() {});
                      //                         } else {
                      //                           setState(() => {
                      //                                 myImagePath = '',
                      //                                 predictionResult = ""
                      //                               });
                      //                         }
                      //                       },
                      //                       icon: FaIcon(
                      //                         Icons.camera_alt,
                      //                         color: Color.fromARGB(
                      //                             255, 236, 139, 11),
                      //                         size: 40,
                      //                       ))
                      //                   : PopupMenuButton<String>(
                      //                       icon: const FaIcon(
                      //                         FontAwesomeIcons.ellipsisVertical,
                      //                         color: Colors.white,
                      //                         size: 40,
                      //                       ),
                      //                       onSelected: (val) {
                      //                         setState(() {
                      //                           hour = val;
                      //                           debugPrint(hour);
                      //                         });
                      //                       },
                      //                       itemBuilder:
                      //                           (BuildContext context) {
                      //                         return goMicro
                      //                             .map((String choice) {
                      //                           return PopupMenuItem<String>(
                      //                             value: choice,
                      //                             child: Text(choice),
                      //                           );
                      //                         }).toList();
                      //                       },
                      //                     ),
                      //             ],
                      //           )),
                      //     ),
                      //   ),
                      // ),
                      appBar: AppBar(
                        backgroundColor: primaryColor,
                        //leading: MyLogoutButton(isIconButton: true),
                        centerTitle: true,

                        title: isBanana
                            ? Text('Predict ${widget.mlModel} Stages',
                                style: TextStyle(fontSize: 18))
                            : Text(
                                'Predict ${widget.mlModel} ${suffix[widget.mlModel]} (${widget.part})',
                                style: TextStyle(fontSize: 18),
                              ),

                        //actions: [Image.asset('images/assets/Le_Marche.png')],
                        toolbarHeight: 60,
                      ),
                      backgroundColor: Colors.white,
                      body:
                          // Container(
                          //   decoration: BoxDecoration(
                          //     gradient: LinearGradient(
                          //         begin: Alignment.topRight,
                          //         end: Alignment.bottomLeft,
                          //         colors: [
                          //           Color.fromARGB(255, 103, 199, 204),
                          //           Color.fromARGB(255, 238, 127, 131),
                          //           Color.fromARGB(255, 241, 121, 167),
                          //           Color.fromARGB(255, 214, 139, 243),
                          //           Color.fromARGB(255, 132, 202, 214),
                          //         ],
                          //         stops: [
                          //           0.1,
                          //           0.4,
                          //           0.6,
                          //           0.8,
                          //           1
                          //         ]),
                          //   ),
                          //   child:
                          Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container(
                          //   width: MediaQuery.of(context).size.width,
                          //   height: 80,
                          //   decoration: BoxDecoration(
                          //       color: const Color.fromARGB(31, 51, 49, 49),
                          //       borderRadius: BorderRadius.only(
                          //           bottomLeft: Radius.circular(15),
                          //           bottomRight: Radius.circular(15))),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //     children: [
                          //       const SizedBox(width: 8),
                          //       MyLogoutButton(isIconButton: true),
                          //       const SizedBox(
                          //         width: 8,
                          //       ),
                          //       SizedBox(
                          //           height: 85,
                          //           width: 150,
                          //           child: Image.asset(
                          //             'images/assets/Le_Marche.png',
                          //             fit: BoxFit.contain,
                          //           )),
                          //       const SizedBox(
                          //         width: 6,
                          //       )
                          //     ],
                          //   ),
                          // ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.width * 0.4,
                                  left: MediaQuery.of(context).size.width * 0.3,
                                  right:
                                      MediaQuery.of(context).size.width * 0.3),
                              child: SizedBox.fromSize(
                                  size: Size(150, 150),
                                  child: ClipOval(
                                      child: Material(
                                          color: Color.fromRGBO(14, 80, 95, 1),
                                          child: InkWell(
                                              splashColor:
                                                  Colors.deepOrangeAccent,
                                              onTap: () {
                                                if (cameraOn) {
                                                  _getImage(
                                                      ImageSource.gallery);

                                                  setState(() {});
                                                } else {
                                                  setState(() => {
                                                        myImagePath = '',
                                                        predictionResult = ""
                                                      });
                                                }
                                              },
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text('Gallery',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Icon(Icons.image,
                                                        size: 50,
                                                        color: Colors.white),
                                                  ])))))),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.width * 0.15,
                                  left: MediaQuery.of(context).size.width * 0.3,
                                  right:
                                      MediaQuery.of(context).size.width * 0.3),
                              child: SizedBox.fromSize(
                                  size: Size(150, 150),
                                  child: ClipOval(
                                      clipBehavior: Clip.antiAlias,
                                      child: Material(
                                          color: Color.fromRGBO(14, 80, 95, 1),
                                          child: InkWell(
                                              splashColor:
                                                  Colors.deepOrangeAccent,
                                              onTap: () {
                                                if (cameraOn) {
                                                  _getImage(ImageSource.camera);

                                                  setState(() {});
                                                } else {
                                                  setState(() => {
                                                        myImagePath = '',
                                                        predictionResult = ""
                                                      });
                                                }
                                              },
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text('Take a Snap',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Icon(Icons.camera_alt,
                                                        size: 50,
                                                        color: Colors.white),
                                                  ])))))),
                          const MySocialFooter(),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.120,
                                right:
                                    MediaQuery.of(context).size.width * 0.120),
                            child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.1),
                          )
                        ],
                      ),

                      // : Container(
                      //     child: Center(
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           CircularProgressIndicator(
                      //             color: primaryColor,
                      //           ),
                      //           SizedBox(
                      //             height: 10,
                      //           ),
                      //           Text(
                      //             'Loading...',
                      //             style: TextStyle(
                      //                 fontWeight: FontWeight.bold,
                      //                 color: primaryColor),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                    )
                  : Center(
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
                    )
            ],
          ),
        ));
  }
}

class CameraFooter extends StatefulWidget {
  const CameraFooter({Key? key}) : super(key: key);

  @override
  State<CameraFooter> createState() => _CameraFooterState();
}

class _CameraFooterState extends State<CameraFooter> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
