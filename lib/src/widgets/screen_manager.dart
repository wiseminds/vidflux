import 'dart:async';

import 'package:flutter/material.dart';

///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';

class ScreenManagerWidget extends StatefulWidget {
  final VideoPlayerController controller;

  const ScreenManagerWidget(this.controller);
  @override
  _ScreenManagerState createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManagerWidget>
      with WidgetsBindingObserver {
  StreamSubscription _subscription;
  final _watchDuration = Duration(seconds: 30);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
    _subscription.resume();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
       _subscription.pause();
        ScreenManager.keepOn(false);
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _subscription = ScreenManager.watchScreen( _screenListener, _watchDuration);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _screenListener(bool isOn) async {
    print('VidFlux: watching screen- $isOn');
    if (widget.controller?.value?.isPlaying ?? false){
      if(!isOn)
      await ScreenManager.keepOn(true);
    } else if (isOn)
      await ScreenManager.keepOn(false);
  }

  @override
  void deactivate() {
    ScreenManager.keepOn(false);
    _subscription.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
typedef  Future<void> Screenlistener(bool isScreenOn);
class ScreenManager {
  static Future<double> getBrightness() async => await Screen.brightness;

  static Future<double> setBrightness(double brightness) async =>
      await Screen.setBrightness(brightness);

  static Future<bool> isKeptOn() async => await Screen.isKeptOn;

  static Future<bool> keepOn(bool on) async => await Screen.keepOn(on);

  static StreamSubscription watchScreen(Screenlistener listener, Duration watchhDuration)=>
  Stream.periodic(watchhDuration ?? Duration(seconds: 10))
  .listen((event) async {
    listener( await ScreenManager.isKeptOn());
  });
}
