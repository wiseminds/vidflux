///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:vidflux/vidflux.dart';


class FullScreenDialog extends StatefulWidget {
  final VideoPlayerController controller;
  final List<DeviceOrientation> orientations;
  final List<DeviceOrientation> exitOrientations;
  final Widget loadingIndicator;

  const FullScreenDialog({Key key, this.controller, this.orientations, this.exitOrientations, this.loadingIndicator }) : super(key: key);
  @override
  _FullScreenDialogState createState() => _FullScreenDialogState();
}

class _FullScreenDialogState extends State<FullScreenDialog> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(widget.orientations ?? [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.restoreSystemUIOverlays();
     SystemChrome.setPreferredOrientations(widget.exitOrientations ?? [DeviceOrientation.portraitUp]);
    super.dispose();
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
        loadingIndicator: widget.loadingIndicator,
        isFullscreen: true,
      )),
    );
  }
}
