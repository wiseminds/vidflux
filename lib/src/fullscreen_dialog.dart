///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:vidflux/vidflux.dart';

import 'screen_manager.dart';

class FullScreenDialog extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenDialog({Key key, this.controller}) : super(key: key);
  @override
  _FullScreenDialogState createState() => _FullScreenDialogState();
}

class _FullScreenDialogState extends State<FullScreenDialog> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    ScreenManager().keepOn(true);
  }

  @override
  void dispose() {
    SystemChrome.restoreSystemUIOverlays();
     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
    // SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    ScreenManager().keepOn(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async {
    SystemChrome.restoreSystemUIOverlays();
     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
    // SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    return true;
      },
          child: Material(
          child: VidFlux(
        key: widget.key,
        videoPlayerController: widget.controller,
        isFullscreen: true,
      )),
    );
  }
}
