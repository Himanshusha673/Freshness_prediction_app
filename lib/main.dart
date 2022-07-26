import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qzenesapp/constants.dart';
import 'package:qzenesapp/generated_routes.dart';
import 'package:qzenesapp/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool auth = false;
Future<bool> checkAuthToken(prefs) async {
  final token = prefs.getString('token') ?? "";
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      debugPrint('Connected');
    }
  } on SocketException catch (_) {
    debugPrint('not Connected');
  }
  if (token != "") {
    debugPrint('Local Token found!');
    debugPrint('Local Token : $token\n');
    final email = prefs.getString('email') ?? "";

    // var res = await Requests.get(
    //     'http://mobileapi.qzenselabs.com:8000/api/auth/jwt/clear/',
    //     headers: {'authorization': 'Bearer $token'});
    // Map<String, dynamic> data =
    //     Map<String, dynamic>.from(json.decode(res.content()));
    // debugPrint(data.toString());
    // debugPrint("local email : $email");
    // debugPrint('api email : ${data["email"]}');
    // if (res.statusCode >= 200 && res.statusCode < 400) {
    //   debugPrint('Token Found Sucessfully');
    //   return true;
    // } else {
    //   debugPrint('Token Expired');
    //   return false;
    // }
    return true;
  } else {
    debugPrint('!!!!!!! Auth not Found using Token !!!!!!!');
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  auth = await checkAuthToken(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: const Color.fromRGBO(12, 52, 61, 1),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: auth ? '/' : Login_page,

      onGenerateRoute: MyRoutes.route,
      //home: ,
    );
  }
}