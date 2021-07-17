import 'package:flutter/material.dart';
import 'package:flutterapp/test/web_view_example_state.dart';
import 'package:flutterapp/test/web_amap.dart';
import 'package:flutterapp/page/wev_index.dart';

class PageRouter {
  Widget _getPage(String url, dynamic params) {
    switch (url) {
      case 'webview':
        return WebViewExample(url: params['url']);
      case 'amap':
        return AmapPage();
      case 'home':
        return AppHome(url: params['url']);
    }
    return null;
  }

  PageRouter.pushNoParams(BuildContext context, String url) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return _getPage(url, null);
    }));
  }

  PageRouter.push(BuildContext context, String url, dynamic params) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return _getPage(url, params);
    }));
  }
}
