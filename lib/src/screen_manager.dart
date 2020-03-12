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
  Timer _screenTimer;

  void _initializeTimer() => _screenTimer =
      Timer.periodic(Duration(seconds: 30), _screenListener)..tick;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _initializeTimer();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _screenTimer.cancel();
        ScreenManager().keepOn(false);
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    WidgetsBinding.instance.addObserver(this);
  }

  void _screenListener(Timer t) async {
    print(t);
    if (widget.controller?.value?.isPlaying ?? false) {
      if (await ScreenManager().isKeptOn()) return;
      await ScreenManager().keepOn(true);
    } else if (await ScreenManager().isKeptOn())
      await ScreenManager().keepOn(false);
  }

  @override
  void deactivate() {
    ScreenManager().keepOn(false);
    _screenTimer.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _screenTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: add functionality to change brigthness
    return SizedBox.shrink();
  }
}

class ScreenManager {
  Future<double> getBrightness() async => await Screen.brightness;

  Future<double> setBrightness(double brightness) async =>
      await Screen.setBrightness(brightness);

  Future<bool> isKeptOn() async => await Screen.isKeptOn;

  Future<bool> keepOn(bool on) async => await Screen.keepOn(on);
}
