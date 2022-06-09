import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

class OfficialWebsite extends StatefulWidget {
  const OfficialWebsite({Key? key}) : super(key: key);

  @override
  State<OfficialWebsite> createState() => _OfficialWebsiteState();
}

class _OfficialWebsiteState extends State<OfficialWebsite> {
  late WebViewController controllerGlobal;
  bool isLoading = true;

  Future<bool> _exitApp(BuildContext context) async {
    if (await controllerGlobal.canGoBack()) {
      debugPrint("onwill goback");
      controllerGlobal.goBack();
      return Future.value(false);
    } else {
      // Scaffold.of(context).showSnackBar(
      //   const SnackBar(content: Text("No back history item")),
      // );
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff0c343d),
            automaticallyImplyLeading: true,
            leading: BackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text("Qzense Official"),
            centerTitle: true,
          ),
          body: Stack(children: [
            WebView(
              onWebViewCreated: (controller) => {controllerGlobal = controller},
              gestureNavigationEnabled: true,
              allowsInlineMediaPlayback: true,
              zoomEnabled: false,
              onPageFinished: (url) {
                setState(() {
                  isLoading = false;
                });
              },
              initialUrl: 'https://www.qzense.com/',
              javascriptMode: JavascriptMode.unrestricted,
            ),
            Center(
              child: isLoading ? const CircularProgressIndicator() : null,
            )
          ]),
        ),
      ),
    );
  }
}

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({Key? key}) : super(key: key);

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff0c343d),
          leading: BackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Qzense Dashboard"),
          centerTitle: true,
        ),
        body: const WebView(
          initialUrl: 'https://dashboard.qzenselabs.com/',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
