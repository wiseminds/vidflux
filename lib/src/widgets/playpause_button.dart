///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:vidflux/src/state/touch_notifier.dart';

import '../../vidflux.dart';
/// A widget to display play/pause button.
class PlayPauseButton extends StatefulWidget {
  final VideoPlayerController controller;

  const PlayPauseButton({Key key, this.controller}) : super(key: key);

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  VideoPlayerController _controller;
  AnimationController _animController;

  @override
  void initState() {
    _controller = widget.controller;
    super.initState();
    _animController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_playPauseListener);
  }

  @override
  void didUpdateWidget(PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_playPauseListener);
    widget.controller.addListener(_playPauseListener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_playPauseListener);
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller?.removeListener(_playPauseListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.controller.addListener(_playPauseListener);
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        widget.controller.removeListener(_playPauseListener);
        break;
      default:
        break;
    }
  }

  bool _inProgress = false;
  void _playPauseListener() {
    // if (!_controller.value.isPlaying)
    // Provider.of<TouchDetector>(context, listen: false).toggleControl(true);
    // else  Provider.of<TouchDetector>(context, listen: false).toggleControl(false);
    //  if (Provider.of<TouchDetector>(context).showControls && !_wait){
    //   _wait = true;
    //   Future.delayed(Duration(seconds: 5), () {
    //      Provider.of<TouchDetector>(context).toggleControl(false);
    //       _wait = false;
    //      });
    //      }
    if (_controller.value.isPlaying) {
      if (!_inProgress &&
          Provider.of<TouchNotifier>(context, listen: false).value) {
        _inProgress = true;
        Future.delayed(Duration(seconds: 3), () {
          if (Provider.of<TouchNotifier>(context, listen: false).value &&
              _controller.value.isPlaying)
            Provider.of<TouchNotifier>(context, listen: false).toggleControl();
          _inProgress = false;
        });
      }
      if (_animController.status.index < 3 && !_animController.isAnimating)
        _animController.forward();
    } else {
      if (_animController.status.index > 1 && !_animController.isAnimating)
        _animController.reverse();
    }
  }

  bool showControls = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Consumer<TouchNotifier>(builder: (context, detector, _) {
          return AnimatedOpacity(
              duration: Duration(milliseconds: 700),
              curve: Curves.decelerate,
              opacity: detector?.value ?? true ? 1 : 0,
              child: Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50.0),
                  onTap: Provider.of<StateNotifier>(context).hasError ||
                          !detector.value
                      ? null
                      : () {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        },
                  child: Material(
                    color: Colors.black12,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _animController.view,
                      color: Colors.white,
                      size: 60.0,
                    ),
                  ),
                ),
              ));
        }),
      ],
    );
  }
}
