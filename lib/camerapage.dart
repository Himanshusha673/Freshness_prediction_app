import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image/image.dart' as bdimg;
// import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:qzapp/home.dart';
import 'package:get/get.dart';

class CameraApp extends StatefulWidget {
  final List listOfCameras;
  const CameraApp({Key? key, required this.listOfCameras}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  bool cameraOn = true;
  late CameraController _controller;

  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iosInformation;
  late int R, G, B;
  var size;

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      deviceInfoPlugin.androidInfo
          .then((value) => setState(() => {androidInfo = value}));
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await _controller.setFlashMode(mode);
    } catch (e) {
      debugPrint('Camera FLASH MODE error!');
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _controller = CameraController(
        widget.listOfCameras[0], ResolutionPreset.medium,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
    //
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      setFlashMode(FlashMode.off);
    });
  }

  void onNewCameraSelected(CameraDescription description) {
    debugPrint('$description.toString()');
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      debugPrint('YOYOYOYO INACTIVE');
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_controller.description);
    } else {
      _controller.dispose();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<http.StreamedResponse> uploadImage(
      filepath, deviceModel, brand, mlModel, part, hour, flash) async {
    // String url = "http://127.0.0.1:8000/post/";
    String url =
        'http://ec2-3-110-68-246.ap-south-1.compute.amazonaws.com:8000/post/';
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

  Future<XFile> captureImage() async {
    return await _controller.takePicture();
  }

  int predictionNumeric = -1;

  String imagePath = '',
      predictionResult = '',
      mlModel = '',
      part = '',
      hour = 'CAM_TEST';
  Map<String, String> suffix = {'BANANA': 'Type', 'FISH': 'Freshness'};
  List<String> goMicro = ['0', '20', '40', '60', '80', '100', 'CAM_TEST'];
  bool flashOn = false;

  void _pickImageAndSetStates() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _apiCallSetStates(pickedImage.path);
      setState(() {
        imagePath = pickedImage.path;
        cameraOn = false;
      });
    } else {
      imagePath = "";
      cameraOn = true;
    }
  }

  void _apiCallSetStates(path) {
    uploadImage(path, androidInfo.model, androidInfo.brand, mlModel, part, hour,
            flashOn)
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
                              predictionResult = jsonDecode(value)['result'],
                              predictionNumeric =
                                  jsonDecode(value)['numericVal'],

                              if (flashOn)
                                {
                                  flashOn = !flashOn,
                                  setFlashMode(FlashMode.torch)
                                }
                              else
                                {setFlashMode(FlashMode.off)},
                              // set RGB values
                              R = jsonDecode(value)['R'],
                              G = jsonDecode(value)['G'],
                              B = jsonDecode(value)['B'],
                            }),
                        Navigator.pushNamed(context, '/results', arguments: {
                          'setcamon': setCameraOn,
                          'R': R,
                          'G': G,
                          'B': B,
                          'predictionResults': predictionResult,
                          'imagePath': imagePath
                        })
                      })
                  .catchError((e) {
                setState(() {
                  predictionResult = '**Something went wrong**';
                  R = 255;
                  G = 255;
                  B = 255;
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
      Navigator.pushNamed(context, '/results', arguments: {
        'setcamon': setCameraOn,
        'R': R,
        'G': G,
        'B': B,
        'predictionResults': predictionResult,
        'imagePath': imagePath
      });
    });
  }

  void setCameraOn() {
    setState(() {
      cameraOn = true;
    });
  }

  void cropImage(String path) async {
    debugPrint('THIS IS BRENDAN DUNCAN IMAGE CROP');
    var image = bdimg.decodeJpg(File(path).readAsBytesSync());
    debugPrint("IMAGE WIDTH : ${image!.width}");
    debugPrint("IMAGE HEIGHT : ${image.height}");
    var croppedimg = bdimg.copyCrop(
        image, 0, image.height - image.width, image.width, image.width);
    debugPrint("cropped IMAGE WIDTH : ${croppedimg.width}");
    debugPrint("cropped IMAGE HEIGHT : ${croppedimg.height}");
    File(path).writeAsBytesSync(bdimg.encodeJpg(croppedimg));
  }

  bool isRightHanded = true;
  ////////////////////
  XFile? imageFile;
  String? myImagePath = '';
  // bool notCropped = false;
  File? croppedImage;

  //////////////////////////////////////////////////////////
  ///////////////////////////////
  void _getImage(ImageSource source) async {
    // this.setState(() {
    //   cameraOn = true;
    //   notCropped = true;
    // });
    try {
      XFile? imageXfile = await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );
      // Image(image: FileImage(File(imageXfile!.path)))
      //     .image
      //     .resolve(ImageConfiguration())
      //     .addListener((ImageInfo info, bool _)  {
      //   int width = info.image.width;
      //   int height =  info.image.height;
      // });
      File tempImage = new File(imageXfile!.path);
      var decodedImage = await decodeImageFromList(tempImage.readAsBytesSync());
      if (decodedImage.height != decodedImage.width ||
          source == ImageSource.gallery) {
        if (imageXfile != null) {
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

          _apiCallSetStates(croppedImage!.path);
          setState(() {
            imagePath = croppedImage!.path;
            cameraOn = false;
          });
        } else {
          imagePath = "";
          cameraOn = true;
        }
      } else {
        if (imageXfile != null) {
          // croppedImage = await ImageCropper().cropImage(
          //     sourcePath: image.path,
          //     aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          //     compressQuality: 100,
          //     maxWidth: 700,
          //     maxHeight: 700,
          //     compressFormat: ImageCompressFormat.jpg,
          //     androidUiSettings: AndroidUiSettings(
          //       lockAspectRatio: true,
          //     ));

          _apiCallSetStates(imageXfile.path);
          setState(() {
            imagePath = imageXfile.path;
            cameraOn = false;
          });
        } else {
          imagePath = "";
          cameraOn = true;
        }
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

    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, String>{}) as Map;
    mlModel = arguments['model'];
    part = arguments['part'];

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // ImagePicker Optionb
    void imagePickerOption() {
      if (cameraOn == true) {
        Get.bottomSheet(
          SingleChildScrollView(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: Container(
                color: Colors.white,
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Pic Image From",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (cameraOn) {
                            _getImage(ImageSource.camera);
                            setState(() {
                              cameraOn = false;
                            });
                          } else {
                            setState(
                                () => {imagePath = '', predictionResult = ""});
                          }
                        },
                        icon: const Icon(Icons.camera),
                        label: const Text("CAMERA"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (cameraOn) {
                            _getImage(ImageSource.gallery);
                            setState(() {
                              cameraOn = false;
                            });
                          } else {
                            setState(
                                () => {imagePath = '', predictionResult = ""});
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text("GALLERY"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text("CANCEL"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        Center(child: CircularProgressIndicator());
      }
    }

    if (!_controller.value.isInitialized) {
      return Container();
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          // actions: <Widget>[
          //   PopupMenuButton<String>(
          //     onSelected: (val) {
          //       setState(() {
          //         hour = val;
          //         debugPrint(hour);
          //       });
          //     },
          //     itemBuilder: (BuildContext context) {
          //       return goMicro.map((String choice) {
          //         return PopupMenuItem<String>(
          //           value: choice,
          //           child: Text(choice),
          //         );
          //       }).toList();
          //     },
          //   ),
          // ],
          backgroundColor: const Color(0xff0c343d),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          centerTitle: true,
          titleTextStyle: const TextStyle(fontSize: 15),
          title: Text('Predict $mlModel ${suffix[mlModel]} ($part)'),
          toolbarHeight: 60,
        ),
        backgroundColor: primaryColor,
        body: cameraOn
            ? Column(
                children: [
                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 20),
                  //   height: 80,
                  //   child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.end, children: []),
                  // ),
                  // CAMERA PREVIEW
                  SizedBox(
                    width: size.width,
                    height: size.width,
                    child: Stack(children: [
                      //Camera
                      Camera(
                        controller: _controller,
                        size: size,
                      ),
                      YellowBox(X: size.width),
                    ]),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "GoMicro Value : $hour",
                        style:
                            const TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Center(
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isRightHanded = !isRightHanded;
                          });
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.recycle,
                          color: Colors.white,
                          size: 30,
                        )),
                  )),
                  // BUTTONS SECTION
                  isRightHanded
                      ? Expanded(
                          child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (cameraOn) {
                                      _pickImageAndSetStates();
                                      setState(() {
                                        cameraOn = false;
                                      });
                                    } else {
                                      setState(() => {
                                            imagePath = '',
                                            predictionResult = ""
                                          });
                                    }
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: primaryColor,
                                          border: Border.all(
                                              color: primaryColor, width: 5),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Icon(
                                        Icons.file_upload,
                                        size: 40,
                                        color: Colors.white,
                                      )),
                                ),
                                PopupMenuButton<String>(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.ellipsisVertical,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  onSelected: (val) {
                                    setState(() {
                                      hour = val;
                                      debugPrint(hour);
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return goMicro.map((String choice) {
                                      return PopupMenuItem<String>(
                                        value: choice,
                                        child: Text(choice),
                                      );
                                    }).toList();
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      flashOn = !flashOn;
                                      if (flashOn) {
                                        setFlashMode(FlashMode.torch);
                                      } else {
                                        setFlashMode(FlashMode.off);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    !flashOn ? Icons.flash_off : Icons.flash_on,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (cameraOn) {
                                      captureImage().then((imageXfile) => {
                                            cropImage(imageXfile.path),
                                            setState(() => {
                                                  cameraOn = false,
                                                  imagePath = imageXfile.path,
                                                }),
                                            _apiCallSetStates(imageXfile.path)
                                          });
                                    } else {
                                      setState(() => {
                                            imagePath = '',
                                            predictionResult = ""
                                          });
                                    }
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: primaryColor,
                                          border: Border.all(
                                              color: primaryColor, width: 5),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Colors.white,
                                      )),
                                ),
                                IconButton(
                                  onPressed: () {
                                    imagePickerOption();
                                  },
                                  icon: Icon(Icons.camera_outlined),
                                  iconSize: 40,
                                  color: Colors.white,
                                ),
                              ]),
                        ))
                      : Expanded(
                          child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      imagePickerOption();
                                    },
                                    child: Icon(Icons.camera_outlined)),
                                GestureDetector(
                                  onTap: () {
                                    if (cameraOn) {
                                      captureImage().then((imageXfile) => {
                                            cropImage(imageXfile.path),
                                            setState(() => {
                                                  cameraOn = false,
                                                  imagePath = imageXfile.path
                                                }),
                                            _apiCallSetStates(imageXfile.path)
                                          });
                                    } else {
                                      setState(() => {
                                            imagePath = '',
                                            predictionResult = ""
                                          });
                                    }
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: primaryColor,
                                          border: Border.all(
                                              color: primaryColor, width: 5),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Colors.white,
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      flashOn = !flashOn;
                                      if (flashOn) {
                                        setFlashMode(FlashMode.torch);
                                      } else {
                                        setFlashMode(FlashMode.off);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    !flashOn ? Icons.flash_off : Icons.flash_on,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.ellipsisVertical,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  onSelected: (val) {
                                    setState(() {
                                      hour = val;
                                      debugPrint(hour);
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return goMicro.map((String choice) {
                                      return PopupMenuItem<String>(
                                        value: choice,
                                        child: Text(choice),
                                      );
                                    }).toList();
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (cameraOn) {
                                      _pickImageAndSetStates();
                                      setState(() {
                                        cameraOn = false;
                                      });
                                    } else {
                                      setState(() => {
                                            imagePath = '',
                                            predictionResult = ""
                                          });
                                    }
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: primaryColor,
                                          border: Border.all(
                                              color: primaryColor, width: 5),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Icon(
                                        Icons.file_upload,
                                        size: 40,
                                        color: Colors.white,
                                      )),
                                ),
                              ]),
                        )),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      )),
    );
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

class Camera extends StatelessWidget {
  final Size size;
  final CameraController controller;
  const Camera({Key? key, required this.controller, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
        reverse: true,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio * size.aspectRatio,
            child: CameraPreview(
              controller,
            ),
          ),
        ]);
  }
}
