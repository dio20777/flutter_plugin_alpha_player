import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_alpha_player_plugin/alpha_player_controller.dart';
import 'package:flutter_alpha_player_plugin/alpha_player_view.dart';
import 'package:flutter_alpha_player_plugin/queue_util.dart';

import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> downloadPathList = [];
  bool isDownload = false;

  @override
  void initState() {
    super.initState();
    initDownloadPath();
  }

  Future<void> initDownloadPath() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    String rootPath = appDocDir.path;
    downloadPathList = ["$rootPath/vap_demo1.mp4", "$rootPath/vap_demo2.mp4"];
    print("downloadPathList:$downloadPathList");
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        home: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // decoration: BoxDecoration(
            //   color: Color.fromARGB(255, 140, 41, 43),
            //   image: DecorationImage(image: AssetImage("assets/bg.jpeg")),
            // ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text(
                          "download video source${isDownload ? "(✅)" : ""}"),
                      onPressed: _download,
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("File1 play"),
                      onPressed: () => _playFile(downloadPathList[0]),
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("File2 play"),
                      onPressed: () => _playFile(downloadPathList[1]),
                    ),
                    // CupertinoButton(
                    //   color: Colors.purple,
                    //   child: Text("asset play"),
                    //   onPressed: () => _playAsset("assets/demo.mp4"),
                    // ),
                    // CupertinoButton(
                    //   color: Colors.purple,
                    //   child: Text("stop play"),
                    //   onPressed: () => AlphaPlayerController.stop(),
                    // ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("queue play"),
                      onPressed: _queuePlay,
                    ),
                    CupertinoButton(
                      color: Colors.purple,
                      child: Text("cancel queue play"),
                      onPressed: _cancelQueuePlay,
                    ),
                  ],
                ),
                const IgnorePointer(
                  // VapView可以通过外层包Container(),设置宽高来限制弹出视频的宽高
                  // VapView can set the width and height through the outer package Container() to limit the width and height of the pop-up video
                  child: AlphaPlayerView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _download() async {
    await Dio().download(
        "http://file.jinxianyun.com/vap_demo1.mp4", downloadPathList[0]);
    await Dio().download(
        "http://file.jinxianyun.com/vap_demo2.mp4", downloadPathList[1]);
    setState(() {
      isDownload = true;
    });
  }

  Future<Map<dynamic, dynamic>?> _playFile(String path) async {
    if (path == null) {
      return null;
    }
    var res = await AlphaPlayerController.play(path, "demo_play.mp4");
    if (res!["status"] == "failure") {
      showToast(res["errorMsg"]);
    }
    return res;
  }

  // Future<Map<dynamic, dynamic>?> _playAsset(String asset) async {
  //   if (asset == null) {
  //     return null;
  //   }
  //   var res = await AlphaPlayerController.play(path,"vap_demo1.mp4");;
  //   if (res!["status"] == "failure") {
  //     showToast(res["errorMsg"]);
  //   }
  //   return res;
  // }

  _queuePlay() async {
    // 模拟多个地方同时调用播放,使得队列执行播放。
    // Simultaneously call playback in multiple places, making the queue perform playback.
    QueueUtil.get("vapQueue")?.addTask(
        () => AlphaPlayerController.play(downloadPathList[0], "demo_play.mp4"));
    QueueUtil.get("vapQueue")?.addTask(
        () => AlphaPlayerController.play(downloadPathList[1], "demo_play.mp4"));
  }

  _cancelQueuePlay() {
    QueueUtil.get("vapQueue")?.cancelTask();
  }
}
