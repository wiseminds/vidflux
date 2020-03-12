///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
library vidflux;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'src/app_lifecycle_observer.dart';
import 'src/kvideo_controls.dart';
import 'src/playpause_button.dart';
import 'src/screen_manager.dart';

const IS_DEBUG_MODE = kDebugMode;

/// ```
/// A widget that plays video given the video url, this is not suitable for youtube videos see
/// youtube_player_flutter for playing youtube videos
///```
class VidFlux extends StatefulWidget {
  final bool isFullscreen;
  final VideoPlayerController videoPlayerController;
  final TouchDetector _touchDetector;

  /// a widget to show when the video is in error state
  final Widget errorWidget;

  /// a widget to show when the video is in error state
  final Widget loadingIndicator;

  final int retry;

  VidFlux({
    Key key,
    @required this.videoPlayerController,
    this.isFullscreen = false,
    this.errorWidget,
    this.loadingIndicator,
    this.retry = 5,
  })  : _touchDetector =
            TouchDetector(videoPlayerController, isFullscreen ?? false),
        super(key: key);
  @override
  _KVideoWidgetState createState() => _KVideoWidgetState();
}

class _KVideoWidgetState extends State<VidFlux>
// with WidgetsBindingObserver
{
  VideoPlayerController _videoPlayerController;
  bool isLoading = true;
  bool isInitializing = true;
  int retryInit;
  StateNotifier _stateNotifier;
  AppLifeCycleObserver _lifeCycleObserver;
  bool _wasPlayingBeforePause = false;
  void _errorListener() {
    if (widget.videoPlayerController.value.hasError) {
      // _stateNotifier.setLoading(false);
      widget._touchDetector.toggleControl(false);
      if (IS_DEBUG_MODE)
        print(
            'error listener. $retryInit   .${_videoPlayerController.value?.errorDescription}');

      if (retryInit > 0) {
        retryInit--;
        _videoPlayerController?.value?.copyWith();
        if (_videoPlayerController.value?.errorDescription?.contains('404') ??
            false) {
          _stateNotifier.setLoading(false);
          _stateNotifier.setHasError(
              true, _videoPlayerController.value?.errorDescription);
          retryInit = 5;
          setState(() {});
        } else
          initController();
      } else {
        _stateNotifier.setLoading(false);
        _stateNotifier.setHasError(
            true, _videoPlayerController.value?.errorDescription);
        retryInit = 5;
        setState(() {});
      }
    }
    // else if (_stateNotifier._hasError)
    //   _stateNotifier.setHasError(
    //     false,
    //   );
  }

  void _screenListener(Timer t) async {
    if (_videoPlayerController?.value?.isPlaying ?? false) {
      if (await ScreenManager().isKeptOn()) return;
      await ScreenManager().keepOn(true);
    } else if (await ScreenManager().isKeptOn())
      await ScreenManager().keepOn(false);
  }

  static const VIDEOSCREEN = 1000;
  @override
  void initState() {
    retryInit = widget.retry;
    _videoPlayerController = widget.videoPlayerController;
    // _lifeCycleObserver =
    // Provider.of<AppLifeCycleObserver>(context, listen: false) ??
    //         AppLifeCycleObserver();
    // _lifeCycleObserver.addCallbacks([
    //   CallbackItem(_onPause, VIDEOSCREEN, AppLifecycleState.paused),
    //   CallbackItem(_onResume, VIDEOSCREEN, AppLifecycleState.resumed)
    // ]);
    Timer.periodic(Duration(seconds: 5), _screenListener)..tick;
    _stateNotifier = StateNotifier();
    if (!_videoPlayerController.value.initialized) initController();

    _videoPlayerController.addListener(_errorListener);
    // if (widget.isFullscreen &&
    //     (_videoPlayerController?.value?.initialized ?? false))
    _videoPlayerController.play();
    super.initState();
  }

  void _onPause() {
    _wasPlayingBeforePause = _videoPlayerController.value.isPlaying;
    print('onpause called $_wasPlayingBeforePause');
    if (widget.videoPlayerController.value.isPlaying)
      _videoPlayerController?.pause();
  }

  void _onResume() {
    print('onresume called $_wasPlayingBeforePause');
    if (widget.videoPlayerController != null) {
      if (!widget.videoPlayerController.value.initialized) initController();
    }
    if (_wasPlayingBeforePause) _videoPlayerController?.play();
  }

  void initController() {
    _stateNotifier.setLoading(true);
    _videoPlayerController?.value?.copyWith();
    _stateNotifier.setHasError(false);
    if (IS_DEBUG_MODE) print('init .........................$retryInit');
    _videoPlayerController
      ..initialize().then((_) {
        isInitializing = false;
        if (IS_DEBUG_MODE)
          print('success init .........................$retryInit');
        isLoading = false;
        _stateNotifier.setLoading(false);
        _videoPlayerController?.value?.copyWith();
        _stateNotifier.setHasError(false);
        retryInit = widget.retry;
        _videoPlayerController.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_errorListener);
    _lifeCycleObserver?.removeCallbacks(VIDEOSCREEN);
    ScreenManager().keepOn(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (_videoPlayerController.value.isPlaying)
            widget._touchDetector
                .toggleControl(!widget._touchDetector._showControls);
          else if (!widget._touchDetector._showControls)
            widget._touchDetector.toggleControl(true);
        },
        // onHorizontalDragStart: (details) {
        //   _stateNotifier.setTakeAction(false);
        // },
        // onHorizontalDragEnd: (details) {
        //   _stateNotifier.setTakeAction(true);
        // },
        // onHorizontalDragCancel: () {
        //   _stateNotifier.setTakeAction(true);
        // },
        // onHorizontalDragUpdate: (details) async {
        // WidgetsBinding.instance.addPostFrameCallback((d) async {
        //   if ( _videoPlayerController.value.initialized) {
        //      _videoPlayerController.seekTo(
        //         await  _videoPlayerController?.position +
        //             Duration(seconds: (details.delta.dx > 1 ? 10 : -10)));

        //      _videoPlayerController?.play();
        //   }
        // });
        // },
        child: Container(
            color: Colors.black,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => widget._touchDetector),
                ChangeNotifierProvider(create: (_) => _stateNotifier)
              ],
              child: AspectRatio(
                  aspectRatio: (widget.isFullscreen &&
                          MediaQuery.of(context).orientation ==
                              Orientation.landscape)
                      ? (MediaQuery.of(context).size.width /
                          MediaQuery.of(context).size.height)
                      : _videoPlayerController.value.initialized
                          ? _videoPlayerController.value.aspectRatio
                          : 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      _videoPlayerController.value.initialized
                          ? VideoPlayer(_videoPlayerController)
                          : Container(
                              color: Colors.black,
                            ),
                      Center(child: LoadinIndicator(_videoPlayerController)),
                      if (_videoPlayerController.value.initialized)
                        PlayPauseButton(
                          controller: _videoPlayerController,
                        ),
                      if (_videoPlayerController.value.initialized)
                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            alignment: Alignment.bottomCenter,
                            child: KVideoControls(_videoPlayerController,
                                playerKey: widget.key,
                                isFullScreen: widget.isFullscreen)),
                      ErrorWidget(initController: initController),
                    ],
                  )),
            )));
    // Chewie(controller: _playerController);
  }
}

