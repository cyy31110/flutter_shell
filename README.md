# flutter_shell

flutter+h5混合开发的壳

文档：

1、main.dart文件home: AppHome(url:'修改为服务器url');

2、前端页面开放功能
pl_scan.postMessage(回调函数名称);  //扫描二维码
pl_location.postMessage(回调函数名称); //获取定位

let jsonObj = {
  msg: '消息内容',                     //回调信息内容
  payload: {
    parameter: 'flutter_callback',    //回调函数名称
    cameraScanResult: '调用成功!'      //点击消息时，调用回调函数时传入的参数
  }
}
pl_msg.postMessage(JSON.stringify(jsonObj));  //推送通知


//回调函数格式
//需要挂载在window下
window.flutter_callback = flutter_callback;
flutter_callback(message) {
  Dialog({ message: message });
},
