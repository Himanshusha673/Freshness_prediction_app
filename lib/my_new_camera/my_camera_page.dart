// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:qzapp/camerapage.dart';

// import 'package:qzapp/my_new_camera/Widgets/yellow_box.dart';

// import 'package:qzapp/my_new_camera/my_result_page.dart';

// class MyCameraPage extends StatefulWidget {
//   final List listOfCameras;
//   const MyCameraPage({Key? key, required this.listOfCameras}) : super(key: key);

//   @override
//   State<MyCameraPage> createState() => MyCameraPageState();
// }

// class MyCameraPageState extends State<MyCameraPage> {
//   // late CameraController myCameraController;
//   // late Future<void> _initializeControllerFuture;

//   String imagePath = '';
//   // void initState() {
//   //   super.initState();
//   //   myCameraController = CameraController(
//   //       widget.listOfCameras[0], ResolutionPreset.medium,
//   //       enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
//   //   //
//   //   myCameraController.initialize().then((_) {
//   //     if (!mounted) {
//   //       return;
//   //     }
//   //     setState(() {});
//   //   });
//   // }

//   // Future<XFile> capptureImage() async {
//   //   return await myCameraController.takePicture();
//   // }

//   // void onNewCameraSelected(CameraDescription description) {
//   //   debugPrint('$description.toString()');
//   // }

//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   // App state changed before we got the chance to initialize.
//   //   if (!myCameraController.value.isInitialized) {
//   //     return;
//   //   }
//   //   if (state == AppLifecycleState.inactive) {
//   //     debugPrint('YOYOYOYO INACTIVE');
//   //     myCameraController.dispose();
//   //   } else if (state == AppLifecycleState.resumed) {
//   //     onNewCameraSelected(myCameraController.description);
//   //   } else {
//   //     myCameraController.dispose();
//   //   }
//   // }

//   @override
//   // void dispose() {
//   //   myCameraController.dispose();
//   //   super.dispose();
//   // }

//   bool _isCameraOn = true;
//   late XFile imageFile;

//   getImage(ImageSource source) async {
//     this.setState(() {
//       _isCameraOn = true;
//     });
//     XFile? image = await ImagePicker().pickImage(source: source);

//     if (image != null) {
//       Future<CroppedFile?> croppedImage = ImageCropper().cropImage(
//           sourcePath: image.path,
//           aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
//           compressQuality: 100,
//           maxWidth: 700,
//           maxHeight: 700,
//           compressFormat: ImageCompressFormat.jpg,
//           uiSettings: [
//             AndroidUiSettings(
//               toolbarColor: Colors.grey,
//               toolbarTitle: 'Type',
//               statusBarColor: Colors.grey.shade700,
//               backgroundColor: Colors.white,
//             ),
//           ]);
//       this.setState(() {
//         imageFile = croppedImage as XFile;
//         _isCameraOn = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final deviceRatio = size.width / size.height;
//     final aspectRatio = 1 / 1;

//     // if (!myCameraController.value.isInitialized) {
//     //   return Center(
//     //     child: CircularProgressIndicator(color: Colors.red),
//     //   );
//     // } else {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Stack(children: [
//         // SizedBox(
//         //   height: size.width,
//         //   width: size.width,
//         //   child: AspectRatio(
//         //     aspectRatio: 1,
//         //     child: ClipRect(
//         //       child: Transform.scale(
//         //         scale: 1 / myCameraController.value.aspectRatio,
//         //         child: CameraPreview(
//         //           myCameraController,
//         //         ),
//         //       ),
//         //     ),
//         //   ),
//         // ),//HI I'm checking the code
//         // Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//         /////////////////////////////////////////////

//         //  GestureDetector(
//         //     child: Icon(
//         //       Icons.camera,
//         //       size: 40,
//         //     ),
//         //     onTap: () async {
//         //       XFile imageXFile = await capptureImage();

//         //       setState(() {
//         //         imagePath = imageXFile.path;
//         //         isCameraOn = false;
//         //       });

//         //       Navigator.pushNamed(context, '/resultPage',
//         //           arguments: {'path': imageXFile.path, 'size': size});
//         //     },
//         //  ),
//         // this  code for when we use camera preview
//         ////////////////////////////////////////
//         ///

//         /////////////////////////////////////

//         Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//           GestureDetector(
//             child: Icon(
//               Icons.camera,
//               size: 40,
//             ),
//             onTap: () {
//               getImage(ImageSource.camera);
//               Navigator.pushNamed(context, '/resultPage', arguments: {
//                 'path': imageFile.path,
//                 'size': size,
//                 'imageFile': imageFile 
//               });
//             },
//           ),
//           GestureDetector(
//             child: Icon(
//               Icons.upload,
//               size: 40,
//             ),
//             onTap: () {
//               getImage(ImageSource.gallery);

//               Navigator.pushNamed(context, '/resultPage', arguments: {
//                 'path': imageFile.path,
//                 'size': size,
//                 'imageFile': imageFile
//               });
//             },
//           )
//         ]),
//       ]),
//     );
//   }
// }
