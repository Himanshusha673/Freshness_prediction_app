import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:qzapp/my_new_camera/my_camera_page.dart';
import 'package:qzapp/my_new_camera/my_result_page.dart';
import 'package:qzapp/resultspage.dart';
import 'package:qzapp/webview.dart';
import 'home.dart';
import 'camerapage.dart';
import 'login.dart';
import 'package:requests/requests.dart';
// import 'package:shared_preferences/shared_preferences.dart';

String authToken = '';
List<CameraDescription> cameras = [];

Future<bool> checkAuthToken(prefs) async {
  final token = prefs.getString('token') ?? "";
  if (token != "") {
    debugPrint('Local Token found!');
    debugPrint('Local Token : $token\n');
    final email = prefs.getString('email') ?? "";
    var res = await Requests.get(
        'http://dev-qzenserd-dev.ap-south-1.elasticbeanstalk.com/api/auth/users/me/',
        headers: {'authorization': 'Bearer $token'});
    Map<String, dynamic> data =
        Map<String, dynamic>.from(json.decode(res.content()));
    debugPrint(data.toString());
    debugPrint("local email : $email");
    debugPrint('api email : ${data["email"]}');
    if (email == data['email']) {
      debugPrint('Auth Succesfully Found using Token :))))))');
      prefs.setString('username', data['username']);
      return true;
    } else {
      debugPrint('\n!!!!!!! Auth not Found using Token !!!!!!!\n');
      return false;
    }
  } else {
    // debugPrint('!!!!!!! Auth not Found using Token !!!!!!!');
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List cameras = await availableCameras();

  // debugPrint("LEN OF CAMERA : ${cameras.length.toString()}");

  ///////////////////////////////////////
  // UNCOMMENT TOGETHER

  // final prefs = await SharedPreferences.getInstance();
  // bool auth = await checkAuthToken(prefs);
  ///////////////////////////////////////

  bool auth = true;
  debugPrint('Auth and Camera received');
  debugPrint('Auth : $auth');
  runApp(GetMaterialApp(
    color: const Color.fromRGBO(12, 52, 61, 1),
    // initialRoute: auth ? '/home' : '/login',
    initialRoute: '/home',
    home: const HomePage(),
    routes: {
      // '/newCamera': (context) => MyCameraPage(listOfCameras: cameras),
      '/login': (context) => const LoginPage(),
      '/home': (context) => const HomePage(),
      '/officialWebsite': (context) => const OfficialWebsite(),
      '/qzenseDashboard': (context) => const DashBoardPage(),
      '/predict': (context) => CameraApp(
            listOfCameras: cameras,
          ),
      '/results': (context) => const ResultsPage(),
      '/resultPage': (context) => MyResultPage(),
    },
  ));
}
