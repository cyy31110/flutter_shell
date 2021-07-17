import 'dart:async';
import 'dart:io';
import 'package:amap_location_flutter_plugin/generated/i18n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 动态权限
import 'package:permission_handler/permission_handler.dart';
// 获取位置
import 'package:amap_location_flutter_plugin/amap_location_flutter_plugin.dart';
import 'package:amap_location_flutter_plugin/amap_location_option.dart';
//转化json
import 'dart:convert' as convert;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'dart:convert' as convert;

// String _locationText;

class AppHome extends StatefulWidget {
  String url = '';
  AppHome({Key key, @required this.url}) : super(key: key);

  @override
  AppHomeState createState() => AppHomeState();
}

class AppHomeState extends State<AppHome> {
  Map<String, Object> _locationResult; // 获取位置
  StreamSubscription<Map<String, Object>> _locationListener;
  AmapLocationFlutterPlugin _locationPlugin = new AmapLocationFlutterPlugin();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  bool _offstage = true;
  // String filePath = 'http://192.168.50.143:8080/#/demo';

  /// 图片选择器
  final ImagePicker _picker = ImagePicker();
  WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 这个api是我在网上找的，必须用自己的，我的代码里也是我自己去申请的，ios的可以先不申请，但是要写，我的ios的key是用下面的这个
    AmapLocationFlutterPlugin.setApiKey(
        '4d7c0dd7abd375a894c6a71ab673256e', '4d7c0dd7abd375a894c6a71ab673256e');

    /// 动态申请定位权限
    requestPermission();

