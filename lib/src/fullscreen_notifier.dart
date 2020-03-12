///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenNotifier with ChangeNotifier {
  int _itemClicked = 0;
  bool _isFullScreen = false;

  bool get isFullScreen => _isFullScreen;

  void setFullScreen(bool value) {
    _isFullScreen = value;
    // SchedulerBinding.instance.addPostFrameCallback((duration) {
    if (value) {
      SystemChrome.setEnabledSystemUIOverlays([]);
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      Future.delayed(
          Duration.zero,
          () =>
              SystemChrome.setPreferredOrientations(DeviceOrientation.values));
    }
    notifyListeners();
  }
}