///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';
import 'package:vidflux/src/state/touch_notifier.dart';

import 'fullscreen_dialog.dart';
import 'progress_bar.dart';

class VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final Key playerKey;
  final bool isFullScreen;
  final bool showToggle;
  final List<DeviceOrientation> fullScreenOrientations;
  final List<DeviceOrientation> exitOrientations;
  final Widget loadingIndicator;

  const VideoControls(
    this.controller, {
    Key key,
    this.playerKey,
    this.isFullScreen,
    this.fullScreenOrientations,
    this.exitOrientations, this.loadingIndicator, this.showToggle = true,
  }) : super(key: key);
  @override
  _VideoControlsState createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls>
    with WidgetsBindingObserver {
  final BehaviorSubject<String> _durationSubject =
      BehaviorSubject.seeded('0.0');
  final BehaviorSubject<String> _positionSubject =
      BehaviorSubject.seeded('0.0');
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_positionListener);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.controller.addListener(_positionListener);
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        widget.controller.removeListener(_positionListener);
        break;
      default:
        break;
    }
  }

  void _positionListener() {
    _positionSubject.add(
        _formatDuration(widget.controller?.value?.position?.inMilliseconds) ??
            '0.0');
    _durationSubject.add(
        _formatDuration(widget.controller?.value?.duration?.inMilliseconds) ??
            '');
  }

  @override
  void didUpdateWidget(VideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_positionListener);
    widget.controller.addListener(_positionListener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_positionListener);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_positionListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TouchNotifier>(builder: (context, detector, _) {
      return AnimatedAlign(
          duration: Duration(milliseconds: 500),
          alignment: Alignment(0, detector.value ? 1 : 1.5),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 700),
            opacity: detector.value ? 1 : 0,
            child: Container(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Row(
                children: <Widget>[
                  StreamBuilder(
                      stream: _positionSubject.stream,
                      builder: (context, snapshot) => Text(
                          snapshot.data ?? '0.0',
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Colors.white,
                              ))),
                  ProgressBar(
                    controller: widget.controller,
                    isExpanded: true,
                    colors: ProgressBarColors(
                      backgroundColor: Colors.white,
                      playedColor: Theme.of(context).accentColor,
                      bufferedColor: Colors.amber,
                    ),
                  ),
                  StreamBuilder(
                      stream: _durationSubject.stream,
                      builder: (context, snapshot) => Text(snapshot.data ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: Colors.white))),
                 widget.showToggle ? IconButton(
                      color: Colors.white,
                      icon: Icon(widget.isFullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen),
                      onPressed: widget.isFullScreen
                          ? () {
                              Future.delayed(Duration.zero, () {
                                SystemChrome.setEnabledSystemUIOverlays(
                                    [SystemUiOverlay.top]);
                                SystemChrome.setPreferredOrientations(
                                    DeviceOrientation.values);
                              });
                              Navigator.of(context).pop();
                            }
                          : () => Navigator.of(context).push(MaterialPageRoute(
                              fullscreenDialog: true,
                              maintainState: true,
                              builder: (c) => Material(
                                      child: FullScreenDialog(
                                    key: widget.key,
                                    loadingIndicator: widget.loadingIndicator,
                                    controller: widget.controller,
                                    orientations: widget.fullScreenOrientations,
                                    exitOrientations: widget.exitOrientations,
                                  )))))
                                  : SizedBox(width: 20,)
                ],
              ),
            ),
          ));
    });
    // Chewie(controller: _playerController);
  }

  String _formatDuration(int milliSeconds) {
    if (milliSeconds == null) return null;
    int seconds = milliSeconds ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;
    final hoursString = hours >= 10 ? '$hours' : hours == 0 ? '00' : '0$hours';
    final minutesString =
        minutes >= 10 ? '$minutes' : minutes == 0 ? '00' : '0$minutes';
    final secondsString =
        seconds >= 10 ? '$seconds' : seconds == 0 ? '00' : '0$seconds';
    final formattedTime =
        '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';
    return formattedTime;
  }
}

