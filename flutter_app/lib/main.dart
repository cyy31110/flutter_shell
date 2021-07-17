import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutterapp/router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutterapp/page/wev_index.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async';

void main() {
  runApp(MyApp(title: '欢迎使用混合开发'));
}

//扫码函数,最简单的那种
// Future scan() async {
//   String cameraScanResult = await scanner.scan(); //通过扫码获取二维码中的数据
//
//   String filePath = cameraScanResult;
//   this.setState(() {
//     // ignore: unnecessary_statements
//     filePath;
//   });
// }

class MyApp extends StatelessWidget {
  const MyApp({Key key, @required this.title}) : super(key: key);

  final String title;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: this.title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //测试模式
        home: MyHomePage(title: '')
        //生产模式
        // home: AppHome(
        //     url:
        //         '生产url')
        );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.initValue: 0}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final int initValue;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Duration timeout;
  Timer timer;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    this._counter = widget.initValue;
    print("initState");

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);

    this.timeout = Duration(seconds: 2);
  }

  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
  }

  showNotification() async {
    var android = new AndroidNotificationDetails(
        _counter.toString(),
        'channel NAME' + _counter.toString(),
        'CHANNEL DESCRIPTION' + _counter.toString(),
        priority: Priority.High,
        importance: Importance.Max);

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0,
        'New Video is out' + _counter.toString(),
        'Flutter Local Notification' + _counter.toString(),
        platform,
        payload: 'Nitish Kumar Singh is part time Youtuber');
  }

  void opentime() {
    this.timer = Timer.periodic(timeout, (timer) {
      //callback function
      //1s 回调一次
      // print('afterTimer=' + DateTime.now().toString());
      showNotification();
    });
  }

  void closetime() {
    this.timer.cancel();
  }

  /// 动态申请定位权限
  void requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      print("照相权限申请通过");
    } else {
      print("照相权限申请不通过");
    }
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.camera.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.camera.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future scan() async {
    requestPermission();
    String cameraScanResult = await scanner.scan(); //通过扫码获取二维码中的数据
    print('cameraScanResult::::::' + cameraScanResult);
    PageRouter.push(context, 'home', {'url': cameraScanResult});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("扫码页面"),
              textColor: Colors.blue,
              onPressed: scan,
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("開始消息推送"),
              textColor: Colors.blue,
              // onPressed: showNotification,
              onPressed: opentime,
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("關閉消息推送"),
              textColor: Colors.blue,
              onPressed: closetime,
            ),
          ],
        ),
      ),
    );
  }
}

class NewRoute extends StatelessWidget {
  const NewRoute(
      {Key key, @required this.title, this.backgroundColor: Colors.blue})
      : super(key: key);

  final String title;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Route"),
      ),
      body: Container(
          child: Container(
              color: this.backgroundColor,
              child: Builder(builder: (context) {
                Scaffold scaffold =
                    context.findAncestorWidgetOfExactType<Scaffold>();
                return (scaffold.appBar as AppBar).title;
              }))),
    );
  }
}