    ///开始定位
    // _startLocation();

    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    ///注册定位结果监听
    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      setState(() {
        _locationResult = result;
        // print('定位结果${result}');
        // _locationText = ' ' +
        //     _locationResult['province'] +
        //     _locationResult['city'] +
        //     _locationResult['district'] +
        //     _locationResult['street'];
      });
    });

    //消息推送
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  //点击消息回调函数
  Future onSelectNotification(String payload) {
    _controller.evaluateJavascript(payload);
    // debugPrint("payload : $payload");
    // showDialog(
    //   context: context,
    //   builder: (_) => new AlertDialog(
    //     title: new Text('Notification'),
    //     content: new Text('$payload'),
    //   ),
    // );
  }

  // 消息推送时间
  showNotification(msg) async {
    Map<String, dynamic> data = convert.jsonDecode(msg);
    print(data);
    String parameter = data['payload']['parameter'];
    String cameraScanResult = data['payload']['cameraScanResult'].toString();
    String payload = "${parameter}('${cameraScanResult}')";
    var android = new AndroidNotificationDetails(
        'channel ID', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);

    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin
        .show(0, '消息', data['msg'].toString(), platform, payload: payload);
  }

  @override
  void dispose() {
    super.dispose();
    if (null != _locationPlugin) {
      _locationPlugin.stopLocation();
    }

    ///移除定位监听
    if (null != _locationListener) {
      _locationListener.cancel();
    }

    ///销毁定位
    if (null != _locationPlugin) {
      _locationPlugin.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return WillPopScope(
        onWillPop: () async {
          _controller.evaluateJavascript("getRouter()");
          return false;
        },
        // onWillPop: () async => showDialog(
        //     context: context,
        //     builder: (context) =>
        //         AlertDialog(title: Text('你确定要退出吗？'), actions: <Widget>[
        //           // ignore: deprecated_member_use
        //           RaisedButton(
        //               child: Text('退出'),
        //               onPressed: () => Navigator.of(context).pop(true)),
        //           // ignore: deprecated_member_use
        //           RaisedButton(
        //               child: Text('取消'),
        //               onPressed: () => Navigator.of(context).pop(false)),
        //         ])),
        child: ScreenUtilInit(
            designSize: Size(360, 690),
            builder: () => SafeArea(
                  // MaterialApp(
                  //       debugShowCheckedModeBanner: false,
                  //       home: Stack(
                  //         alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
                  //         children: <Widget>[
                  child: Visibility(
                      visible: _offstage,
                      replacement: Text('data'),
                      maintainState: true,
                      child: Container(
                          child: WebView(
                        initialUrl: widget.url,
                        javascriptMode: JavascriptMode.unrestricted,
                        javascriptChannels: <JavascriptChannel>[
                          JavascriptChannel(
                              name: "show_flutter_toast",
                              onMessageReceived: (JavascriptMessage message) {
                                print("参数： ${message.message}");
                              }),
                          JavascriptChannel(
                              name: "pl_exit",
                              onMessageReceived: (JavascriptMessage message) {
                                // exit(0);
                                SystemNavigator.pop();
                                // Navigator.of(context).pop(true);
                              }),
                          JavascriptChannel(
                              name: "pl_scan",
                              onMessageReceived: (JavascriptMessage message) {
                                print(message.message);
                                scan(message.message);
                              }),
                          JavascriptChannel(
                              name: "pl_callphone",
                              onMessageReceived: (JavascriptMessage message) {
                                // print(message.message);
                                callphone(message.message);
                              }),
                          JavascriptChannel(
                              name: "pl_location",
                              onMessageReceived: (JavascriptMessage message) {
                                if (_locationResult != null) {
                                  // String _locationText = ' ' +
                                  //     _locationResult['province'] +
                                  //     _locationResult['city'] +
                                  //     _locationResult['district'] +
                                  //     _locationResult['street'];

                                  String _locationText =
                                      convert.jsonEncode(_locationResult);

                                  _controller.evaluateJavascript(
                                      "${message.message}('${_locationText}')");
                                }

                                // print(message.message);
                                // scan(message.message);
                              }),
                          JavascriptChannel(
                              name: "pl_video",
                              onMessageReceived:
                                  (JavascriptMessage message) async {
                                video(message.message);
                              }),
                          JavascriptChannel(
                              name: "pl_msg",
                              onMessageReceived:
                                  (JavascriptMessage message) async {
                                print(message.message);
                                showNotification(message.message);
                              }),
                          JavascriptChannel(
                              name: "pl_callajax",
                              onMessageReceived:
                                  (JavascriptMessage message) async {
                                // print(message.message);
                                // Map<String, dynamic> formData =convert.jsonDecode(message.message);

                                // Dio dio = new Dio();
                                // var response = await dio.post(
                                //     'http://192.168.50.143:6767/loadaaa.php',
                                //     data: formData);
                              }),
                        ].toSet(),
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          _controller = webViewController;
                        },
                      ))),
                  //     ],
                  //   ),
                  // )
                )));
  }

  //录制视频
  Future video(msg) async {
    Map<String, dynamic> data = convert.jsonDecode(msg);
    String url = data['url'];
    String parameter = data['parameter'];
    PickedFile pickedFile = await _picker.getVideo(
        source: ImageSource.camera, maxDuration: Duration(seconds: 10));

    var file = new File(pickedFile.path);

    FormData formData = new FormData.fromMap(
        {"file": await MultipartFile.fromFile(file.path, filename: 'kkk.mp4')});

    Dio dio = new Dio();
    var response = await dio.post(url, data: formData);

    _controller.evaluateJavascript("${parameter}('${response}')");
    // print(response);
  }

  ///设置定位参数
  void _setLocationOption() {
    if (null != _locationPlugin) {
      AMapLocationOption locationOption = new AMapLocationOption();

      ///是否单次定位
      locationOption.onceLocation = false;

      ///是否需要返回逆地理信息
      locationOption.needAddress = true;

      ///逆地理信息的语言类型
      locationOption.geoLanguage = GeoLanguage.ZH;

      locationOption.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

      locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

      ///设置Android端连续定位的定位间隔
      locationOption.locationInterval = 2000;

      ///设置Android端的定位模式<br>
      ///可选值：<br>
      ///<li>[AMapLocationMode.Battery_Saving]</li>
      ///<li>[AMapLocationMode.Device_Sensors]</li>
      ///<li>[AMapLocationMode.Hight_Accuracy]</li>
      locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

      ///设置iOS端的定位最小更新距离<br>
      locationOption.distanceFilter = -1;

      ///设置iOS端期望的定位精度
      /// 可选值：<br>
      /// <li>[DesiredAccuracy.Best] 最高精度</li>
      /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
      /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
      /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
      /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
      locationOption.desiredAccuracy = DesiredAccuracy.Best;

      ///设置iOS端是否允许系统暂停定位
      locationOption.pausesLocationUpdatesAutomatically = false;

      ///将定位参数设置给定位插件
      _locationPlugin.setLocationOption(locationOption);
    }
  }

  ///开始定位
  void _startLocation() {
    if (null != _locationPlugin) {
      ///开始定位之前设置定位参数
      _setLocationOption();
      _locationPlugin.startLocation();
    }
  }

  //扫码函数,最简单的那种
  Future scan(parameter) async {
    String cameraScanResult = await scanner.scan(); //通过扫码获取二维码中的数据
    print("哈哈哈");
    print(cameraScanResult);
    print("哈哈哈");
    if (cameraScanResult != null) {
      _controller.evaluateJavascript("${parameter}('${cameraScanResult}')");
    }

    // setState(() {
    //   filePath = cameraScanResult;
    // });
  }

  void callphone(String phone) async {
    String url = 'tel:' + phone;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("hah");
    }
  }

  /// 动态申请定位权限
  void requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await requestLocationPermission('location');
    if (hasLocationPermission) {
      print("定位权限申请通过");
      _startLocation();
    } else {
      print("定位权限申请不通过");
    }

    // 申请权限
    bool hasCameraPermission = await requestLocationPermission('camera');
    if (hasCameraPermission) {
      print("照相权限申请通过");
    } else {
      print("照相权限申请不通过");
    }
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission(String type) async {
    switch (type) {
      case 'location':
        //获取当前的权限
        var status = await Permission.location.status;
        var locationAlwaysstatus = await Permission.locationAlways.status;
        var locationWhenInUsestatus = await Permission.locationWhenInUse.status;
        if (status == PermissionStatus.granted &&
            locationAlwaysstatus == PermissionStatus.granted &&
            locationWhenInUsestatus == PermissionStatus.granted) {
          //已经授权
          return true;
        } else {
          //未授权则发起一次申请
          status = await Permission.location.request();
          locationAlwaysstatus = await Permission.locationAlways.request();
          locationWhenInUsestatus =
              await Permission.locationWhenInUse.request();
          if (status == PermissionStatus.granted &&
              locationAlwaysstatus == PermissionStatus.granted &&
              locationWhenInUsestatus == PermissionStatus.granted) {
            return true;
          } else {
            return false;
          }
        }
        break;
      case 'camera':
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
        break;
    }
  }
}