class StateNotifier with ChangeNotifier {
  bool _isLoading;
  bool _hasError;
  bool takeAction;
  String message;
  Duration position;
  StateNotifier()
      : _isLoading = true,
        _hasError = false,
        takeAction = true,
        position = Duration.zero;

  get isLoading => _isLoading;
  get hasError => _hasError;
  void setHasError(bool val, [String message]) {
    _hasError = val;
    this.message = _formatMessage(message);
    notifyListeners();
  }

  void setTakeAction(bool val) {
    takeAction = val;
    notifyListeners();
  }

  void setPosition(Duration val) {
    position = val;
    notifyListeners();
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _formatMessage([String message]) {
    if (message == null) return null;
    if (message.contains('HttpDataSourceException'))
      return 'An Error occured playing video, please check your internet connection';
    if (message.contains('404'))
      return 'This Channel is not currently Streaming Please contact channel Admin';
    return 'An Error occured playing video';
  }
}

class LoadinIndicator extends StatefulWidget {
  final VideoPlayerController _controller;

  const LoadinIndicator(this._controller);
  @override
  _LoadinIndicatorState createState() => _LoadinIndicatorState();
}

class _LoadinIndicatorState extends State<LoadinIndicator> {
  bool isBuferring = true;
  Duration position = Duration.zero;
  @override
  void initState() {
    if (IS_DEBUG_MODE) print('init loader');
    widget._controller?.addListener(_buferingListener);
    // isBuferring = widget.isLoading;
    position = widget._controller?.value?.position ?? Duration.zero;
    super.initState();
  }

  @override
  void dispose() {
    widget._controller.removeListener(_buferingListener);
    super.dispose();
  }

  int _counter = 0;
  void _buferingListener() {
    // print('counter..........................$_counter');

    if (_counter > 10) {
      _counter = 0;
      if (Provider.of<StateNotifier>(context, listen: false).position ==
          widget._controller?.value?.position) {
        if (!Provider.of<StateNotifier>(context, listen: false).isLoading &&
            Provider.of<StateNotifier>(context, listen: false).takeAction)
          Provider.of<StateNotifier>(context, listen: false).setLoading(true);
        if (!(widget._controller?.value?.isPlaying ?? false))
          Provider.of<StateNotifier>(context, listen: false).setLoading(false);
      } else {
        if (Provider.of<StateNotifier>(context, listen: false).isLoading &&
            Provider.of<StateNotifier>(context, listen: false).takeAction)
          Provider.of<StateNotifier>(context, listen: false).setLoading(false);
        if (!(widget._controller?.value?.isPlaying ?? false))
          Provider.of<StateNotifier>(context, listen: false).setLoading(false);
      }
      if (Provider.of<StateNotifier>(context, listen: false).takeAction)
        Provider.of<StateNotifier>(context, listen: false)
            .setPosition(widget._controller?.value?.position);
    }
    //  if (_counter == 1)
    // Provider.of<StateNotifier>(context).setPosition(widget._controller?.value?.position);
    _counter++;
    if (widget._controller?.value?.isBuffering ?? true)
      Provider.of<StateNotifier>(context, listen: false).setLoading(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StateNotifier>(
        builder: (context, state, _) =>
            state._isLoading || (widget._controller?.value?.isBuffering ?? true)
                ? Container(
                    width: 70.0,
                    height: 70.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : SizedBox.shrink());
  }
}

class ErrorWidget extends StatefulWidget {
  final Function initController;

  const ErrorWidget({Key key, this.initController}) : super(key: key);
  @override
  _ErrorWidgetState createState() => _ErrorWidgetState();
}

class _ErrorWidgetState extends State<ErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateNotifier>(
        builder: (context, state, _) => state._hasError
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Text(
                      state.message ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          letterSpacing: 2),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: RaisedButton(
                          color: Colors.white,
                          child: Text(
                            'Reload',
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(color: Colors.black),
                          ),
                          onPressed: widget.initController),
                    ),
                    // Spacer(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox.shrink());
  }
}

class TouchDetector with ChangeNotifier {
  final VideoPlayerController _playerController;
  bool _showControls = true;
  bool _isFullScreen;

  TouchDetector(this._playerController, this._isFullScreen)
      : _showControls = !_isFullScreen;

  VideoPlayerController get playerController => _playerController;
  bool get showControls => _showControls;
  bool get isFullScreen => _isFullScreen;

  set fullScreen(bool value) => _isFullScreen = value;
  bool _inProgress = false;
  void toggleControl(bool value) {
    if (value) {
      _showControls = value;
      _inProgress = false;
      notifyListeners();
    } else if (!_inProgress) {
      _inProgress = true;
      Future.delayed(Duration(seconds: 5), () {
        // if (_showControls == true && _playerController.value.isPlaying) {
        _showControls = value;
        _inProgress = false;
        notifyListeners();
        // }
      });
    }
  }
}
